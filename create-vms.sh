#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./cluster-config.sh

if [[ -z ${STORAGE_DIR} ]]; then
    echo STORAGE_DIR variable must be defined
    exit 1
else
    echo "Using STORAGE_DIR : ${STORAGE_DIR}"
fi

BASE_IMAGE="bionic-server-cloudimg-amd64.img"

function prepare {
    rm -rf ./temp/
    mkdir -p ./temp/
}


function downloadBaseImage {
    if [[ ! -f "${STORAGE_DIR}/${BASE_IMAGE}" ]]; then
        echo "Downloading Ubuntu cloud image"
        wget https://cloud-images.ubuntu.com/bionic/current/${BASE_IMAGE} -O ${STORAGE_DIR}/${BASE_IMAGE}

        echo "Resizing cloud image to 30G virtual size"
        qemu-img resize ${STORAGE_DIR}/${BASE_IMAGE} 30G
    else
        echo "Using base image: ${STORAGE_DIR}/${BASE_IMAGE}"
    fi
    
    qemu-img info ${STORAGE_DIR}/${BASE_IMAGE}    
    echo ""
    echo ""
}

function createOverlayImage {
    local VM_NAME=$1
    cd ${STORAGE_DIR}

    if [[ ! -f "${VM_NAME}.ovl" ]]; then
        echo "Creating overlay image for ${VM_NAME}" 
        qemu-img create -f qcow2 -b ${BASE_IMAGE} -F qcow2 ${VM_NAME}.ovl
    fi

    echo "**************************************************"
    echo "${VM_NAME} using overlay file: ${VM_NAME}.ovl"
    qemu-img info ${VM_NAME}.ovl
    echo "**************************************************"

    cd -
}


function createiso {
    local VM_NAME=$1
    createOverlayImage ${VM_NAME}

    echo "Creating iso for ${VM_NAME}"
    cat <<EOT >> temp/${VM_NAME}-config.txt
#cloud-config
password: testing123
chpasswd: { expire: False }
ssh_pwauth: True
hostname: ${VM_NAME}
EOT

    cloud-localds ${STORAGE_DIR}/${VM_NAME}.iso temp/${VM_NAME}-config.txt
}

function installvm {    
    local VM_NAME=$1
    local MEMORY=$2

    if virsh list | grep ${VM_NAME}; then 
        echo "${VM_NAME} already exists. Use: 'virsh console ${VM_NAME}' to login"
        return
    fi

    createiso ${VM_NAME}

    virt-install \
            --name ${VM_NAME} \
            --memory ${MEMORY} \
            --disk ${STORAGE_DIR}/${VM_NAME}.ovl,device=disk,bus=virtio \
            --disk ${STORAGE_DIR}/${VM_NAME}.iso,device=cdrom \
            --filesystem source=${SCRIPT_DIR},target=/host,type=mount,mode=passthrough \
            --os-type linux \
            --os-variant ubuntu18.04 \
            --virt-type kvm \
            --graphics none \
            --network network=default,model=virtio \
            --import \
            --noautoconsole
}

prepare
downloadBaseImage

for machine in "${machines[@]}"
  do
  :   
  
  echo "Creating ${machine}"
  installvm ${machine} 2048

  done

echo "******************************"
virsh list --all