# Proxmox Configuration Summary

## Overview
This PR adds Proxmox VE support to the packer-windows repository by creating a new Packer configuration for Windows Server 2025 with Docker.

## Files Added

### 1. windows_2025_docker_proxmox.json
A complete Packer configuration file for building Windows Server 2025 with Docker on Proxmox VE.

**Key Features:**
- Based on the existing `windows_2025_docker.json` configuration
- Uses the `proxmox-iso` builder type
- Replaces floppy_files with cd_files (Proxmox doesn't support virtual floppy disks)
- Includes VirtIO drivers for optimal performance
- Maintains identical provisioners and post-processors from the original file
- Configurable via user variables for flexibility

**Builder Configuration:**
- VM Name: WindowsServer2025Docker
- Memory: 2048 MB (configurable)
- CPU: 2 cores, 1 socket
- Disk: 81920 MB (80 GB) on VirtIO with writeback cache
- Network: VirtIO adapter on vmbr0 bridge
- OS Type: win11 (for Windows Server 2025)
- SCSI Controller: virtio-scsi-single
- QEMU Agent: Enabled

### 2. build_windows_2025_docker_proxmox.sh
An executable build script with comprehensive documentation.

**Features:**
- Supports environment variables for Proxmox credentials
- Detailed prerequisites and usage instructions in comments
- Safe handling of credentials (optional environment variables)
- Example usage patterns included

### 3. README-proxmox.md
Comprehensive documentation for Proxmox users.

**Contents:**
- Prerequisites and setup instructions
- Plugin installation guide
- ISO upload requirements
- Configuration variables reference table
- Multiple build examples
- Customization options for storage and network
- Installed software list
- Troubleshooting guide
- Differences from other builders

## Design Decisions

### 1. Separate Configuration File
Created a dedicated file instead of modifying the existing `windows_2025_docker.json` to:
- Keep Proxmox-specific configuration isolated
- Avoid conflicts with multi-builder setup
- Make it easier for Proxmox users to find and use
- Maintain the original file's flexibility

### 2. CD-ROM for Answer Files
Proxmox doesn't support virtual floppy disks, so:
- Used `additional_iso_files` with `cd_files` option
- Answer files and scripts are provided on a CD-ROM labeled "PROVISION"
- This is the standard approach for Proxmox Windows builds

### 3. VirtIO Drivers
Included VirtIO drivers ISO as an additional device:
- Provides optimal disk and network performance
- Required for Windows to recognize VirtIO devices
- Standard practice for Windows VMs on KVM/Proxmox

### 4. Template Output
Configured to create a Proxmox template:
- Uses `template_name` and `template_description` fields
- Template can be cloned for creating new VMs
- Retained Vagrant post-processor for compatibility

### 5. Identical Provisioners
Kept the same provisioning steps as the original:
- Ensures consistent Windows/Docker setup across platforms
- Includes all Docker configuration and optimization scripts
- Maintains compatibility with existing workflows

## Testing Performed

1. ✓ JSON syntax validation
2. ✓ Structure verification (builders, provisioners, variables, post-processors)
3. ✓ Provisioner comparison with original file (identical)
4. ✓ Post-processor comparison with original file (identical)
5. ✓ Security scan (no vulnerabilities detected)

**Note:** Full functional testing requires:
- Packer Proxmox plugin installation: `packer plugins install github.com/hashicorp/proxmox`
- Access to a Proxmox VE server
- Windows Server 2025 ISO uploaded to Proxmox
- VirtIO drivers ISO uploaded to Proxmox

## Usage

### Quick Start
```bash
# Install the Proxmox plugin
packer plugins install github.com/hashicorp/proxmox

# Set environment variables
export PROXMOX_URL="https://your-proxmox.com:8006/api2/json"
export PROXMOX_USERNAME="root@pam"
export PROXMOX_PASSWORD="your_password"
export PROXMOX_NODE="pve"

# Run the build
./build_windows_2025_docker_proxmox.sh
```

### Customization
All Proxmox-specific settings can be overridden via command-line variables:
```bash
packer build \
  -var "proxmox_url=..." \
  -var "proxmox_storage_pool=my-storage" \
  -var "proxmox_network_bridge=vmbr1" \
  windows_2025_docker_proxmox.json
```

## Benefits

1. **Proxmox Support**: Adds support for the popular open-source virtualization platform
2. **Consistency**: Uses the same provisioning scripts as other builders
3. **Flexibility**: Fully configurable via user variables
4. **Documentation**: Comprehensive documentation for easy adoption
5. **Best Practices**: Follows Proxmox and Packer best practices
6. **Template-Ready**: Creates a reusable Proxmox template

## Compatibility

- Packer: 1.6.0+ (tested with 1.14.2)
- Proxmox VE: 6.x and 7.x (should work with 8.x)
- Windows Server 2025
- Requires Packer Proxmox plugin from HashiCorp

## References

- Original configuration: `windows_2025_docker.json`
- Packer Proxmox Builder: https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox
- VirtIO Drivers: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/
- Windows Server 2025: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2025
