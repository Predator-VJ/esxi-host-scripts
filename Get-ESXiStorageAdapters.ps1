<#
.SYNOPSIS
    Retrieves storage adapter and LUN information from ESXi hosts.
.DESCRIPTION
    Connects to vCenter and collects HBA (Host Bus Adapter), iSCSI, and
    datastore LUN information from all ESXi hosts. Exports to CSV.
.PARAMETER vCenterServer
    The FQDN or IP of the vCenter Server.
.PARAMETER Credential
    PSCredential for vCenter authentication.
.EXAMPLE
    .\Get-ESXiStorageAdapters.ps1 -vCenterServer 'vcenter.domain.local'
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
    Write-Host "Collecting storage adapter information from ESXi hosts..." -ForegroundColor Cyan

    $results = @()
    $esxiHosts = Get-VMHost

    foreach ($esxiHost in $esxiHosts) {
        $hbas = Get-VMHostHba -VMHost $esxiHost
        foreach ($hba in $hbas) {
            $result = [PSCustomObject]@{
                HostName    = $esxiHost.Name
                HBADevice   = $hba.Device
                HBAType     = $hba.Type
                Model       = $hba.Model
                Status      = $hba.Status
                WWN         = if ($hba.Type -eq 'FibreChannel') { $hba.PortWorldWideName } else { 'N/A' }
                iSCSIName   = if ($hba.Type -eq 'IScsi') { $hba.IScsiName } else { 'N/A' }
            }
            $results += $result
        }
    }

    $results | Format-Table -AutoSize
    $outputPath = ".\ESXiStorageAdapters_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $results | Export-Csv -Path $outputPath -NoTypeInformation
    Write-Host "Storage adapter info exported to: $outputPath" -ForegroundColor Green
}
catch {
    Write-Error "Failed to retrieve storage adapter info: $_"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
