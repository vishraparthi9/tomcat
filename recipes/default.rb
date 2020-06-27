#
# Cookbook:: tomcat
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

yum_package 'java-1.7.0-openjdk' do
  action :upgrade
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

remote_file node['tomcat']['download_location'] do
  backup false
  group node['tomcat']['group']
  mode '0755'
  owner node['tomcat']['user']
  source node['tomcat']['tar_url']
  not_if { ::File.exist?(node['tomcat']['startup_script']) }
end

archive_file node['tomcat']['download_location'] do
  destination node['tomcat']['home_dir']
  group node['tomcat']['group']
  mode '0754'
  owner node['tomcat']['user']
  action :extract
end

#template node['tomcat']['systemd_file_path'] do
#  backup false
#  group node['tomcat']['group']
#  owner node['tomcat']['user']
#  mode '0744'
#  source 'centos/tomcat.service.erb'
#  action :create_if_missing
#end

systemd_unit 'tomcat.service' do
  content <<-EOU.gsub(/^\s+/, '')
  [Unit]
  Description=Apache Tomcat Web Application Container
  After=syslog.target network.target

  [Service]
  Type=forking

  Environment=JAVA_HOME=node['java']['java_home']
  Environment=CATALINA_PID=node['tomcat']['catalina_pid']
  Environment=CATALINA_HOME=node['tomcat']['home_dir']
  Environment=CATALINA_BASE=node['tomcat']['home_dir']
  Environment="CATALINA_OPTS=node['tomcat']['catalina_opts']""

  ExecStart=node['tomcat']['startup_script']
  ExecStop=/bin/kill -15 $MAINPID

  User=node['tomcat']['user']
  Group=node['tomcat']['group']
  UMask=0007
  RestartSec=10
  Restart=always

  [Install]
  WantedBy=multi-user.target
  EOU


  user node['tomcat']['user']
  triggers_reload true
  action [ :create, :start, :enable ]
end

