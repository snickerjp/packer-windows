#!/bin/bash
# Build Windows Server 2022 with Docker for Proxmox
# 
# Prerequisites:
# 1. Install the Proxmox plugin for Packer:
#    packer plugins install github.com/hashicorp/proxmox
# 
# 2. Upload the Windows Server 2022 ISO to your Proxmox storage
# 3. Upload the VirtIO drivers ISO to your Proxmox storage
#    Download from: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
# 
# 4. Set environment variables or pass them as command-line arguments:
#    - PROXMOX_URL: Your Proxmox server URL (e.g., https://proxmox.example.com:8006/api2/json)
#    - PROXMOX_USERNAME: Your Proxmox username (e.g., root@pam)
#    - PROXMOX_PASSWORD: Your Proxmox password
#    - PROXMOX_NODE: The Proxmox node name (e.g., pve)
# 
# Example usage:
#   export PROXMOX_URL="https://proxmox.example.com:8006/api2/json"
#   export PROXMOX_USERNAME="root@pam"
#   export PROXMOX_PASSWORD="your_password"
#   export PROXMOX_NODE="pve"
#   ./build_windows_2022_docker_proxmox.sh
# 
# Or with command-line variables:
#   packer build \
#     -var "proxmox_url=https://proxmox.example.com:8006/api2/json" \
#     -var "proxmox_username=root@pam" \
#     -var "proxmox_password=your_password" \
#     -var "proxmox_node=pve" \
#     windows_2022_docker_proxmox.json

packer build \
  ${PROXMOX_URL:+-var "proxmox_url=${PROXMOX_URL}"} \
  ${PROXMOX_USERNAME:+-var "proxmox_username=${PROXMOX_USERNAME}"} \
  ${PROXMOX_PASSWORD:+-var "proxmox_password=${PROXMOX_PASSWORD}"} \
  ${PROXMOX_NODE:+-var "proxmox_node=${PROXMOX_NODE}"} \
  windows_2022_docker_proxmox.json
