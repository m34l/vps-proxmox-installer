# Proxmox VPS Provisioning Script

This is a simple Bash script to provision a new VPS on a fresh Proxmox VE installation using a cloud image.

## Features

- Select OS template from predefined options (Ubuntu 24.04, Debian 12)
- Automatically downloads the image if not available
- Configures VM with Cloud-Init (user/password, IP, gateway, DNS)
- No SSH key injection
- Uses `qm` Proxmox CLI

## Requirements

- Proxmox VE installed
- Internet connection to download cloud images
- Template directory: `/var/lib/vz/template/qcow2/`
- Storage: `local-lvm`
- Network bridge: `vmbr0`

## Usage

Make the script executable:

```bash
chmod +x create-vps.sh
```

Run the script:

```bash
./create-vps.sh
```

Follow the prompts to:

- Select OS
- Define VM ID, hostname, CPU, RAM, disk
- Configure static IP, gateway, DNS
- Set VPS username and password

## Example Cloud Images Used

- **Ubuntu 24.04**: `https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img`
- **Debian 12**: `https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2`

## Notes

- You can add more OS options by extending the `case` block.
- Resulting VPS can be accessed from the Proxmox console using the username/password provided.

## License

MIT

Developed By Ismail Muhammad Zeindy