#
# Cookbook Name:: vltk-jenkins
# Recipe:: jenkins-slave
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
  jenkins_slave_user = search(:users, 'id:jenkins-slave').first
end

if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
  search(:node, 'roles:jenkins-slave').each do |jenkins_slave|
    jenkins_ssh_slave 'slave' do
      description 'slave'
      remote_fs   jenkins_slave_user['user_home']
      labels      ['executor', 'slave']

      # SSH specific attributes
      host        jenkins_slave['fqdn']
      user        'jenkins-slave'
      credentials 'jenkins-slave'
    end
  end
end