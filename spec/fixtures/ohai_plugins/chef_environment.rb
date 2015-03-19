require 'chef/config'
Ohai.plugin(:ChefEnvironment) do
  provides 'chef_environment'

  collect_data do
    Chef::Config.from_file File.expand_path('../../etc/chef/client.rb', __FILE__)
    chef_environment Chef::Config[:environment]
  end
end
