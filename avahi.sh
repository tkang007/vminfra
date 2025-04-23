#!/bin/bash
# avahi mDSN(multicast DSN) network handling
# avahi does not work between WSL and multipass VM
# tailscale work beween WSL and multipass VM

# NOTE: initial try failed when ping between instances
# ping: mt-2.local: Temporary failure in name resolution
# => a little complex to resolve. use tailscale.

source ./.local-env.sh 
source ./avahi/avahi-utils.sh

setup_avahi_instances() {
  for i in $(seq 1 $VM_COUNT); do
    setup_avahi_if_notexist "${VM_PREFIX}$i" 
  done
}

status_avahi_instances() {
  for i in $(seq 1 $VM_COUNT); do
    status_avahi_if_exist "${VM_PREFIX}$i" 
  done
}

test_avahi_instances() {
  for i in $(seq 1 $VM_COUNT); do
    test_avahi_if_exist "${VM_PREFIX}$i" 
  done
}

ping_avahi_pair() {
  for i in $(seq 1 $VM_COUNT); do
    for j in $(seq 1 $VM_COUNT); do
      if [ $i -eq $j ]; then continue; fi 
      ping_avahi_between "${VM_PREFIX}$i" "${VM_PREFIX}$j" 
    done
  done
}

# main 

case "$1" in
  setup)
    setup_avahi_instances;;
  status)
    status_avahi_instances;;
  test)
    test_avahi_instances;;
  ping)
    ping_avahi_pair;;    
  *)
    log_warn "Invalid usage" 
    log_error "usage: $0 { setup | status | test | ping }"
esac
