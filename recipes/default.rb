#
# Cookbook:: tomcat
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

yum_package 'java-1.7.0-openjdk' do
  action [ :install, :upgrade ]
end

group node['tomcat']['group'] do
  gid node['tomcat']['gid']
  action :create
end

user node['tomcat']['user'] do
  gid node['tomcat']['gid']
  home node['tomcat']['home_dir']
  shell node['tomcat']['shell']
end

directory node['tomcat']['home_dir'] do
  group node['tomcat']['group']
  user node['tomcat']['user']
 mode "0755"
end

tar_extract node['tomcat']['tar_url'] do
  target_dir node['tomcat']['home_dir']
  download_dir '/tmp'
  tar_flags [ '-P', '--strip-components 1' ]
  group node['tomcat']['group']
  user node['tomcat']['user']
  action :extract
end

## App install
execute "Clean webapps" do
  cwd node['tomcat']['webapps_folder']
  command "rm -rf *"
  not_if { ::File.exist?("#{node['tomcat']['webapps_folder']}/helloworld.war") }
end

remote_file "#{node['tomcat']['webapps_folder']}/helloworld.war" do
  source 'file:///tmp/helloworld.war'
  group node['tomcat']['group']
  owner node['tomcat']['user']
  mode '0755'
end

## Create service file and start tomcat
systemd_unit 'tomcat.service' do
  content <<-EOU.gsub(/^\s+/, '')
  [Unit]
  Description=Apache Tomcat Web Application Container
  After=syslog.target network.target

  [Service]
  Type=forking

  Environment=JAVA_HOME=#{node['java']['java_home']}
  Environment=CATALINA_PID=#{node['tomcat']['catalina_pid']}
  Environment=CATALINA_HOME=#{node['tomcat']['home_dir']}
  Environment=CATALINA_BASE=#{node['tomcat']['home_dir']}
  Environment="CATALINA_OPTS=#{node['tomcat']['catalina_opts']}"

  ExecStart=#{node['tomcat']['startup_script']}
  ExecStop=/bin/kill -15 $MAINPID

  User=#{node['tomcat']['user']}
  Group=#{node['tomcat']['group']}
  UMask=0007
  RestartSec=10
  Restart=always

  [Install]
  WantedBy=multi-user.target
  EOU


  triggers_reload true
  action [ :create, :start, :enable ]
end