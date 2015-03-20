require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut
include Helpers::Rhn

class CommandTimeout < RuntimeError; end

def load_current_resource
  @current_resource = Chef::Resource::RhnSystem.new(new_resource)
  if ::File.exist?('/etc/sysconfig/rhn/systemid')
    systemid = {}
    require 'rexml/document'
    systemid_xml = REXML::Document.new(::File.open('/etc/sysconfig/rhn/systemid', 'r'))
    systemid_xml.root.each_element('param/value/struct/member') do |e|
      next if e.elements['name'].text == 'fields'
      systemid.merge!(e.elements['name'].text => e.elements['value'].elements['string'].text)
    end
    @current_resource.profile_name(systemid['profile_name'])
    @current_resource.system_id(systemid['system_id'])
  end
  @current_resource
end

action :register do
  unless registered?
    register
    new_resource.updated_by_last_action(true)
  end
end

def execute_cmd(cmd, timeout = new_resource.cmd_timeout)
  Chef::Log.debug('Executing: ' + cmd)
  begin
    shell_out(cmd, :timeout => timeout)
  rescue Mixlib::ShellOut::CommandTimeout
    raise CommandTimeout, <<-EOM

Command timed out:
#{cmd}

Please adjust node['rhn']['cmd_timeout'] attribute or this rhn_system cmd_timeout attribute if necessary.
EOM
  end
end

def registered?
  @current_resource.system_id
end

def register
  args = {
    'force' => true,
    'profilename' => new_resource.profile_name,
    'nohardware' => new_resource.no_hardware,
    'novirtinfo' => new_resource.no_virtinfo,
    'nopackages' => new_resource.no_packages,
    'norhnsd' => new_resource.no_rhnsd
  }

  unless new_resource.hostname == 'xmlrpc.rhn.redhat.com'
    args.merge!('serverUrl' => "https://#{new_resource.hostname}/XMLRPC")
  end

  args.merge!('username' => new_resource.username) if new_resource.username
  args.merge!('password' => new_resource.password) if new_resource.password
  args.merge!('activationkey' => new_resource.activation_keys) if new_resource.activation_keys
  execute_cmd("rhnreg_ks #{cli_args(args)}")
end
