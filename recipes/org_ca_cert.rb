if node['rhn']['org_ca_cert']['url'].match(/\.rpm$/)
  package_filename = ::File.basename(node['rhn']['org_ca_cert']['url'])
  package_path = "#{Chef::Config['file_cache_path']}/#{package_filename}"

  remote_file package_path do
    owner 'root'
    group 'root'
    mode '0644'
    source node['rhn']['org_ca_cert']['url']
    if node['rhn']['org_ca_cert']['action'] == 'upgrade'
      action :create
    else
      action :create_if_missing
    end
  end

  package 'rhn-org-trusted-ssl-cert' do
    source package_path
    action node['rhn']['org_ca_cert']['action'].intern
  end
else
  # Use string interpolation to avoid having to rewrite if
  # attributes change for internal satellite servers.
  url = node['rhn']['org_ca_cert']['url'] % {
    hostname: node['rhn']['hostname'],
    name: node['rhn']['org_ca_cert']['name']
  }
  remote_file "/usr/share/rhn/#{node['rhn']['org_ca_cert']['name']}" do
    owner 'root'
    group 'root'
    mode '0644'
    source url
    if node['rhn']['org_ca_cert']['action'] == 'upgrade'
      action :create
    else
      action :create_if_missing
    end
  end
end
