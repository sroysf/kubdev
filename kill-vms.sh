#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./cluster-config.sh

for machine in "${machines[@]}"
  do
  :   
  
  echo "Killing ${machine}"
  virsh destroy ${machine}

  done

virsh list --all