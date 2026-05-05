<#
.SYNOPSIS
    Puts ESXi hosts into or removes from maintenance mode.
.DESCRIPTION
    Connects to vCenter and places specified ESXi hosts into maintenance mode
    (with optional VM migration) or exits maintenance mode.
.PARAMETER vCenterServer
    The FQDN or IP of the vCenter Server.
.PARAMETER Credential
    PSCredential for vCenter authentication.
.PARAMETER HostName
    Name of the ESXi host. Use '*' for all hosts.
.PARAMETER Action
    'Enter' to enter maintenance mode or 'Exit' to leave it.
.PARAMETER Evacuate
    If set, VMs are migrated off the host via vMotion before entering maintenance mode.
.EXAMPLE
    .\Set-ESXiMaintenanceMode.ps1 -vCenterServer 'vcenter.domain.local' -HostName 'esxi01.domain.local' -Action Enter -Evacuate
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,

    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$HostName,

    [ValidateSet('Enter','Exit')]
    [string]$Action = 'Enter',

    [switch]$Evacuate
)

Import-Module VMware.PowerCLI -ErrorAction Stop
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

try {
    Connect-VIServer -Server $vCenterServer -Credential $Credential -ErrorAction Stop

    if ($HostName -eq '*') {
        $esxiHosts = Get-VMHost
    } else {
        $esxiHosts = Get-VMHost -Name $HostName -ErrorAction Stop
    }

    foreach ($host in $esxiHosts) {
        if ($Action -eq 'Enter') {
            if ($host.ConnectionState -ne 'Maintenance') {
                Write-Host "Entering maintenance mode: $($host.Name)" -ForegroundColor Yellow
                if ($Evacuate) {
                    Set-VMHost -VMHost $host -State Maintenance -Evacuate -Confirm:$false
                } else {
                    Set-VMHost -VMHost $host -State Maintenance -Confirm:$false
                }
                Write-Host "$($host.Name) is now in maintenance mode." -ForegroundColor Green
            } else {
                Write-Host "$($host.Name) is already in maintenance mode." -ForegroundColor Gray
            }
        }
        elseif ($Action -eq 'Exit') {
            if ($host.ConnectionState -eq 'Maintenance') {
                Write-Host "Exiting maintenance mode: $($host.Name)" -ForegroundColor Cyan
                Set-VMHost -VMHost $host -State Connected -Confirm:$false
                Write-Host "$($host.Name) is back online." -ForegroundColor Green
            } else {
                Write-Host "$($host.Name) is not in maintenance mode." -ForegroundColor Gray
            }
        }
    }
}
catch {
    Write-Error "Maintenance mode operation failed: $_"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
