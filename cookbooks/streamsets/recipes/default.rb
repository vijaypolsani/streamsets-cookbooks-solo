#
# Cookbook Name:: streamsets
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


include_recipe 'java'
include_recipe 'tar'

unless node[cookbook_name]['sdc']['environment'].include?('JAVA_HOME')
  streamset_env = node[cookbook_name]['sdc']['environment'].dup
  streamset_env['JAVA_HOME'] = node['java']['java_home']
  node.set[cookbook_name]['sdc']['environment'] = streamset_env
end

package node[cookbook_name]['streamsets']['package_name'] do
  action :install
  #Local test for individual cookbook
  source '/share/streamsets-datacollector-1.0.0b2-1.noarch.rpm'
end

package node[cookbook_name]['apache-kafka']['package_name'] do
  action :install
  #Local test for individual cookbook
  source '/share/streamsets-datacollector-apache-kafka_0.8.2.0-lib-1.0.0b2-1.noarch.rpm'
end

include_recipe 'python::pip'

=begin
# Add the internal pip server.
# TODO: Need a better way to add this...
directory "/root/.pip" do
  action :create
end

file "/root/.pip/pip.conf" do
  content "[global]\nextra-index-url=http://pypi.lcloud.com:8080/simple\ntrusted-host=pypi.lcloud.com\n"
end
=end

python_pip 'requests' do
  action :install
end

python_pip 'setuptools' do
  action :install
end

python_pip 'pip' do
  action :upgrade
end

=begin
python_pip 'sdc-cli' do
  version node[cookbook_name]['sdc-cli']['version'] if !node[cookbook_name]['sdc-cli']['version'].nil?
  action :install
end
=end

# Use this to install locally.
execute 'install-streamsets-cli' do
  command 'pip install /share/sdc-cli-0.1.0.tar.gz'
  user 'root'
end

# Unzip Kafka libraries for creating the TOPIC with 1 Partition & 3 Replicas
execute 'Create sdc directory' do
  command "mkdir /opt/sdc"
  creates "/opt/sdc"
end

tar_extract node['kafka']['package']['location']  do
#tar_extract 'http://yum.core.lithium.com/lithium/tarballs/kafka_2.10-0.8.2.0.tgz'  do
  target_dir '/opt/kafka'
  creates '/opt/sdc/kafka_2.10-0.8.2.0/bin/kafka-topics.sh'
end

=begin

# Execute command way: Unzip Kafka libraries for creating the TOPIC with 1 Partition & 3 Replicas
execute 'UnTar kafka_2.10-0.8.2.0.tgz' do
  command 'mkdir /opt/sdc | tar xzf /share/kafka_2.10-0.8.2.0.tgz'
  cwd '/opt/sdc'
  creates '/opt/sdc/kafka_2.10-0.8.2.0/bin/kafka-topics.sh'
end
=end

template '/etc/sdc/sdc.properties' do
  source 'sdc.properties.erb'
  owner 'sdc'
  group 'sdc'
  mode '0600'
  variables (
                {
                    :http_port => node[cookbook_name]['sdc']['http_port'],
                    :https_port => node[cookbook_name]['sdc']['https_port'],
                    :execution_mode => node[cookbook_name]['sdc']['execution_mode']
                }
            )
  notifies :restart, "service[sdc]", :delayed
end

template '/opt/sdc/current/libexec/sdcd-env.sh' do
  source 'sdcd-env.sh.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables (
                {
                    :env => node[cookbook_name]['sdc']['environment']
                }
            )
  notifies :restart, "service[sdc]", :delayed
end

# Pulled logic from Couchbase cookbook
# https://github.com/disney/couchbase/blob/441064912f4781b658b9c16c67e8b4a03f480f21/recipes/server.rb#L73
ruby_block "sdc_block_until_operational" do
  block do
    max_retries = 10
    retry_count = 0
    Chef::Log.info("Waiting until SDC is listening on port #{node[cookbook_name]['sdc']['http_port']}")
    until StreamsetsHelpers::Server.service_listening?(node[cookbook_name]['sdc']['http_port']) do
      retry_count += 1
      raise "SDC is not listening on port #{node[cookbook_name]['sdc']['http_port']}. Retried #{retry_count} times before aborting." unless retry_count <= max_retries
      sleep 5
      Chef::Log.debug(".")
    end

    retry_count = 0
    Chef::Log.info("Waiting until the SDC admin API is responding")
    test_uri = URI("http://localhost:#{node[cookbook_name]['sdc']['http_port']}/ping")
    until StreamsetsHelpers::Server.endpoint_responding?(test_uri) do
      retry_count += 1
      raise "SDC API is not responding on port #{node[cookbook_name]['sdc']['http_port']}. Retried #{retry_count} times before aborting." unless retry_count <= max_retries
      sleep 1
      Chef::Log.debug(".")
    end
  end
  action :nothing
  subscribes :run, 'service[sdc]', :immediately
end

service 'sdc' do
  action [:start, :enable]
  supports :status => true, :start => true, :stop => true, :restart => true
end

communities = StreamsetsHelpers::CommunitiesList.sub_folders?(node['streamsets']['pipeline']['configuration']['log_base_path'])
# RUN the  TOPIC with 1 Partition & 3 Replicas
communities.each do |community|
  Chef::Log.info("Community Name for Topic Creation: #{community}")
  execute 'Create Topic in Kafka' do
    command "/opt/kafka/kafka_2.10-0.8.2.0/bin/kafka-topics.sh --create --zookeeper #{node.streamsets.topic.configuration.zookeeper} --partitions 1 --replication-factor 3 --topic lia.#{community}.raw_events"
    not_if "/opt/kafka/kafka_2.10-0.8.2.0/bin/kafka-topics.sh --list --zookeeper #{node.streamsets.topic.configuration.zookeeper} --partitions 1 --replication-factor 3 --topic lia.#{community}.raw_events| grep 'lia.#{community}.raw_events'"
  end
end

ruby_block "Find Communities from Folders" do
  block do
    Chef::Log.info("Communities Name:  #{communities}")
    communities.each do |community|
      Chef::Log.info("Community Name for PATH creation in JSON : #{community}")
      node.set['streamsets']['pipeline']['configuration']['fileInfos']["#{community}"] = {
          'fileFullPath' => "#{node.streamsets.pipeline.configuration.log_base_path}#{community}#{node.streamsets.pipeline.configuration.log_end_path}#{node.streamsets.pipeline.configuration.log_pattern}",
          'fileRollMode' => 'PATTERN',
          'patternForToken' => '.*',
          'firstFile' => ''
      }
    end
  end
end

streamsets_config node[cookbook_name]['pipeline']['name'] do
  action :create
end
