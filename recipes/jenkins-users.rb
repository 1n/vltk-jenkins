#
# Cookbook Name:: vltk-jenkins
# Recipe:: jenkins-users
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
  search(:users, 'group_id:ci OR id:jenkins*').each do |ju|
    jenkins_private_key_credentials ju['id'] do
      description ju['comment']
      private_key ju['private_key']
    end
  end
end