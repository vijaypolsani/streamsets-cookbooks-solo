def whyrun_supported?
  true
end

action :create do

  pipeline_exists = false
  if ::File.exists?(get_filename)
    pipeline_exists = true
  end

  tpl = template get_filename do
    source 'pipeline.json.erb'
    owner 'sdc'
    group 'sdc'
    mode '0644'
    variables (
                  {
                      :pipeline_name => node[cookbook_name]['pipeline']['name'],
                      :clusterSlaveMemory => node[cookbook_name]['pipeline']['clusterSlaveMemory'],
                      :clusterSlaveJavaOpts => node[cookbook_name]['pipeline']['clusterSlaveJavaOpts'],
                      :clusterKerberos => node[cookbook_name]['pipeline']['clusterKerberos'],
                      :config => node[cookbook_name]['pipeline']['configuration']
                  }
              )
    action :nothing
  end

  tpl.run_action(:create)
  resource_updated = tpl.updated_by_last_action?
  if resource_updated
    if pipeline_exists
      stop_pipeline
    end

    import_pipeline

    Chef::Log.debug("IN wait_for_import_completion. Delay 2 seconds")
    wait_for_import_completion

    start_pipeline
  end

  new_resource.updated_by_last_action(resource_updated)
end

action :remove do
  stop_pipeline
  file get_filename do
    action :delete
  end
end

private
def get_filename
  if new_resource.config_file.nil? or new_resource.config_file.empty?
    ::File.join('/opt/sdc/current', "pipeline-#{new_resource.name}.json")
  else
    new_resource.config_file
  end
end

def import_pipeline
  filename = get_filename
  execute "import-pipeline #{new_resource.name}" do
    user 'sdc'
    command "sdc-cli --sdc-url http://localhost:#{node[cookbook_name]['sdc']['http_port']} --sdc-user admin --sdc-password admin --auth-type form --config-file #{::File.join('/tmp', new_resource.name)}.conf --auth-type form library import #{filename}"
  end
end

=begin
def wait_for_import_completion
  wait_interval = 1
  max_retries = 10
  retry_count = 0

  ruby_block new_resource.name do
    block do
      import_completed = false
      until import_completed do
        output = `sdc-cli --sdc-url http://localhost:#{node[cookbook_name]['sdc']['http_port']} --sdc-user admin --sdc-password admin --config-file #{::File.join('/tmp', new_resource.name)}.conf --auth-type form library list`
     #  output = "Hello World"
        Chef::Log.info "List operation output: '#{output}'"
        pipelines = output.gsub(/^\[|\]$|\n|\"/,'').split(",")
        import_completed = pipelines.length > 0
        Chef::Log.info "import_completed: '#{import_completed}'"
        retry_count += 1
        raise "Pipeline not imported after '#{retry_count}' attempts before aborting." unless retry_count <= max_retries
        Chef::Log.info "List of current pipelines: '#{pipelines}'"
        sleep wait_interval
      end
    end
  end
end
=end

def wait_for_import_completion
  try =1
  execute "wait for #{new_resource.name} to be imported" do
    Chef::Log.debug("IN wait_for_import_completion. Delay 2 seconds #{try+1}")
    command "sdc-cli --sdc-url http://localhost:#{node[cookbook_name]['sdc']['http_port']} --sdc-user admin --sdc-password admin --config-file #{::File.join('/tmp', new_resource.name)}.conf --auth-type form library list | grep '#{new_resource.name}'"
    user 'sdc'
    retries 5
    retry_delay 2
  end
end

def start_pipeline
  execute "start-pipeline #{new_resource.name}" do
    user 'sdc'
    command "sdc-cli --sdc-url http://localhost:#{node[cookbook_name]['sdc']['http_port']} --sdc-user admin --sdc-password admin --auth-type form --config-file #{::File.join('/tmp', new_resource.name)}.conf pipeline start #{new_resource.name}"
  end
end

def stop_pipeline
  execute "stop-pipeline #{new_resource.name}" do
    user 'sdc'
    command "sdc-cli --sdc-url http://localhost:#{node[cookbook_name]['sdc']['http_port']} --sdc-user admin --sdc-password admin --auth-type form --config-file #{::File.join('/tmp', new_resource.name)}.conf pipeline stop"
  end
end

def reset_pipeline
  execute "reset-pipeline #{new_resource.name}" do
    user 'sdc'
    command "sdc-cli --sdc-url http://localhost:#{node[cookbook_name]['sdc']['http_port']} --sdc-user admin --sdc-password admin --auth-type form --config-file #{::File.join('/tmp', new_resource.name)}.conf pipeline reset-origin #{new_resource.name}"
  end
end

