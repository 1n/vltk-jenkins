#
# Cookbook Name:: vltk-jenkins
# Recipe:: jenkins-config
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

%w{greenballs git github email-ext github-oauth role-strategy scriptler job-dsl}.each do |plugin|
  jenkins_plugin plugin do
    notifies :restart, 'service[jenkins]', :delayed
  end
end