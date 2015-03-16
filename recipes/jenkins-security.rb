#
# Cookbook Name:: vltk-jenkins
# Recipe:: jenkins-security
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
  jenkins_admin_user = search(:users, 'id:jenkins').first
end

require 'openssl'
require 'net/ssh'

key = OpenSSL::PKey::RSA.new(jenkins_admin_user['private_key'])
private_key = key.to_pem
public_key = "#{key.ssh_type} #{[key.to_blob].pack('m0')}"
#pubiic_key = jenkins_user['public_key']

# If security was enabled in a previous chef run then set the private key in the run_state
# now as required by the Jenkins cookbook
ruby_block 'set jenkins private key' do
  block do
    node.run_state[:jenkins_private_key] = private_key
  end
  only_if { node.attribute?('security_enabled') }
end

# Add the admin user only if it has not been added already then notify the resource
# to configure the permissions for the admin user
jenkins_user jenkins_admin_user['id'] do
  password jenkins_admin_user['user_password']
  public_keys [public_key]
  not_if { node.attribute?('security_enabled') }
  notifies :execute, 'jenkins_script[configure permissions]', :immediately
end

# Configure the permissions so that login is required and the admin user is an administrator
# after this point the private key will be required to execute jenkins scripts (including querying
# if users exist) so we notify the `set the security_enabled flag` resource to set this up.
# Also note that since Jenkins 1.556 the private key cannot be used until after the admin user
# has been added to the security realm
jenkins_script 'configure permissions' do
  command <<-EOH.gsub(/^ {4}/, '')
    import jenkins.model.*
    import hudson.security.*
    def instance = Jenkins.getInstance()
    def hudsonRealm = new HudsonPrivateSecurityRealm(false)
    instance.setSecurityRealm(hudsonRealm)
    def strategy = new GlobalMatrixAuthorizationStrategy()
    strategy.add(Jenkins.ADMINISTER, "jenkins")
    instance.setAuthorizationStrategy(strategy)
    instance.save()
  EOH
  notifies :create, 'ruby_block[set the security_enabled flag]', :immediately
  action :nothing
end

# Set the security enabled flag and set the run_state to use the configured private key
ruby_block 'set the security_enabled flag' do
  block do
    node.run_state[:jenkins_private_key] = private_key
    node.set['security_enabled'] = true
    node.save
  end
  action :nothing
end