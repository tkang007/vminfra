#!/bin/bash 
# tailscale network handling
# avahi mDSN only work in same subnetwork
#
# functions with global variables
#
source ./.local-env.sh 
source ./tailscale/tailscale-utils.sh

install_tailscales() {
  for i in $(seq 1 $VM_COUNT); do
    install_tailscale_if_notexist "${VM_PREFIX}$i" 
  done
}

up_tailscales() {
  for i in $(seq 1 $VM_COUNT); do
    up_tailscale_if_notup "${VM_PREFIX}$i" "${TAILSCALE_AUTH_KEY}"
  done
}

down_tailscales() {
  for i in $(seq 1 $VM_COUNT); do
    down_tailscale_if_up "${VM_PREFIX}$i" 
  done
}

remove_tailscales() {
  for i in $(seq 1 $VM_COUNT); do
    remove_tailscale_if_exist "${VM_PREFIX}$i" "${TAILSCALE_API_KEY}"
  done
}

list_tailscales() {
  tailscale status
}

ping_tailscales() {
  for i in $(seq 1 $VM_COUNT); do
    for j in $(seq 1 $VM_COUNT); do
      # tailscale ip/dn ping failed to itself. verify...
      if [ $i -eq $j ]; then continue; fi 
      ping_tailscale_between "${VM_PREFIX}$i" "${VM_PREFIX}$j" "$TAILSCALE_API_KEY"
    done
  done
}


hostfile_tailscales() {

  local tmpfile=$(mktemp)
  for i in $(seq 1 $VM_COUNT); do
    # set RETIPDNS
    get_tailscale_ipdns "${VM_PREFIX}$i" "$TAILSCALE_API_KEY"
    echo $RETIPDNS >> $tmpfile
  done
  
  log_info "# start of tailscale IP DNS"
  cat $tmpfile
  log_info "# end of tailscale IP DNS"
  rm -f "$tmpfile"
}

# main 
case "$1" in
  setup)
    install_tailscales 
    up_tailscales;;
  remove)
    #down_tailscales
    remove_tailscales;;
  list)
    list_tailscales;;
  ping)
    ping_tailscales;;    
  up)
    up_tailscales;;
  down)
    down_tailscales;;
  hostfile)
    hostfile_tailscales;;
  help)
    log_error "usage: $0 { help | setup | remove | list | ping | up | down | hostfile }";;
  *)
    log_error "Invalid usage; $0 help"     
esac

