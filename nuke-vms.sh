#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./cluster-config.sh

if [[ -z ${STORAGE_DIR} ]]; then
    echo STORAGE_DIR variable must be defined
    exit 1
else
    echo "Using STORAGE_DIR : ${STORAGE_DIR}"
fi

function nukevm {
    VM_NAME=$1
    virsh destroy ${VM_NAME}
    virsh undefine ${VM_NAME}
    rm ${STORAGE_DIR}/${VM_NAME}.ovl
    rm ${STORAGE_DIR}/${VM_NAME}.iso
}

for machine in "${machines[@]}"
  do
  :   
  
  echo "Nuking ${machine}"
  nukevm ${machine}

  done