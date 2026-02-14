# Ansible Kubernetes HA Deployment

This project contains Ansible playbooks and roles for deploying a High Availability (HA) Kubernetes cluster on AWS.

## Architecture
- **Control Plane**: 3 Master Nodes behind a Network Load Balancer (NLB).
- **Worker Nodes**: 3 Worker Nodes.
- **Runtime**: containerd with CRI plugin enabled.
- **Network**: Calico CNI.

## Project Structure
- `inventory/`: Contains the host inventory and global variables.
- `roles/`:
  - `cleanup`: Resets existing cluster state and cleans up conflicting APT repositories.
  - `common`: OS-level prerequisites (swap, kernel modules, dependencies).
  - `container_runtime`: Installs and configures containerd.
  - `kubernetes`: Installs kubeadm, kubelet, and kubectl.
  - `master`: Initializes the primary master and joins secondary masters to the control plane.
  - `worker`: Joins worker nodes to the cluster.

## Getting Started

### 1. Prerequisites
- EC2 instances (or VMs) for the control plane and workers.
- SSH access to the instances with sudo privileges.
- Your SSH private key available locally.

### 2. Configure Inventory
Update `inventory/hosts.ini` with the IP addresses of your instances:
```ini
[masters]
master1 ansible_host=<master-ip-1>
master2 ansible_host=<master-ip-2>
master3 ansible_host=<master-ip-3>

[workers]
worker1 ansible_host=<worker-ip-1>
...
```

### 3. Run the Playbook
To deploy the entire cluster:
```bash
ansible-playbook -i inventory/hosts.ini site.yml
```

### 4. Verify the Cluster
Copy the generated `admin.conf` from the primary master to your local `~/.kube/config`:
```bash
scp -i <your-key>.pem ubuntu@<master-ip-1>:/etc/kubernetes/admin.conf ./admin.config
kubectl get pods -A --kubeconfig=./admin.config
```

## Troubleshooting
- **Stale SSH Sockets**: If the playbook hangs on "Gathering Facts", run:
  ```bash
  rm -rf ~/.ansible/cp/*
  ```
- **Control Plane Endpoint**: Ensure the `control_plane_endpoint` in `inventory/group_vars/all.yml` matches your current Load Balancer DNS name.
