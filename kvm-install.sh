#!/bin/bash

echo "Installing KVM required packages"

apt install -y qemu-kvm libvirt-bin bridge-utils virt-manager cloud-image-utils virtinst

