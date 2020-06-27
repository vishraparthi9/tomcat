default['java']['jdk_version']='7'
default['java']['java_home']='/usr/lib/jvm/jre'

## Tomcat attributes
default['tomcat']['group']='tomcat'
default['tomcat']['gid']=1001

default['tomcat']['user']='tomcat'
default['tomcat']['home_dir']='/opt/tomcat'
default['tomcat']['shell']='/bin/nologin'

default['tomcat']['tar_url']='https://downloads.apache.org/tomcat/tomcat-8/v8.5.56/bin/apache-tomcat-8.5.56.tar.gz'
default['tomcat']['download_location']='/tmp/apache-tomcat-8.5.56.tar.gz'
default['tomcat']['webapps_folder']='/opt/tomcat/webapps'

default['tomcat']['systemd_file_path']='/etc/systemd/system/tomcat.service'
default['tomcat']['catalina_pid']='/opt/tomcat/temp/tomcat.pid'
default['tomcat']['catalina_opts']='-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
default['tomcat']['startup_script']='/opt/tomcat/bin/startup.sh'