<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0d1117,50:1a1a2e,100:1a1020&height=200&section=header&text=ESXi%20Host%20Scripts&fontSize=48&fontColor=e040fb&animation=fadeIn&fontAlignY=35&desc=Configure.%20Monitor.%20Maintain.&descAlignY=55&descSize=18&descColor=ce93d8" />

</div>

<div align="center">

![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![VMware ESXi](https://img.shields.io/badge/VMware%20ESXi-607078?style=for-the-badge&logo=vmware&logoColor=white)
![PowerCLI](https://img.shields.io/badge/VMware%20PowerCLI-E040FB?style=for-the-badge&logo=vmware&logoColor=white)
![Scripts](https://img.shields.io/badge/Scripts-5-blueviolet?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge)

</div>

<br/>

<div align="center">
<img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=700&size=20&pause=1000&color=E040FB&center=true&vCenter=true&width=650&height=40&lines=🖥️+ESXi+Host+Info+%26+Hardware+Inventory;🌐+Network+Adapter+%26+vSwitch+Config;💾+Storage+Adapter+%26+Datastore+Info;📦+Syslog+Configuration+Management;🔧+Maintenance+Mode+Control" alt="Features" />
</div>

<br/>

---

## 📋 &nbsp;Script Arsenal

<div align="center">

| Script | Description | Category |
|--------|-------------|----------|
| `Get-ESXiHostInfo.ps1` | ESXi host hardware & version inventory | 🖥️ Info |
| `Get-ESXiNetworkConfig.ps1` | Network adapters & vSwitch configuration | 🌐 Network |
| `Get-ESXiStorageAdapters.ps1` | Storage adapters & datastore details | 💾 Storage |
| `Get-ESXiSyslogConfig.ps1` | View & verify syslog server settings | 📦 Logging |
| `Set-ESXiMaintenanceMode.ps1` | Enter or exit ESXi maintenance mode | 🔧 Maintenance |

</div>

---

## ⚙️ &nbsp;Prerequisites

- PowerShell 5.1 or PowerShell 7+
- VMware PowerCLI module installed:

```powershell
Install-Module -Name VMware.PowerCLI -Scope CurrentUser
```

- Direct network access to ESXi host or via vCenter
- ESXi credentials with administrative privileges

---

## 🚀 &nbsp;Quick Start

```powershell
# Clone the repository
git clone https://github.com/Predator-VJ/esxi-host-scripts.git
cd esxi-host-scripts

# Connect to ESXi host directly
Connect-VIServer -Server <esxi-host-ip-or-fqdn>

# Run any script
.\Get-ESXiHostInfo.ps1
.\Get-ESXiNetworkConfig.ps1
.\Get-ESXiStorageAdapters.ps1
```

---

## 👤 &nbsp;Author

<div align="center">

**Vikas Joshi** — IT SysAdmin | VMware ESXi+26 vCenter Engineer

[![GitHub](https://img.shields.io/badge/GitHub-Predator--VJ-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Predator-VJ)

</div>

<div align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:1a1020,50:1a1a2e,100:0d1117&height=120&section=footer" />
</div>
