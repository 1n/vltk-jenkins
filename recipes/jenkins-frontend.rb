#
# Cookbook Name:: vltk-jenkins
# Recipe:: jenkins-frontend
#
# Copyright (C) 2015 private, inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'route53'

route53_record 'create CNAME record' do
  name                   node['jenkins']['frontend']['hostname']
  zone_id                node['route53']['zone_id']
  value                  node['ec2']['public_hostname']
  type                   'CNAME'
  ttl                    600
  action :create
end

httpd_service 'jenkins' do
  mpm 'event'
  listen_ports ['80']
  action [:create, :start]
end

%w{proxy proxy_http}.each do |mod|
  httpd_module mod do
    instance 'jenkins'
    action :create
  end
end

if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
  search(:node, 'roles:jenkins-backend-master').each do |jenkins_master_node|
    httpd_config 'jenkins' do
      instance 'jenkins'
      source 'jenkins-vhost.conf.erb'
      variables({
                    :server_name  => node['jenkins']['frontend']['hostname'],
                    :jenkins_url  => jenkins_master_node['fqdn'],
                    :jenkins_port => jenkins_master_node['jenkins']['master']['port']
                })
      notifies :restart, 'httpd_service[jenkins]'
      action :create
    end
  end
end