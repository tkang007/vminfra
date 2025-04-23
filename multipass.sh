#!/bin/bash 
# multipass vm handling
#
# functions with global variables
#
source ./.local-env.sh 
source ./multipass/multipass-utils.sh

launch_multipass_instances() {
  for i in $(seq 1 $VM_COUNT); do
    launch_multipass_instance_if_notexist "${VM_PREFIX}$i" "$CPUS" "$MEM" "$DISK"
  done
}

delete_multipass_instances() {
  for i in $(seq 1 $VM_COUNT); do
    delete_multipass_instance_if_exist "${VM_PREFIX}$i" 
  done
}

list_multipass_instances() {
  multipass list 
}

status_multipass_instances() {
  for i in $(seq 1 $VM_COUNT); do
    status_multipass_instance_if_exist "${VM_PREFIX}$i" 
  done
}

start_multipass_instances() {
  for i in $(seq 1 $VM_COUNT); do
    multipass start "${VM_PREFIX}$i" 
  done
}

stop_multipass_instances() {
  for i in $(seq 1 $VM_COUNT); do
    multipass stop "${VM_PREFIX}$i" 
  done
}

# main 

case "$1" in
  launch)
    launch_multipass_instances;;
  delete)
    delete_multipass_instances
    bash ./tailscale.sh remove || true ;; 
  list)
    list_multipass_instances;;    
  status)
    status_multipass_instances;;
  start)
    start_multipass_instances;;
  stop)
    stop_multipass_instances;;
  help)
    log_info "usage: $0 { help | launch | delete | list | status | start | stop }"
  *)
    log_error "Invalid usage; $0 help"     
esac

