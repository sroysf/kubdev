#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./cluster-config.sh

for machine in "${machines[@]}"
  do
  :   

  echo "Starting ${machine}"
  virsh start ${machine}

  done

virsh list --all