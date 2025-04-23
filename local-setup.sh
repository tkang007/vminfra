#!/bin/env bash 

# common packages 
echo "apt-get update ..."
sudo apt-get update

if [ ! -f ./.local-env.sh ]; then 
  echo "Not found env file: ./.local-env.sh"
  exit 1
fi
echo "source ./.local-env.sh"
source ./.local-env.sh 

if ! command -v jq; then
  echo "jq install ..."
  sudo apt-get install -y jq
fi

if ! command -v curl; then
  echo "curl install ..."
  sudo apt-get install -y curl
fi

if ! command -v tailscale; then
  echo "tailscale install ..."
  curl -fsSL https://tailscale.com/install.sh | sudo sh
fi

if ! tailscale status >/dev/null 2>&1; then
  echo "tailscale is not connected. Bringing it up..."
  sudo tailscale up --reset --auth-key=${TAILSCALE_AUTH_KEY}
else
  echo "tailscale is already connected."
  sudo tailscale ip -4

  echo "tailscale tatus"
  sudo tailscale status
fi
