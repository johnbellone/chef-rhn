actions :register

default_action :register

attribute :profile_name, :name_attribute => true

attribute :activation_keys, :kind_of => [String], :default => lazy { node['rhn']['activation_keys'] }
attribute :cmd_timeout, :kind_of => [Integer], :default => lazy { node['rhn']['cmd_timeout'] }
attribute :hostname, :kind_of => [String], :default => lazy { node['rhn']['hostname'] }
attribute :username, :kind_of => [String], :default => lazy { node['rhn']['username'] }
attribute :password, :kind_of => [String], :default => lazy { node['rhn']['password'] }
attribute :system_id, :kind_of => [String]
attribute :no_hardware, :kind_of => [TrueClass, FalseClass], :default => false
attribute :no_packages, :kind_of => [TrueClass, FalseClass], :default => false
attribute :no_virtinfo, :kind_of => [TrueClass, FalseClass], :default => false
attribute :no_rhnsd, :kind_of => [TrueClass, FalseClass], :default => true
