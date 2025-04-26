# Multilple VMs in Windows using Multipass and Tailscale

Windows hosted multiple VMs with stable IP and FQDN.

## Purpose 
Simple way to prepare multiple VMs in Windows with stable IP and FQDN for various VM based solutions.  

## Usage to experiment cluster solutions 
These are only a few cases based on multiple VMs.
- Easier alternative of WSL2 or VirtualBox.
- SDS (Software Defined Storage) 
  - DRBD(Ditributed Replication Block Device) 
  - Ceph: cluster of Block, File, Object storage
  - GlusterFS: cluster of File storage 
  - Minio: cluster of Object storage
- HA (High Availability) 
  - ClusterLab Stack : Pacemaker, Corosync, Fencing, Resource Agents
  - Keeplived
- LB (Load Balancer) 
  - HAProxy, Nginx, Traefik, Envoy, MetalLB
  - Keeplived
- DBMS replications, sharding, connection pool
  - PostgreSQL replicaiton: Async/Sync/Quorum/Logical/Physical Replication
  - PostgreSQL conn. pool and/or load balancer: pgBouncer, pgPool-II
  - MySQL replcation: Async/Semi-synch/Group/Multi-Source replication 
  - MySQL conn. pool and/ load balancer: ProxySQL, MaxScale
  - Mongodb: sharding, replica set (HA)
- Distributed Caching and Messaging: Ignite, NATS, Redis
- Container solution with Podman, Docker Swarm, Nomad, Kubernetes,K3S, Mickok8s
- Classic application HA with podman + systemd
  

### Step 0 - Setup Windows system
- Windows Terminal
- VSCode installation
- Multipass installation
- Tailscale installation
- Tailscale auth-key (reusable), api-key and MagicDNS enabling
- Hyper-V enabled for WSL2 and multipass
- WSL2 Ubuntu instance for bash, Windows hosted Multipass
- Working directory at Windows
```cmd
mkdir C:\Proinfra
cd C:\Proinfra
```
  
### Step 1 - Setup WSL Ubuntu work environment  
- login to WSL2 ubuntu and install git
``` 
wsl -d Ubuntu-22.04  
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
  - usage: ./tailscale.sh { help | setup | remove | list | ping | up | down | hostfile }
```
./tailscale.sh help
./tailscale.sh setup
```

### Step 4 - Using VM intance
- connect to a VM instance (multipass managed ssh key) 
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

### Known issue
- ping to tailscale ip/dns oneself failed,even though succeed when ping to others 
  - manual fix in instance iptables by reference, tailscale-ping-oneself-case.txt file.

### Reference: Solutions for VM in Windows
-  Multipass (Canonical) — Lightweight and Tailscale-friendly
  - Creates Ubuntu VMs quickly
  - Each VM is isolated and runs in Hyper-V or VirtualBox
  - Works great with Tailscale in each VM

- podman machine 
  - Create minimal Fedora-based virtual machine, called Fedora CoreOS.
  - 'podman machine' only support 1 VM in a host.
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
