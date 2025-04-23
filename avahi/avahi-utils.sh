#!/bin/bash

function setup_avahi_if_notexist() {
  local NAME="$1"

  if [ -z "$NAME" ]; then 
    log_error "Usage: ${FUNCNAME[0]} <vm-name>"
  fi

  multipass exec "$NAME" -- bash -c "command -v avahi-browse"
  if [ $? -eq 0 ]; then 
    log_info "${FUNCNAME[0]}: avahi already installed"
    return 0
  fi

  # install
  multipass_exec "$NAME" "sudo apt install -y avahi-daemon avahi-utils libnss-mdns"
  
  # service enable
  multipass_exec "$NAME" "sudo systemctl enable avahi-daemon"

  # service start
  multipass_exec "$NAME" "sudo systemctl start avahi-daemon"
}

function status_avahi_if_exist() {
  local NAME="$1"

  if [ -z "$NAME" ]; then 
    log_error "Usage: ${FUNCNAME[0]} <vm-name>"
  fi

  multipass exec "$NAME" -- bash -c "command -v avahi-browse"
  if [ $? -ne 0 ]; then 
    log_info "${FUNCNAME[0]}: avahi not installed"
    return 0
  fi

  multipass_exec "$NAME" "sudo systemctl status avahi-daemon --no-pager"
}

function test_avahi_if_exist() {
  local NAME="$1"

  if [ -z "$NAME" ]; then 
    log_error "Usage: ${FUNCNAME[0]} <vm-name>"
  fi

  multipass exec "$NAME" -- bash -c "command -v avahi-browse"
  if [ $? -ne 0 ]; then 
    log_info "${FUNCNAME[0]}: avahi not installed"
    return 0
  fi

  #multipass_exec "$NAME" "avahi-browse -a"
  multipass_exec "$NAME" "ping -c 1 ${NAME}.local"
  log_info "${FUNCNAME[0]}: ping test done for '${NAME}.local'"
}


function ping_avahi_between() {
  local SRCNAME="$1"
  local DSTNAME="$2"

  if [ -z "$DSTNAME" ]; then 
    log_error "Usage: ${FUNCNAME[0]} <vm-name1> <vm-name1>"
  fi

  multipass_exec "$SRCNAME" "ping -c 1 ${DSTNAME}.local"
  log_info "${FUNCNAME[0]}: ping test done from '${SRCNAME}.local' -> '${DSTNAME}.local"
}

