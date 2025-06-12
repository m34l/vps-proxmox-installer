#!/bin/bash

set -e

# Function to download image if not exists
download_image() {
  local filename="$1"
  local url="$2"
  local target="/var/lib/vz/template/qcow2/$filename"

  if [ -f "$target" ]; then
    echo "Image $filename already exists."
  else
    echo "Downloading $filename..."
    wget -O "$target" "$url"
  fi
}

# OS selection
echo "Select OS Template:"
echo "1. Ubuntu 24.04"
echo "2. Debian 12"
read -p "Choice [1-2]: " OS_CHOICE

case "$OS_CHOICE" in
  1)
    IMAGE_NAME="ubuntu-24.04-cloudimg-amd64.img"
    IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
    ;;
  2)
    IMAGE_NAME="debian-12-genericcloud-amd64.qcow2"
    IMAGE_URL="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
    ;;
  *)
    echo "Invalid selection."
    exit 1
    ;;
esac

download_image "$IMAGE_NAME" "$IMAGE_URL"

# VPS configuration input
read -p "VM ID (e.g. 101): " VMID
read -p "VM Name (hostname): " VMNAME
read -p "CPU cores: " CPU
read -p "Memory (MB): " RAM
read -p "Disk size (GB): " DISK
read -p "Username for VPS: " CIUSER
read -p "Password for user $CIUSER: " CIPASS
read -p "Static IP (e.g. 192.168.10.100/24): " IPADDR
read -p "Gateway (e.g. 192.168.10.1): " GATEWAY
read -p "DNS (default 8.8.8.8): " DNS
DNS=${DNS:-8.8.8.8}

# Proxmox settings
STORAGE="local-lvm"
BRIDGE="vmbr0"
OS_PATH="/var/lib/vz/template/qcow2/$IMAGE_NAME"

# Create VM
qm create "$VMID" \
  --name "$VMNAME" \
  --memory "$RAM" \
  --cores "$CPU" \
  --net0 virtio,bridge="$BRIDGE" \
  --ide2 "$STORAGE":cloudinit \
  --boot order=scsi0 \
  --scsihw virtio-scsi-pci \
  --serial0 socket \
  --vga serial0

# Import OS image
qm importdisk "$VMID" "$OS_PATH" "$STORAGE"
qm set "$VMID" --scsi0 "$STORAGE:vm-$VMID-disk-0"

# Cloud-init configuration
qm set "$VMID" --ciuser "$CIUSER" --cipassword "$CIPASS"
qm set "$VMID" --ipconfig0 "ip=$IPADDR,gw=$GATEWAY"
qm set "$VMID" --nameserver "$DNS"

# Resize disk
qm resize "$VMID" scsi0 "${DISK}G"

# Start VM
qm start "$VMID"

echo "VPS '$VMNAME' (VMID: $VMID) created and started successfully."
