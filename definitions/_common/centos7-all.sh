# Make ssh faster by not waiting on DNS
echo "UseDNS no" >> /etc/ssh/sshd_config

# Note build date
echo -e "TEMPLATE_TS=$(date +'%s')\nTEMPLATE_DATE=$(date +'%m/%d/%y')\nTEMPLATE_TIME=$(date +'%T')" > /etc/template-release

# Install EPEL
yum install -y epel-release

# Install extra packages
yum install -y vim htop wget curl psmisc sudo rsync unzip lsof screen

#  Truc a remove: GeoIP.x86_64  aic94xx-firmware.noarch alsa-firmware.noarch btrfs-progs.x86_64 chrony.x86_64 cronie.x86_64 cronie-anacron.x86_64 cyrus-sasl-lib.x86_64 ebtables.x86_64 ethtool.x86_64 fipscheck.x86_64 firewalld.noarch initscripts.x86_64 iputils.x86_64  *-firmware jansson.x86_64 nettle.x86_64 newt.x86_64 openldap.x86_64 polkit.x86_64 pth.x86_64 snappy.x86_64 slang tcp_wrappers-libs.x86_64  sysvinit-tools.x86_64 ustr.x86_64 vim-minimal.x86_64 wpa_supplicant.x86_64 
# Filesystem                     Size  Used Avail Use% Mounted on
# /dev/mapper/system_vm-slash    1.5G   36M  1.3G   3% /
# devtmpfs                       219M     0  219M   0% /dev
# tmpfs                          229M     0  229M   0% /dev/shm
# tmpfs                          229M  4.4M  224M   2% /run
# tmpfs                          229M     0  229M   0% /sys/fs/cgroup
# /dev/mapper/system_vm-usr      1.5G  915M  439M  68% /usr
# /dev/vda1                      477M  106M  342M  24% /boot
# /dev/mapper/system_vm-tmp       93M  1.6M   85M   2% /tmp
# /dev/mapper/system_vm-var      380M  113M  243M  32% /var
# /dev/mapper/system_vm-var_tmp   93M  1.6M   85M   2% /var/tmp
# /dev/mapper/system_vm-var_log   93M  3.5M   83M   4% /var/log
# tmpfs                           46M     0   46M   0% /run/user/1000


# Configure sudo
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

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


# Configure Grub
cat <<EOF > /etc/default/grub
# If you change this file, run 'grub2-mkconfig -o /boot/grub2/grub.cfg' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_CMDLINE_LINUX_DEFAULT=""

#GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=system_vm/slash rd.lvm.lv=system_vm/swap rd.lvm.lv=system_vm/usr rhgb console=ttyS0 console=ttyS0,115200n8"
GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=system_vm/slash rd.lvm.lv=system_vm/swap rd.lvm.lv=system_vm/usr console=ttyS0 console=ttyS0,115200n8"
GRUB_TERMINAL=serial
#GRUB_TERMINAL_OUTPUT="console"
GRUB_TERMINAL_OUTPUT="serial"
GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"

GRUB_DISABLE_SUBMENU=true
#GRUB_DISABLE_LINUX_UUID=true
#GRUB_DISABLE_RECOVERY="true"
EOF
grub2-mkconfig -o /boot/grub2/grub.cfg

# Create nice bashrc

cat <<EOF > /root/.bash_rc
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
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

if [ -x /usr/bin/colordiff ]; then
        alias diff='colordiff'
fi

# Variables
RGX_IP='([0-2][0-9]{2}\.){3}'

# List directory when moving
#cd() { builtin cd "$@"; ll; }


##########################
# History management
##########################
# Force timestamp in history
HISTTIMEFORMAT='%F %T '

# Synchronise history
shopt -s histappend
PROMPT_COMMAND="history -a; history -n;  $PROMPT_COMMAND"

# Ignore duplicates and lines starting by a space
HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000


##########################
# Misc
##########################

# Update shell output according to the terminal size
shopt -s checkwinsize

# Load other aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Enable completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Bash correction
alias cd..='cd ..'
shopt -s autocd
shopt -s cdspell
shopt -s checkjobs
shopt -s hostcomplete
shopt -s nocaseglob


# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

EOF

# Disable NetworkManager
systemctl disable NetworkManager
systemctl enable network 

# Remove useless packages
yum remove -y NetworkManager* plymouth*
yum -y clean all

# Update initramfs image after plymouth removal
dracut --force


#yum -y erase gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts
#rm -rf /etc/yum.repos.d/{puppetlabs,epel}.repo
#rm -rf VBoxGuestAdditions_*.iso
#
## Remove traces of mac address from network configuration
#sed -i /HWADDR/d /etc/sysconfig/network-scripts/ifcfg-enp0s3


for partition in $(mount | grep '^/' | awk '{print $3}'); do
        echo -n "Zeroing ${partition} partition ... "
	dd if=/dev/zero of=${partition}/EMPTY bs=1M > /dev/null 2>&1 || echo "done!"
        rm -f ${partition}/EMPTY
done

# Reboot VM
echo "Rebooting VM ..."
shutdown -r -t 5
