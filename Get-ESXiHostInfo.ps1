<#
.SYNOPSIS
    Retrieves hardware and system information from ESXi hosts.
.DESCRIPTION
    Connects to vCenter and collects detailed hardware and software inventory
    from all ESXi hosts, including CPU, memory, BIOS version, and uptime.
.PARAMETER vCenterServer
    The FQDN or IP of the vCenter Server.
.PARAMETER Credential
    PSCredential for vCenter authentication.
.EXAMPLE
    .\Get-ESXiHostInfo.ps1 -vCenterServer 'vcenter.domain.local'
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,

    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]$Credential
)

Import-Module VMware.PowerCLI -ErrorAction Stop
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

try {
    Connect-VIServer -Server $vCenterServer -Credential $Credential -ErrorAction Stop
    Write-Host "Collecting ESXi host information..." -ForegroundColor Cyan

    $hosts = Get-VMHost | Select-Object Name,
        @{N='Manufacturer';E={$_.ExtensionData.Hardware.SystemInfo.Vendor}},
        @{N='Model';E={$_.ExtensionData.Hardware.SystemInfo.Model}},
        @{N='BIOSVersion';E={$_.ExtensionData.Hardware.BiosInfo.BiosVersion}},
        @{N='CPUSockets';E={$_.ExtensionData.Hardware.CpuInfo.NumCpuPackages}},
        @{N='CPUCores';E={$_.ExtensionData.Hardware.CpuInfo.NumCpuCores}},
        @{N='MemoryGB';E={[math]::Round($_.MemoryTotalGB,0)}},
        @{N='ESXiVersion';E={$_.Version}},
        @{N='Build';E={$_.Build}},
        @{N='UptimeDays';E={[math]::Round(((Get-Date) - $_.ExtensionData.Runtime.BootTime).TotalDays,1)}},
        ConnectionState

    $hosts | Format-Table -AutoSize
    $outputPath = ".\ESXiHostInfo_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $hosts | Export-Csv -Path $outputPath -NoTypeInformation
    Write-Host "Host info exported to: $outputPath" -ForegroundColor Green
}
catch {
    Write-Error "Failed to collect host info: $_"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
