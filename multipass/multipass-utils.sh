#!/bin/bash 

#
# local function without referencing global variables
#

# Launch a multipass instance if it does not exist. 
launch_multipass_instance_if_notexist() {
  local NAME="$1"
  local CPUS="${2:-2}"
  local MEM="${3:-2G}"
  local DISK="${4:-10G}"

  if [ -z "$NAME" ]; then
    log_error "Usage: ${FUNCNAME[0]} <vm-name> [<cpus> <memsize> <disksize>]"
  fi

  if ! command -v multipass >/dev/null >/dev/null 2>&1; then
    log_error "${FUNCNAME[0]}: multipass CLI not available."
  fi

  if multipass info "$NAME" &>/dev/null; then
    echo "${FUNCNAME[0]}: instance '$NAME' already exists."
    return 0
  fi 
  
  log_info "${FUNCNAME[0]}: launch for '$NAME' ..."
  multipass launch --name "$NAME" --cpus "$CPUS" --memory "$MEM" --disk "$DISK"
  if [ $? -ne 0 ]; then 
    log_error "${FUNCNAME[0]}: launch fail for '$NAME'"
  else
    log_info "${FUNCNAME[0]}: launch done for '$NAME'"
  fi

  # set hostname explitely for mDNS, avahi
  log_info "${FUNCNAME[0]}: set-hostname for '$NAME' ..."
  multipass_exec "${NAME}" "sudo hostnamectl set-hostname ${NAME}"
  log_info "${FUNCNAME[0]}: set-hostname done for '$NAME'"

  log_info "${FUNCNAME[0]}: apt-get update for '$NAME' ..."
  multipass_exec "$NAME" "sudo apt-get clean; sudo apt-get update "
  log_info "${FUNCNAME[0]}: apt update done for '$NAME'"
}

# Delete a multipass instance if it is exist
delete_multipass_instance_if_exist() {
  local NAME=$1

  if [ -z "$NAME" ]; then
    log_error "Usage: ${FUNCNAME[0]} <vm-name>"
  fi

  if ! multipass info "$NAME" >/dev/null 2>&1; then
    log_info "${FUNCNAME[0]}: not exist instance '$NAME'"
    return 0 
  fi
  
  log_info "${FUNCNAME[0]}: delete and purge for '$NAME' ..."
  multipass delete "$NAME" --purge
  if [ $? -ne 0 ]; then 
    log_error "${FUNCNAME[0]}: delete or purge fail for '$NAME'"
  else
    log_info "${FUNCNAME[0]}: delete and purge done for '$NAME'"
  fi
}

# Status of a multipass instance if it is exist
status_multipass_instance_if_exist() {
  local NAME=$1

  if [ -z "$NAME" ]; then
    log_error "Usage: ${FUNCNAME[0]} <vm-name>"
  fi

  log_info "${FUNCNAME[0]}: info for '$NAME' ..."
  multipass info $NAME 
  if [ $? -ne 0 ]; then 
    log_warn "${FUNCNAME[0]}: info fail for '$NAME'"
  else
    log_info "${FUNCNAME[0]} info done for '$NAME'"
  fi
}
