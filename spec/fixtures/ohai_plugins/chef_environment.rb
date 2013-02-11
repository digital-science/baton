require 'chef/config'
provides 'chef_environment'

Chef::Config.from_file File.expand_path('../../etc/chef/client.rb', __FILE__)
chef_environment Chef::Config[:environment]
