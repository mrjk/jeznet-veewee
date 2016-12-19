Veewee::Session.declare({
  :cpu_count => '1',
  :memory_size=> '480',
  :disk_size => '10140',
  :disk_format => 'VDI',
  :hostiocache => 'off',
  :os_type_id => 'RedHat6_64',
#  :iso_file => "CentOS-7.0-1406-x86_64-NetInstall.iso",
  :iso_file => "CentOS-7-x86_64-Minimal-1611.iso",
#  :iso_src => "http://mirror.nextlayer.at/centos/7.0.1406/isos/x86_64/CentOS-7.0-1406-x86_64-NetInstall.iso",
  :iso_md5 => "d2ec6cfa7cf6d89e484aa2d9f830517c",
  :iso_download_timeout => 1000,
  :boot_wait => "10",
  :boot_cmd_sequence => [
    '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>'
  ],
  :kickstart_port => "7122",
  :kickstart_timeout => 300,
  :kickstart_file => "ks.cfg",
  :ssh_login_timeout => "10000",
  :ssh_user => "sysmgr",
  :ssh_password => "sysmgrpw",
  :ssh_key => "",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "/sbin/halt -h -p",
  :postinstall_files => [
	  "../_common/centos7-all.sh"
#	  "../_common/centos7-epel.sh",
#	  "../_common/centos7-sudo.sh",
#	  "../_common/centos7-packages.sh",
#	  "../_common/centos7-clean.sh",
#	  "../_common/common-zerodisk.sh"
#    "chef.sh",
#    "puppet.sh",
#    "vagrant.sh",
#    "virtualbox.sh",
    #"vmfusion.sh",
#    "cleanup.sh",
#    "zerodisk.sh"
  ],
  :postinstall_timeout => 10000
})
