default['java']['install_flavor'] = 'oracle'
default['java']['jdk_version'] = '7'
default['java']['oracle']['accept_oracle_download_terms'] = true

default['streamsets']['streamsets']['package_name'] = 'streamsets-datacollector'
default['streamsets']['streamsets']['version'] = '1.0.0b2-1'
default['streamsets']['apache-kafka']['package_name'] = 'streamsets-datacollector-apache-kafka_0.8.2.0-lib'
default['streamsets']['apache-kafka']['version'] = '1.0.0b2-1'
default['streamsets']['sdc-cli']['version'] = '0.1.0'

default['kafka']['package']['location'] = 'http://10.21.100.41/lithium/tarballs/kafka_2.10-0.8.2.0.tgz'
#default['kafka']['package']['location'] = 'http://yum.core.lithium.com/lithium/tarballs/kafka_2.10-0.8.2.0.tgz'

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


#########DIR########

default['streamsets']['pipeline']['configuration']['community'] = "${record:attribute('tag')}"
#Use this when merging with Lithium
#default['streamsets']['pipeline']['configuration']['log_end_path'] = '/serv/journaling/'
default['streamsets']['pipeline']['configuration']['log_end_path'] = ''
default['streamsets']['pipeline']['configuration']['log_pattern'] = '/${PATTERN}'
#Use this when merging with Lithium
#default['streamsets']['pipeline']['configuration']['log_base_path'] = '/home/lithium/customer/'
default['streamsets']['pipeline']['configuration']['log_base_path'] = '/share/input/'

default['streamsets']['pipeline']['configuration']['topicExpression'] = "lia.${record:attribute('tag')}.raw_events"
#Use this for Merge
#default['streamsets']['pipeline']['configuration']['metadataBrokerList'] = "XX"
default['streamsets']['pipeline']['configuration']['metadataBrokerList'] = "10.10.125.56:9092"

default['streamsets']['pipeline']['configuration']['queueBufferingMaxMs'] = '100'
default['streamsets']['pipeline']['configuration']['messageSendMaxRetries'] = '90'
default['streamsets']['pipeline']['configuration']['retryBackoffMs'] = '10000'
default['streamsets']['pipeline']['configuration']['compressionCodec'] = 'LZ4'

#Topic Creation
#Dont use HostName for Vagrant Testing. Use this to Merge
# default['streamsets']['topic']['configuration']['zookeeper'] = "XX"
default['streamsets']['topic']['configuration']['zookeeper'] = "10.10.125.56:2181"
#default['streamsets']['topic']['configuration']['replication'] = 3
#default['streamsets']['topic']['configuration']['partition'] = 1
