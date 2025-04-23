#!/bin/bash

# install tailscale if not exist
install_tailscale_if_notexist() { 
  local NAME="$1"
  
  if [ -z "$NAME" ]; then 
    log_error "Usage: ${FUNCNAME[0]} <vm-name>"
  fi

  multipass exec "$NAME" -- bash -c "command -v tailscale"
  if [ $? -eq 0 ]; then 
    log_info "${FUNCNAME[0]}: tailscale already installed"
    return 0
  fi

  log_info "${FUNCNAME[0]}: install tailscale on '$NAME' ..."
  multipass_exec "$NAME" "curl -fsSL https://tailscale.com/install.sh | sudo sh"
  log_info "${FUNCNAME[0]}: installed tailscale on '$NAME'"
}

# up tailscale 
up_tailscale_if_notup() { 
  local NAME="$1"
  local AUTH_KEY="$2"

  if [ -z "$AUTH_KEY" ]; then 
    log_error "Usage: ${FUNCNAME[0]} <vm-name> <auth-key>"
  fi
  
  multipass exec "$NAME" -- bash -c "sudo tailscale status | grep -q '100\\.'" 
  if [ $? -eq 0 ]; then
    log_info "${FUNCNAME[0]}: tailscale already up on '$NAME'" 
    return 0
  fi 
     
  multipass_exec "$NAME" "sudo tailscale up --reset --authkey=$AUTH_KEY --hostname=$NAME"
  log_info "${FUNCNAME[0]}: tailscale up on '$NAME'" 
}


# down tailscale 
down_tailscale_if_up() { 
  local NAME="$1"
  
  if [ -z "$NAME" ]; then 
    log_error "Usage: ${FUNCNAME[0]} <vm-name>"
  fi
  
  multipass exec "$NAME" -- bash -c "sudo tailscale status | grep -q '100\\.'" 
  if [ $? -ne 0 ]; then
    log_info "${FUNCNAME[0]}: tailscale already down on '$NAME'" 
    return 0
  fi 
     
  multipass_exec "$NAME" "sudo tailscale down"
  log_info "${FUNCNAME[0]}: tailscale down on '$NAME'" 
}

# remove a tailscale instance in the Tailscale control plane
remove_tailscale_if_exist() {
  local NAME="$1"
  local API_KEY="$2"

  if [ -z "$API_KEY" ]; then
    log_error "Usage: ${FUNCNAME[0]} <vm-name> <api_key>"
  fi

  log_info "${FUNCNAME[0]}: searching device for '$NAME' at tailscale site"
  DEVICEID=$(curl -s -H "Authorization: Bearer $API_KEY" \
    "https://api.tailscale.com/api/v2/tailnet/${TAILNET}/devices" \
    | jq -r ".devices[] | select(.hostname == \"$NAME\") | .id")
  
  if [ -z "$DEVICEID" ]; then
    echo "${FUNCNAME[0]}: not found device for '$NAME'"
    return 0
  fi

  log_info "${FUNCNAME[0]}: delete device ID: $DEVICEID for '$NAME'"
  curl -s -X DELETE \
    -H "Authorization: Bearer $API_KEY" \
    "https://api.tailscale.com/api/v2/device/$DEVICEID"
  if [ $? -ne 0 ]; then 
    log_warn "${FUNCNAME[0]}: delete fail for '$NAME'"
  else
    log_info "${FUNCNAME[0]}: delete done for '$NAME'"
  fi
}


function get_tailscale_ipdns() {
  # return by echo for string
  local NAME="$1"
  local API_KEY="$2"

  if [ -z "$API_KEY" ]; then
    log_error "Uage: ${FUNCNAME[0]} <vm-name1> <api-key>"
  fi

  local IPDNS
  IPDNS=$(tailscale status --json | \
          jq -r ".Peer[] | select(.HostName == \"${NAME}\") | \
                \"\(.TailscaleIPs[0]) \(.DNSName)\"")
  if [ -z "$IPDNS" ]; then 
    log_warn "${FUNCNAME[0]}: IP and DNS not found for '$NAME'"
    echo ""
  fi
  log_info "${FUNCNAME[0]}: IP and DNS for '$NAME': $IPDNS"
  echo "$IPDNS"
}


ping_tailscale_between() {
  local SRCNAME="$1"
  local DSTNAME="$2"
  local API_KEY="$3"

  if [ -z "$API_KEY" ]; then
    log_error "Uage: ${FUNCNAME[0]} <vm-name1> <api-key>"
  fi

  local SRCIPDNS=$(get_tailscale_ipdns "$SRCNAME" "$API_KEY")
  if [ -z "$SRCIPDNS" ]; then
    log_warn "${FUNCNAME[0]}: fail for '$SRCNAME'"
    return 1
  fi 
  local SRCDNS=$(echo "$SRCIPDNS" | awk '{print $2}')
  
  local DSTIPDNS=$(get_tailscale_ipdns "$DSTNAME" "$API_KEY")
  if [ -z  "$SRCIPDNS" ]; then
    log_warn "${FUNCNAME[0]}: fail for '$SRCNAME'"
    return 1
  fi 
  local DSTDNS=$(echo "$DSTIPDNS" | awk '{print $2}')

  log_info "ping '$SRCDNS' => '$DSTDNS'"
  multipass_exec "$SRCNAME" "ping -c 1 ${DSTDNS}"
  if [ $? -ne 0 ]; then 
    log_warn "${FUNCNAME[0]}: ping fail '$SRCDNS' => '$DSTDNS'"
    return 1
  else
    log_info "${FUNCNAME[0]}: ping done '$SRCDNS' => '$DSTDNS'"
  fi
}
