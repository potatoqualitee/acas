function Disable-AcasPolicyLocalPortEnumeration {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER SessionId
        ID of a valid Nessus session. This is auto-populated after a connection is made using Connect-AcasService.

    .PARAMETER PolicyId
        Parameter description

    .PARAMETER ScanMethods
        Parameter description

    .PARAMETER VerifyOpenPorts
        Parameter description

    .PARAMETER ScanOnlyIfLocalFails
        Parameter description

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS> Get-Acas
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param
    (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('Index')]
        [int32]$SessionId,
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [int32[]]$PolicyId,
        [Parameter(Mandatory, Position = 2, ValueFromPipelineByPropertyName)]
        [ValidateSet('WMINetstat', 'SSHNetstat', 'SNMPScanner')]
        [string[]]$ScanMethods,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$VerifyOpenPorts,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$ScanOnlyIfLocalFails,
        [switch]$EnableException
    )

    begin {
        $scanners = @{ }
        foreach ($scanner in $ScanMethods) {
            if ($scanner -eq 'WMINetstat')
            { $scanners['wmi_netstat_scanner'] = 'no' }

            if ($scanner -eq 'SSHNetstat')
            { $scanners['ssh_netstat_scanner'] = 'no' }

            if ($scanner -eq 'SNMPScanner')
            { $scanners['snmp_scanner'] = 'no' }
        }

        if ($VerifyOpenPorts)
        { $scanners['verify_open_ports'] = 'no' }

        if ($ScanOnlyIfLocalFails)
        { $scanners['only_portscan_if_enum_failed'] = 'no' }

        $settings = @{'settings' = $scanners }
        $settingsJson = ConvertTo-Json -InputObject $settings -Compress
    }
    process {
        foreach ($session in (Get-AcasSession -SessionId $SessionId)) {
            foreach ($PolicyToChange in $PolicyId) {
                $params = @{
                    SessionObject   = $session
                    Path            = "/policies/$($PolicyToChange)"
                    Method          = 'PUT'
                    ContentType     = 'application/json'
                    Parameter       = $settingsJson
                    EnableException = $EnableException
                }

                $null = Invoke-AcasRequest @params
                Get-AcasPolicyLocalPortEnumeration -SessionId $session.SessionId -PolicyId $PolicyToChange
            }
        }
    }
}