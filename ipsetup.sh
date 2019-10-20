#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./cluster-config.sh

function resetNetwork {
    virsh net-destroy default
    virsh net-start default
    virsh net-dumpxml default
}

function editNetwork {
    virsh net-edit default
    echo "Removing any pre-existing DHCP leases from libvirt"
    sudo rm /var/lib/libvirt/dnsmasq/virbr0.*
    resetNetwork
}

function getMacAddress {
    machine=$1
    ip=$2

    macAddress=$(virsh dumpxml ${machine} | xmllint --xpath "string(/domain/devices/interface/mac/@address)" -)
    echo "Setting DHCP ${machine} ==> IP 192.168.122.${ip}"
    virsh net-update default add ip-dhcp-host \
          "<host name='${machine}' ip='192.168.122.${ip}' mac='${macAddress}'/>" \
           --live --config
}

function setupDHCP {
    i=10
    for machine in "${machines[@]}"
    do
    :   
    getMacAddress ${machine} ${i}
    ((i++))
    done
}

echo "If existing DHCP entries exist, please remove them in this next step. <RETURN> to continue"
read
editNetwork
setupDHCP
resetNetwork