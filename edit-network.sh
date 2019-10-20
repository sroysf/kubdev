#!/bin/bash

virsh net-edit default
virsh net-destroy default
virsh net-start default