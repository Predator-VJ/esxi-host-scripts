<#
.SYNOPSIS
    Retrieves and optionally sets the syslog configuration on ESXi hosts.
.DESCRIPTION
    Connects to vCenter and checks current syslog settings on all ESXi hosts.
    Optionally updates the syslog server to a specified remote endpoint.
.PARAMETER vCenterServer
    The FQDN or IP of the vCenter Server.
.PARAMETER Credential
    PSCredential for vCenter authentication.
.PARAMETER SyslogServer
    Optional. Syslog server URI to configure (e.g., 'udp://syslog.domain.local:514').
    If not provided, the script only reports current settings.
.EXAMPLE
    # Report current syslog settings
    .\Get-ESXiSyslogConfig.ps1 -vCenterServer 'vcenter.domain.local'

    # Update syslog server
    .\Get-ESXiSyslogConfig.ps1 -vCenterServer 'vcenter.domain.local' -SyslogServer 'udp://syslog.domain.local:514'
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,

    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]$Credential,

    [string]$SyslogServer = ''
)

Import-Module VMware.PowerCLI -ErrorAction Stop
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

try {
    Connect-VIServer -Server $vCenterServer -Credential $Credential -ErrorAction Stop
    $esxiHosts = Get-VMHost
    $results = @()

    foreach ($esxiHost in $esxiHosts) {
        $currentSyslog = Get-VMHostSysLogServer -VMHost $esxiHost

        if ($SyslogServer -ne '') {
            Write-Host "Configuring syslog on $($esxiHost.Name) -> $SyslogServer" -ForegroundColor Yellow
            Set-VMHostSysLogServer -SysLogServer $SyslogServer -VMHost $esxiHost -ErrorAction Stop
            # Restart syslog service to apply
            $esxiHost | Invoke-EsxCli -V2 | ForEach-Object { $_.system.syslog.reload.Invoke() }
            Write-Host "Syslog updated on $($esxiHost.Name)" -ForegroundColor Green
        }

        $result = [PSCustomObject]@{
            HostName      = $esxiHost.Name
            SyslogServers = ($currentSyslog | ForEach-Object { "$($_.Host):$($_.Port)" }) -join ', '
        }
        $results += $result
    }

    Write-Host "`n=== Current Syslog Configuration ==="  -ForegroundColor Cyan
    $results | Format-Table -AutoSize
    $results | Export-Csv -Path ".\ESXiSyslogConfig_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation
    Write-Host "Syslog config report exported." -ForegroundColor Green
}
catch {
    Write-Error "Failed to get/set syslog config: $_"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
