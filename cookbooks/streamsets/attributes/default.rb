default['java']['install_flavor'] = 'oracle'
default['java']['jdk_version'] = '7'
default['java']['oracle']['accept_oracle_download_terms'] = true

default['streamsets']['streamsets']['package_name'] = 'streamsets-datacollector'
default['streamsets']['streamsets']['version'] = '1.0.0b2-1'
default['streamsets']['apache-kafka']['package_name'] = 'streamsets-datacollector-apache-kafka_0.8.2.0-lib'
default['streamsets']['apache-kafka']['version'] = '1.0.0b2-1'
default['streamsets']['sdc-cli']['version'] = '0.1.0'

default['streamsets']['pipeline']['clusterSlaveMemory'] = 1024
default['streamsets']['pipeline']['clusterSlaveJavaOpts'] = '-XX:PermSize=128M -XX:MaxPermSize=256M'
default['streamsets']['pipeline']['clusterKerberos'] = 'false'
default['streamsets']['pipeline']['configuration']['fileInfos'] = {}

default['streamsets']['sdc']['http_port'] = 18630
default['streamsets']['sdc']['https_port'] = -1
default['streamsets']['sdc']['execution_mode'] = 'standalone'

default['streamsets']['sdc']['environment'] = {}

#########Content in lithium_streamsets

default['streamsets']['pipeline']['name'] = 'Firehose_File_Kafka'
default['streamsets']['pipeline']['clusterSlaveMemory'] = 384

#NOTE: Always the community parameter shld come before topicExpression
default['lia']['community'] = 'testcommunity'
#Use this when merging with Lithium
#default['lia']['phase'] = '.stage'
default['lia']['phase'] = ''

#########DIR########

default['streamsets']['pipeline']['configuration']['community'] = "${record:attribute('tag')}"
#Use this when merging with Lithium
#default['streamsets']['pipeline']['configuration']['log_start_path'] = '/home/lithium/customer/'
default['streamsets']['pipeline']['configuration']['log_start_path'] = '/var/log/'
#Use this when merging with Lithium
#default['streamsets']['pipeline']['configuration']['log_end_path'] = '/serv/journaling'
default['streamsets']['pipeline']['configuration']['log_end_path'] = ''
default['streamsets']['pipeline']['configuration']['log_pattern'] = '/${PATTERN}'
default['streamsets']['pipeline']['configuration']['base_path'] = '/var/log'

default['streamsets']['pipeline']['configuration']['topicExpression'] = "lia.${record:attribute('tag')}.raw_events"
default['streamsets']['pipeline']['configuration']['metadataBrokerList'] = "sjc1-kafka-1a-br1.sj.lithium.com:9092,sjc1-kafka-1a-br2.sj.lithium.com:9092,sjc1-kafka-1a-br3.sj.lithium.com:9092"

#Topic Creation
#Dont use HostName for Vagrant Testing. Use this to Merge
# default['streamsets']['topic']['configuration']['zookeeper'] = "sjc1pzoo06.sj.lithium.com:2181,sjc1pzoo07.sj.lithium.com:2181,sjc1pzoo08.sj.lithium.com:2181,sjc1pzoo09.sj.lithium.com:2181,sjc1pzoo10.sj.lithium.com:2181/kafka/sjc1-kafka-1a"
default['streamsets']['topic']['configuration']['zookeeper'] = "10.21.110.124:2181,10.21.110.125:2181,10.21.110.126:2181,10.21.110.127:2181,10.21.110.128:2181/kafka/sjc1-kafka-1a"
#default['streamsets']['topic']['configuration']['replication'] = 3
#default['streamsets']['topic']['configuration']['partition'] = 1
