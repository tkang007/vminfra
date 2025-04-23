# Multilple VMs in Windows using Multipass and Tailscale

Windows hosted multiple VMs with stable IP and FQDN.

## Purpose 
Simple way to prepare multiple VMs in Windows with stable IP and FQDN for various VM based solutions.  

## Usage cases
These are only a few usage cases with multiple VMs.
- Easier alternatives of WSL2 or VirtualBox.
- HA or replication nodes for RDBMS: PostgreSQL, MySQL
- Distributed DBMS, Cache and Messaging: Ignite, NATS, Redis
- Distributed file or object storage: Gluster, Gluster, Ceph, Minio
- Cluster for Podman, Docker Swarm, Nomad, Kubernetes,K3S, Mickok8s
- Cluster for etc, consul, ...

Note: 
- 'podman machine' only support 1 VM in a host.
  

### Step 0 - Setup Windows system
- Windows Terminal installation 
- VSCode installation
- Multipass installation
- Tailscale installation
- Tailscale auth-key (reusable), api-key and MagicDNS
- Hyper-V enable for WSL2 and multipass
- WSL2 Ubuntu instance for bash, Windows hosted Multipass
- Working directory at Windows
```cmd
mkdir C:\Proinfra
cd C:\Proinfra
```
  
### Step 1 - Setup WSL Ubuntu work environment  
- login to WSL2 ubuntu and install git
``` 
wsl -d Ubuntu-24.04  
sudo apt-get update
sudo apt-get install -y git curl jq 
```

- checkout this github repo
```
git clone https://github.com/tkang007/vminfra.git

cd ./vminfra
```

- create .local-env.sh file by reference local-env-template.sh 
```
cp local-env-template.sh .local-env.sh
```

- Edit .local-env.sh file by using VScode 
  - multipass alias with Windows installed multipass for Windows hosted VM
  - tailscale credentials
  - VM hostname prefix and instance count  
```
code .
``` 
  
- Confirm scripts
  - local-setup.sh : setup work environment in WSL. 
```
./local-setup.sh 
```

### Step 2 - Setup multipass VM instances
- confirm scripts
  - multipass.sh : launch and manage multipass instances
  - usage: ./multipass.sh { help | launch | delete | list | status | start | stop }
```
./multipass.sh help
./multipass.sh launch 
```

### Step 3 - Setup tailscale network in VM instances
- confirm scripts
  - tailscale.sh : setup and manage tailscale network
  - usage: ./tailscale.sh { setup | remove | list | ping | up | down | help }
```
./tailscale.sh help
./tailscale.sh setup
```

### Step 4 - Using VM intance
- connect to a VM instance (multipass own ssh key) 
```
multipass shell <vm-name>  
multipass exec <vm-name>  -- whoami
```

- stop all VM instance
```
./multipass.sh stop
```

- start all VM instance
```
./multipass.sh start
```

- reset tailscale when tailscale auth-key expired
```
./tailscale.sh down
./tailscale.sh up 
```

### Step 4 - Delete VM instances and remove tailscale 
- Delete all VM instances and remove tailscale network
```
./multipass.sh delete 
./tailscale.sh remove
```

### Reference: Solutions for VM in Windows
-  Multipass (Canonical) — Lightweight and Tailscale-friendly
  - Creates Ubuntu VMs quickly
  - Each VM is isolated and runs in Hyper-V or VirtualBox
  - Works great with Tailscale in each VM

- podman machine 
  - Create minimal Fedora-based virtual machine, called Fedora CoreOS.
  - Only 1 VM in a host
  - A shared networking layer (gvproxy) that doesn't support isolated multi-VM environments easily
  
- WSL2 + systemd — Lightweight, but trickier for networking
  - You can create multiple WSL2 distributions (e.g., Ubuntu-1, Ubuntu-2)
  - Tailscale now works inside WSL2 (with systemd-enabled distros)
  - You can assign different IPs and run tailscale up in each
  - Some caveats: WSL2 networking can be weird, and multicast/broadcast isn't reliable. But for many use cases, it works fine.

- VirtualBox or VMware + Linux ISO — Full control, but heavier
Create VMs manually
  - Install Tailscale inside each one
  - Useful for more complex networking needs or emulating full systems

- Docker Desktop + Tailscale Sidecar (advanced)
  - Not a real VM, but you can run containers with Tailscale sidecars
  - Lightweight and fast
  - Useful for microservice-style development

### Reference: Solutions for Network 
- avihi : mDNS solution
  - initial try was not success when ping between instances

- headscale : similar with tailscale
  - will try later
