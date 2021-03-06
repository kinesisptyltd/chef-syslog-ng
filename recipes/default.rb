extend SyslogNg

apt_repository "syslog-ng" do
  uri "http://download.opensuse.org/repositories/home:/laszlo_budai:/syslog-ng/xUbuntu_14.04"
  key "http://download.opensuse.org/repositories/home:/laszlo_budai:/syslog-ng/Debian_8.0/Release.key"
  components ["./"]
end.run_action(:add)

%w(syslog-ng-core syslog-ng).each do |pkg|
  package(pkg) do
    action :install
  end.run_action(:install)
end

# Make sure to remove rsyslog
%w(rsyslog-gnutls rsyslog).each do |pkg|
  package pkg do
    action :remove
  end.run_action(:remove)
end

@svc = service "syslog-ng" do
  supports status: true, start: true, stop: true, restart: true, reload: true
  provider Chef::Provider::Service::Init::Debian
  action :enable
end

@svc.run_action(:enable)

template "/etc/syslog-ng/syslog-ng.conf" do
  mode "0644"
  owner "root"
  source "syslog-ng.conf.erb"
end.run_action(:create)

@svc.run_action(:start)

include_recipe "syslog-ng::papertrail" if node["syslog-ng"]["papertrail"]["install_ca_bundle"]
