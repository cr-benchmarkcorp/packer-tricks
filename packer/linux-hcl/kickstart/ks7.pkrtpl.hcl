# Kickstart file for RHEL7.9
# Version: 0.0.1
# Date: 2021-07-30

# Install a fresh new system (optional)
install

# Performs the Kickstart installation in text mode. Kickstart installations are performed in graphical mode by default. (optional)
text

# Set language to use during installation and the default language to use on the installed system (required)
lang en_US.UTF-8

# Set system keyboard type / layout (required)
keyboard --xlayouts='us'
###keyboard us

# Configures the X Window System (optional)
xconfig --startxonboot

# Configure network information for target system and activate network devices in the installer environment (optional)
# --onboot	enable device at a boot time
# --device	device to be activated and / or configured with the network command
# --bootproto	method to obtain networking configuration for device (default dhcp)
# --noipv6	disable IPv6 on this device
#
# NOTE: Usage of DHCP will fail CCE-27021-5 (DISA FSO RHEL-06-000292). To use static IP configuration,
#       "--bootproto=static" must be used. For example:
#network --onboot=yes --device=eth0 --bootproto=static --ip=10.10.118.15 --netmask=255.255.254.0 --gateway=10.10.118.1 --nameserver=8.8.8.8
network  --bootproto=dhcp --hostname rhel7template
###network --device eth0 --bootproto dhcp --hostname banner8template

# Set the system's root password (required)
rootpw --plaintext Sammut99*!
###rootpw --iscrypted $6$zOaxFcuH$8ZjEWFU9e6P8ZRlw/FECc1vYB5PpzczJyxIydMeyEjLNSqtiEzJngmFDmc7.EtdQoqLmWHYIL12qSAUj8bD6O1

# Disable the system's host firewall (optional).  Requested by SAIT.
firewall --disabled 

# Set up the authentication options for the system (required)
# --enableshadow	enable shadowed passwords by default
# --passalgo		hash / crypt algorithm for new passwords
# See the manual page for authconfig for a complete list of possible options.
###authconfig --enableshadow --enablemd5

# State of SELinux on the installed system (optional)
selinux --disabled

# Set the system time zone (required)
timezone --utc America/Edmonton

# Specify how the bootloader should be installed (required)
# Plaintext password is: IloveStarwar$888
# Refer to e.g. http://fedoraproject.org/wiki/Anaconda/Kickstart#rootpw to see how to create
# encrypted password form for different plaintext password
bootloader --location=mbr --append="rhgb quiet"

# Initialize (format) all disks (optional)
zerombr

# Remove Linux partitions from the system prior to creating new ones (optional)
# --linux	erase all Linux partitions
# --initlabel	initialize the disk label to the default based on the underlying architecture
clearpart --linux --initlabel

# Create primary system partitions (required for installs)
part /boot --fstype ext4 --size=800
part pv.01 --size=300 --grow --asprimary --ondisk sda

# Create a Logical Volume Management (LVM) group (optional)
volgroup VolGroup00 --pesize=32768 pv.01

# Create particular logical volumes (optional)
logvol / --fstype ext4 --name=LogVol_root --vgname=VolGroup00 --size=15360
# Ensure /home Located On Separate Partition
logvol /home --fstype ext4 --name=LogVol_home --vgname=VolGroup00 --size=10240
# Ensure /swap Located On Separate Partition
logvol swap --fstype swap --name=LogVol_sawp --vgname=VolGroup00 --size=8192
# Ensure /var Located On Separate Partition
logvol /var --fstype ext4 --name=LogVol_var --vgname=VolGroup00 --size=20480
# Ensure /tmp Located On Separate Partition
logvol /tmp --fstype ext4 --name=LogVol_tmp --vgname=VolGroup00 --size=10240
# Ensure /usr Located On Separate Partition
logvol /usr --fstype ext4 --name=LogVol_usr --vgname=VolGroup00 --size=20480

# Packages selection (%packages section is required)
%packages

@base
@core
fipscheck
device-mapper-multipath
sgpio
python-dmidecode
emacs
audit
audit-libs*
telnet
sendmail
sendmail-cf
lvm2
lvm2-libs
iscsi-initiator-utils
fipscheck
device-mapper-multipath
binutils*
ksh*
gcc*
gcc-c++*
glibc*
glibc-devel*
libgcc*
make
sysstat
open-vm-tools

%end
# End of %packages section

%post

# Automatically add a Red Hat subscription manager (using Packer templating)
--log=/root/registration_results.out
subscription-manager register --auto-attach --username=${rhelusername} --password=${rhelpassword}

%end

#+++ Reboot after the installation is complete (optional)
#+++ --eject	attempt to eject CD or DVD media before rebooting
reboot --eject