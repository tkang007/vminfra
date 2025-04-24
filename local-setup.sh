#!/bin/env bash 

if [ ! -f ./.local-env.sh ]; then 
  log_error "Not found env file: ./.local-env.sh"
fi

log_info "source ./.local-env.sh"
source ./.local-env.sh 

# common packages 
log_info "apt-get update ..."
sudo apt-get clean; sudo apt-get update

if ! command -v ssh-keygen; then 
  log_info "openssh-client install ..."
  sudo apt install -y openssh-client
fi  

if ! command -v jq; then
  log_info "jq install ..."
  sudo apt-get install -y jq
fi

if ! command -v curl; then
  log_info "curl install ..."
  sudo apt-get install -y curl
fi

if ! command -v tailscale; then
  log_info "tailscale install ..."
  curl -fsSL https://tailscale.com/install.sh | sudo sh
fi

if ! tailscale status >/dev/null 2>&1 >/dev/null; then
  log_info "tailscale is not connected. Bringing it up..."
  sudo tailscale up --reset --auth-key=${TAILSCALE_AUTH_KEY} --hostname "${VM_WSL}"
fi
log_info "tailscale tatus"
sudo tailscale status

# for ansible
if ! command -v ansible; then
  log_info "ansible install ..."
  sudo apt-get install -y ansible
  # for ssh key handle at playbook
  sudo ansible-galaxy collection install community.crypto
fi

if [ ! -f "$SSHKEY_PATH" ]; then 
  log_info "ssh keygen ${SSHKEY_PATH} ..."
  ssh-keygen -t rsa -b 4096 -f ${SSHKEY_PATH} -N '' -q
else  
  log_info "ssh key already exist ${SSHKEY_PATH}"  
fi

