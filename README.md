# esxi-host-scripts

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)
![VMware](https://img.shields.io/badge/VMware-ESXi-orange?logo=vmware)
![License](https://img.shields.io/badge/License-MIT-yellow)

A collection of PowerShell scripts for managing and automating VMware ESXi host administration tasks. These scripts use **VMware PowerCLI** to streamline daily ESXi operations across your virtualization infrastructure.

---

## Prerequisites

- PowerShell 5.1 or PowerShell 7+
- VMware PowerCLI module installed:
  ```powershell
  Install-Module -Name VMware.PowerCLI -Scope CurrentUser
  ```
- Network access to the vCenter Server (which manages your ESXi hosts)
- Valid credentials with appropriate ESXi/vCenter privileges

---

## Scripts

| Script | Description |
|--------|-------------|
| [Get-ESXiHostInfo.ps1](./Get-ESXiHostInfo.ps1) | Collects hardware, BIOS, CPU, memory, ESXi version, and uptime for all hosts |
| [Set-ESXiMaintenanceMode.ps1](./Set-ESXiMaintenanceMode.ps1) | Puts hosts into or exits maintenance mode, with optional VM evacuation |
| [Get-ESXiStorageAdapters.ps1](./Get-ESXiStorageAdapters.ps1) | Reports HBA, Fibre Channel, and iSCSI adapter details per host |
| [Get-ESXiNetworkConfig.ps1](./Get-ESXiNetworkConfig.ps1) | Retrieves vSwitch, port group, and VMkernel adapter configurations |
| [Get-ESXiSyslogConfig.ps1](./Get-ESXiSyslogConfig.ps1) | Checks and optionally updates syslog server settings on ESXi hosts |

---

## Usage

### Get-ESXiHostInfo.ps1
Collects detailed hardware and software inventory from all ESXi hosts.
```powershell
$cred = Get-Credential
.\Get-ESXiHostInfo.ps1 -vCenterServer 'vcenter.domain.local' -Credential $cred
```

### Set-ESXiMaintenanceMode.ps1
Place a host into maintenance mode (evacuating VMs via vMotion).
```powershell
# Enter maintenance mode with VM evacuation
.\Set-ESXiMaintenanceMode.ps1 -vCenterServer 'vcenter.domain.local' -Credential $cred -HostName 'esxi01.domain.local' -Action Enter -Evacuate

# Exit maintenance mode
.\Set-ESXiMaintenanceMode.ps1 -vCenterServer 'vcenter.domain.local' -Credential $cred -HostName 'esxi01.domain.local' -Action Exit
```

### Get-ESXiStorageAdapters.ps1
Reports all HBA, FC, and iSCSI adapters from every ESXi host.
```powershell
.\Get-ESXiStorageAdapters.ps1 -vCenterServer 'vcenter.domain.local' -Credential $cred
```

### Get-ESXiNetworkConfig.ps1
Reports virtual switches, port groups, and VMkernel adapters.
```powershell
.\Get-ESXiNetworkConfig.ps1 -vCenterServer 'vcenter.domain.local' -Credential $cred
```

### Get-ESXiSyslogConfig.ps1
Check current syslog settings or configure a new syslog server on all ESXi hosts.
```powershell
# Report only
.\Get-ESXiSyslogConfig.ps1 -vCenterServer 'vcenter.domain.local' -Credential $cred

# Update syslog server
.\Get-ESXiSyslogConfig.ps1 -vCenterServer 'vcenter.domain.local' -Credential $cred -SyslogServer 'udp://syslog.domain.local:514'
```

---

## Notes

- All scripts connect via vCenter Server; direct ESXi host connections are not required.
- SSL certificate warnings are suppressed with `-InvalidCertificateAction Ignore`. Configure valid certificates in production.
- Maintenance mode with `-Evacuate` requires DRS (Distributed Resource Scheduler) to be enabled in the cluster.
- Scripts automatically disconnect from vCenter upon completion.

---

## Author

**Predator-VJ** - PowerShell Scripting | IT SysAdmin | VMware Automation

---

## License

This project is licensed under the MIT License.
