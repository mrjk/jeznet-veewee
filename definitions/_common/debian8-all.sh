#!/bin/bash

# Manage Packages
apt-get -y update
apt-get -y upgrade
apt-get -y install vim curl unzip wget sudo rsync psmisc htop lsof screen

# truc a remove: nano {leagy netutils} vim-tiny sudo? ifupdown? gcc-4.8-base gcc-4.9-base 
# root@debian8-tpl:~# df -h
# Filesystem                     Size  Used Avail Use% Mounted on
# /dev/dm-0                      473M  215M  229M  49% /
# udev                            10M     0   10M   0% /dev
# tmpfs                           49M  4.4M   45M   9% /run
# /dev/dm-2                      965M  301M  598M  34% /usr
# tmpfs                          122M     0  122M   0% /dev/shm
# tmpfs                          5.0M     0  5.0M   0% /run/lock
# tmpfs                          122M     0  122M   0% /sys/fs/cgroup
# /dev/vda1                      226M   33M  178M  16% /boot
# /dev/mapper/system_vm-tmp       93M  1.6M   85M   2% /tmp
# /dev/mapper/system_vm-var      376M  156M  197M  45% /var
# /dev/mapper/system_vm-var_log   89M  3.3M   79M   4% /var/log
# /dev/mapper/system_vm-var_tmp   93M  1.6M   85M   2% /var/tmp
# 
# NAME                  MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# sr0                    11:0    1  247M  0 rom
# vda                   254:0    0  9.9G  0 disk
# ├─vda1                254:1    0  237M  0 part /boot
# ├─vda2                254:2    0    1K  0 part
# └─vda5                254:5    0  9.7G  0 part
#   ├─system_vm-slash   253:0    0  496M  0 lvm  /
#   ├─system_vm-swap    253:1    0  252M  0 lvm  [SWAP]
#   ├─system_vm-usr     253:2    0  996M  0 lvm  /usr
#   ├─system_vm-var     253:3    0  396M  0 lvm  /var
#   ├─system_vm-var_log 253:4    0   96M  0 lvm  /var/log
#   ├─system_vm-tmp     253:5    0  100M  0 lvm  /tmp
#   └─system_vm-var_tmp 253:6    0  100M  0 lvm  /var/tmp


# Note build date
echo -e "TEMPLATE_TS=$(date +'%s')\nTEMPLATE_DATE=$(date +'%m/%d/%y')\nTEMPLATE_TIME=$(date +'%T')" > /etc/template-release

# Manage sudo
echo 'sysmgr ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/sysmgr

# Manage ssh
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Clean debinstaller mess
lvremove /dev/system_vm/free  -f

# Create missing partitions
lvcreate -n tmp -L 100M system_vm
lvcreate -n var_tmp -L 100M system_vm

mkfs.ext4 /dev/system_vm/tmp
mkfs.ext4 /dev/system_vm/var_tmp

sed -i '/\/usr /a /dev/mapper/system_vm-tmp\t/tmp\text4\tnodev,nosuid,noexec\t0\t2' /etc/fstab
sed -i '/\/var /a /dev/mapper/system_vm-var_tmp\t/var/tmp\text4\tnodev,nosuid,noexec\t0\t2' /etc/fstab

rm -rf /tmp/*
rm -rf /var/tmp/*
mount -a


# Manage grub options
cat <<EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(lsb_release -i -s 2> /dev/null || echo Debian)"

GRUB_CMDLINE_LINUX_DEFAULT=""
GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,115200n8"

GRUB_TERMINAL=serial
GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"

#GRUB_DISABLE_LINUX_UUID=true
#GRUB_DISABLE_RECOVERY="true"
EOF
update-grub

# Create nice bashrc
cat <<EOF > /root/.bashrc
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac


##########################
# Prompt management
##########################

# Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Prompt definition
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac


##########################
# Alias and variables
##########################
# Base
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias ltr='ls -ahltr'

alias mkdir='mkdir -pv'

alias ..='cd ../../'
alias ...='cd ../../../'
alias ....='cd ../../../../'

alias vih='vim /etc/hosts'

# Color management
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

# Clean
apt-get -y remove linux-headers-$(uname -r) build-essential
apt-get -y autoremove
apt-get -y clean

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp/*


# Make sure Udev doesn't block our network
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces


# This script create an empty file full of zero to make
# final image smaller.
for partition in $(mount | grep '^/' | awk '{print $3}'); do
        echo -n "Zeroing ${partition} partition ... "
        dd if=/dev/zero of=${partition}/EMPTY bs=1M > /dev/null 2>&1 || echo "done!"
        rm -f ${partition}/EMPTY
done


# Reboot VM
echo "Rebooting VM ..."
shutdown -r -t 5
