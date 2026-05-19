<#
.SYNOPSIS
    Retrieves network configuration details from ESXi hosts.
.DESCRIPTION
    Connects to vCenter and collects virtual switch, port group, vmkernel
    adapter, and physical NIC details for all ESXi hosts.
.PARAMETER vCenterServer
    The FQDN or IP of the vCenter Server.
.PARAMETER Credential
    PSCredential for vCenter authentication.
.EXAMPLE
    .\Get-ESXiNetworkConfig.ps1 -vCenterServer 'vcenter.domain.local'
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
    Write-Host "Collecting network configuration from ESXi hosts..." -ForegroundColor Cyan

    $esxiHosts = Get-VMHost
    $allPortGroups = @()
    $allVmk = @()

    foreach ($esxiHost in $esxiHosts) {
        # Virtual Switches
        Write-Host "`n=== vSwitches on $($esxiHost.Name) ==="  -ForegroundColor Yellow
        Get-VirtualSwitch -VMHost $esxiHost | Format-Table Name, NumPorts, Mtu -AutoSize

        # Port Groups
        $portGroups = Get-VirtualPortGroup -VMHost $esxiHost | Select-Object @{N='Host';E={$esxiHost.Name}}, Name, VLanId, VirtualSwitchName
        $allPortGroups += $portGroups

        # Build a vmk -> enabled services map from VirtualNicManager (authoritative)
        # NetConfig.NicType examples: management, vmotion, faultToleranceLogging,
        # vsan, vSphereReplication, vSphereReplicationNFC, vSphereProvisioning
        $vmkServiceMap = @{}
        $vnicMgr = Get-View $esxiHost.ExtensionData.ConfigManager.VirtualNicManager
        foreach ($netConfig in $vnicMgr.Info.NetConfig) {
            foreach ($selected in $netConfig.SelectedVnic) {
                if ($selected -match 'VirtualNic-(vmk\d+)$') {
                    $device = $Matches[1]
                    if (-not $vmkServiceMap.ContainsKey($device)) {
                        $vmkServiceMap[$device] = @()
                    }
                    $vmkServiceMap[$device] += $netConfig.NicType
                }
            }
        }

        # VMkernel Adapters
        $vmks = Get-VMHostNetworkAdapter -VMHost $esxiHost -VMKernel | Select-Object @{N='Host';E={$esxiHost.Name}}, DeviceName, IP, SubnetMask, Mtu, PortGroupName,
            @{N='Services';E={
                if ($vmkServiceMap.ContainsKey($_.DeviceName)) {
                    ($vmkServiceMap[$_.DeviceName] | Sort-Object -Unique) -join ','
                } else { '' }
            }}
        $allVmk += $vmks
    }

    Write-Host "`n=== Port Groups ==="  -ForegroundColor Cyan
    $allPortGroups | Format-Table -AutoSize
    $allPortGroups | Export-Csv -Path ".\ESXiPortGroups_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation

    Write-Host "`n=== VMkernel Adapters ==="  -ForegroundColor Cyan
    $allVmk | Format-Table -AutoSize
    $allVmk | Export-Csv -Path ".\ESXiVMkernels_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation

    Write-Host "Network configuration exported." -ForegroundColor Green
}
catch {
    Write-Error "Failed to retrieve network config: $_"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
