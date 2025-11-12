# Windows Server 2025 with Docker for Proxmox

This configuration builds a Windows Server 2025 virtual machine template with Docker installed for Proxmox VE.

## Prerequisites

### 1. Install Packer Proxmox Plugin

The Proxmox builder requires the official Proxmox plugin for Packer. Install it using:

```bash
packer plugins install github.com/hashicorp/proxmox
```

### 2. Upload Required ISOs to Proxmox

You need to upload the following ISO files to your Proxmox storage:

#### Windows Server 2025 ISO
- Download from: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2025
- Upload to your Proxmox storage (e.g., `local` storage)
- Default expected path: `local:iso/26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso`

#### VirtIO Drivers ISO
- Download from: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
- Upload to your Proxmox storage
- Default expected path: `local:iso/virtio-win.iso`

### 3. Configure Proxmox Connection

Set the following environment variables or pass them as command-line arguments:

- `PROXMOX_URL`: Your Proxmox server URL (e.g., `https://proxmox.example.com:8006/api2/json`)
- `PROXMOX_USERNAME`: Your Proxmox username (e.g., `root@pam`)
- `PROXMOX_PASSWORD`: Your Proxmox password
- `PROXMOX_NODE`: The Proxmox node name (e.g., `pve`)

## Configuration Variables

The `windows_2025_docker_proxmox.json` file includes the following Proxmox-specific variables that can be customized:

| Variable | Default | Description |
|----------|---------|-------------|
| `proxmox_url` | `https://proxmox.example.com:8006/api2/json` | Proxmox API URL |
| `proxmox_username` | `root@pam` | Proxmox username |
| `proxmox_password` | `your_proxmox_password` | Proxmox password |
| `proxmox_node` | `pve` | Proxmox node name |
| `proxmox_vm_id` | `9000` | VM ID for the template |
| `proxmox_iso_file` | `local:iso/26100...iso` | Windows ISO location in Proxmox |
| `proxmox_iso_storage_pool` | `local` | Storage pool for ISO files |
| `proxmox_virtio_iso_file` | `local:iso/virtio-win.iso` | VirtIO drivers ISO location |
| `proxmox_storage_pool` | `local-lvm` | Storage pool for VM disk |
| `proxmox_storage_pool_type` | `lvm` | Storage pool type |
| `proxmox_network_bridge` | `vmbr0` | Network bridge to use |
| `template_name` | `windows-server-2025-docker` | Template name |

## Building the Template

### Using the Build Script

```bash
# Set environment variables
export PROXMOX_URL="https://proxmox.example.com:8006/api2/json"
export PROXMOX_USERNAME="root@pam"
export PROXMOX_PASSWORD="your_password"
export PROXMOX_NODE="pve"

# Run the build script
./build_windows_2025_docker_proxmox.sh
```

### Using Packer Directly

```bash
packer build \
  -var "proxmox_url=https://proxmox.example.com:8006/api2/json" \
  -var "proxmox_username=root@pam" \
  -var "proxmox_password=your_password" \
  -var "proxmox_node=pve" \
  -var "proxmox_iso_file=local:iso/your-windows-iso.iso" \
  -var "proxmox_storage_pool=local-lvm" \
  windows_2025_docker_proxmox.json
```

### Customizing Storage and Network

If your Proxmox setup uses different storage pools or network bridges, you can override them:

```bash
packer build \
  -var "proxmox_url=https://proxmox.example.com:8006/api2/json" \
  -var "proxmox_username=root@pam" \
  -var "proxmox_password=your_password" \
  -var "proxmox_node=pve" \
  -var "proxmox_storage_pool=my-storage" \
  -var "proxmox_storage_pool_type=lvm-thin" \
  -var "proxmox_network_bridge=vmbr1" \
  windows_2025_docker_proxmox.json
```

## What Gets Installed

This template includes:

- Windows Server 2025 Core (no GUI)
- Docker Engine Community Edition (version 27.5.1 by default)
- Pre-pulled Docker images:
  - `mcr.microsoft.com/windows/nanoserver:ltsc2025`
  - `mcr.microsoft.com/windows/servercore:ltsc2025`
- VirtIO drivers for optimal performance
- WinRM enabled for remote management
- Windows Updates applied (can be disabled for faster builds)

## Template Usage

After the build completes, a VM template will be created in Proxmox with the name specified in `template_name` variable. You can:

1. Clone this template to create new VMs
2. Use it with Terraform's Proxmox provider
3. Use it with Ansible for automated deployments

## Differences from Other Builders

Unlike the other builders (VMware, VirtualBox, etc.) that use floppy disks for the `Autounattend.xml` file, the Proxmox builder uses an additional CD-ROM with the `cd_files` option. This is because Proxmox doesn't support virtual floppy disks.

The provisioners and post-processors remain the same as the original `windows_2025_docker.json` configuration, ensuring consistent results across different platforms.

## Troubleshooting

### Plugin Not Found

If you get an error about the `proxmox-iso` builder being unknown:

```bash
packer plugins install github.com/hashicorp/proxmox
```

### ISO Not Found

Ensure your ISO files are uploaded to Proxmox storage and the paths in the variables match. You can verify ISO paths in the Proxmox web interface under: Datacenter → Storage → [Your Storage] → Content.

### Connection Issues

- Verify `proxmox_url` is correct and includes `/api2/json`
- Check that your Proxmox user has appropriate permissions
- If using self-signed certificates, `insecure_skip_tls_verify` is set to `true` by default

### Build Timeout

Windows builds can take several hours, especially with Windows Updates enabled. The default `winrm_timeout` is set to `6h`. If needed, you can increase it:

```bash
packer build -var "winrm_timeout=10h" windows_2025_docker_proxmox.json
```

## Related Files

- `windows_2025_docker.json` - Original configuration with multiple builders
- `build_windows_2025_docker_proxmox.sh` - Build script for Proxmox
- `answer_files/2025_core/Autounattend.xml` - Windows unattended installation file
- `scripts/` - Provisioning scripts directory
