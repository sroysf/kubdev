# Overview

Kubernetes local development environment using KVM and Ceph


# Prerequisites

- Virtualization capable CPU
- Reasonable large amount of RAM and storage
- Ubuntu 18+

# Verify ability to run KVM

`
$ egrep -c "(svm|vmx)" /proc/cpuinfo
`

This should return a non-zero value, equal to the number of CPU cores exposed to your kernel.

```
$ sudo apt install cpu-checker
$ sudo kvm-ok
```

You should see output similar to this:
```
INFO: /dev/kvm exists
KVM acceleration can be used
```

# Install KVM related packages

`
$ sudo bash ./kvm-install.sh
`

## Add user to libvirt group
`
$ sudo adduser [username] libvirt
`

**IMPORTANT:** Logout of your machine and log back in.

## Verify Installation

`
$ virsh -c qemu:///system list
`

You should see output similar to the following:

```
 Id    Name                           State
----------------------------------------------------
```

Now set your storage dir variable for use later in this guide.

`$ export STORAGE_DIR="/var/lib/libvirt/images"`

# OPTIONAL: Modify image storage locations

The default location for virtual machine images is **/var/lib/libvirt/images**. On your machine, this may or may not be a desirable location for storing images, depending on how much disk space you have on that mount, the speed of the disk, etc. 

If you want to modify the default, follow the directions [linked here](http://ask.xmodulo.com/change-default-location-libvirt-vm-images.html).

`$ export STORAGE_DIR="<your image storage directory>"`

# Fix AppArmor to allow qcow2 overlay files

Edit the following file:
`$ sudo vi /etc/apparmor.d/libvirt/TEMPLATE.qemu`

Edit the file to have the following content:
```
#
# This profile is for the domain whose UUID matches this file.
#

#include <tunables/global>

profile LIBVIRT_TEMPLATE flags=(attach_disconnected) {
  #include <abstractions/libvirt-qemu>
  /storage/kubdev/vmimages/**.img rk,
}
```

In this case, make sure that the referenced directory is equal to ${STORAGE_DIR}

[Reference link](https://unix.stackexchange.com/questions/435837/how-to-configure-apparmor-so-that-kvm-can-start-guest-that-has-a-backing-file-ch) for why we have to do this.

`$ sudo service apparmor restart`

# Create virtual machines

`$ sudo STORAGE_DIR=${STORAGE_DIR} bash ./create-vms.sh`

Wait for a minute or two to make sure the machines have been properly initialized...

# Set static IP addresses properly

Using the running machines, we can now extract their MAC addresses in order to configure DHCP to assign static IP's.

```
$ bash reset-network.sh
$ bash ipsetup.sh
$ bash reset-network.sh
```

Now that the DHCP entries have been setup, let's restart the machines in order to pick up the IP assignments properly.
```
$ bash kill-vms.sh
$ bash start-vms.sh
```

# Log into virtual 

There are two ways to log into a VM. In both cases, the credentials are as follows:

**username**=ubuntu, **password**=testing123

## Console

You can login to any of the virtual machines using:

`$ virsh console [vm]`

To exit the console, use <kbd>ctrl</kbd> + <kbd>]</kbd>

## SSH

To do this you must know the IP address:

`$ ssh ubuntu@192.168.122.10`


