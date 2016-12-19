
# Run in this directory, or append at the end of each commmand:
# --workdir=/home/jez/prj/veewee -f

# See definitions
veewee kvm list
time veewee kvm build 'centos7-jzn' -f
time veewee kvm build 'debian8-jzn' -f


# Create new template
veewee kvm templates
veewee kvm define centos-7-jzn 'CentOS-7.0-1406-x86_64-netinstall' --workdir=/home/jez/prj/veewee/definitions
veewee kvm build 'centos-7-jzn' --workdir=/home/jez/prj/veewee/definitions



