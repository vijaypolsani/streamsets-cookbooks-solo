# streamsets-cookbooks-solo
<br>
** StreamSets Chef Cookbooks for local testing using Vagrant **
<br>
* This cookbook is for testing locally using Vagrant for StreamSets. *
<br>
- 1) Clone the project
- 2) cd cookbooks/streamsets/
- 3) vagrant up
<br>
- Note: Makesure Vagrant, VirtualBox is installed on your machine and working
<br>
** Input Files Needed:**
- streamsets-datacollector-1.0.0b2-1.rpm
- streamsets-datacollector-apache-kafka_0.8.2.0-lib-1.0.0b2-1.rpm
- sdc-cli-0.1.0.tar.gz
- kafka_2.10-0.8.2.0.tgz

** VagrantFile Configuration **
* Please change the below according to your machine. Make sure to copy the needed files under sync folder to be available for vagrant *
<br>
    - config.vm.network "forwarded_port", guest: 18630, host: 20000
    - config.vm.synced_folder "/Users/vijay.polsani/Downloads/", "/share/"

* ASSUMPTIONS *
<br>
This below has a . in front of the name for demarcation. Make sure the env name has this!
<br>
- #default['lia']['phase'] = '.stage'
<br>
This below has a ''. Means no env variable in PROD
-  default['lia']['phase'] = ''
- Kafka brokers are reachable. If you cannot reach them, it will fail to send messages.

