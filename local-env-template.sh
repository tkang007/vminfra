# 
# set shell environment variables
# 
# please update with your credential and intension 
# please souce this script before using other script.
# usage: $ source ./this.sh
#  or $ set -a; source ./this.sh; set +a

#
# ssh key file 
#
SSHKEY_PATH="$HOME/.ssh/id_rsa"

#
# Multipass environment.
#
# Enable alias expansion in this script
shopt -s expand_aliases  
# multipass alias for using Windows hosted VMs. 
alias multipass='/mnt/c/Program\ Files/Multipass/bin/multipass.exe'

#
# VMs environment.
#
VM_WSL="$(hostname)-wsl" # multiscale machine name of WSL
VM_IMAGE="22.04"  # multipass image version. 24.04 not fit with k8s
VM_PREFIX="mt-"   # vm instance hostname prefix
VM_COUNT=3        # vm instance count
CPUS="2"          # vm instance cpus  
MEM="2G"          # vm instance memory
DISK="10G"        # vm instance disk

#
# Tailscale environment. Please update 
#
TAILSCALE_TAILNET="xxx@zzz.com" 
TAILSCALE_AUTH_KEY="tskey-auth-xxx"
TAILSCALE_API_KEY="tskey-api-xxx"
#

# ansible config, no prompot and error for recreated instance
ANSIBLE_HOST_KEY_CHECKING=False

#
# common functions
#
function log_info() {
  local ARGS="$@";  echo "[INFO] ${ARGS:0:100}" >&2
}
function log_warn() {
  local ARGS="$@"; echo "[WARN] ${ARGS:0:100}" >&2
}
function log_error() {
  local ARGS="$@"; echo "[ERROR] ${ARGS:0:100}" >&2
  exit 1
}

function multipass_exec() {
  local NAME="$1"
  local SHCMD="$2"

  log_info "exec on $NAME : $SHCMD"
  multipass exec "$NAME" -- bash -c "$SHCMD" 
  if [ $? -ne 0 ]; then
    log_error "fail on $NAME : $SHCMD" 
  fi  
  log_info "done on $NAME : $SHCMD" 
}

