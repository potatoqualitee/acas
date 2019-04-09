function Add-AcasPolicyPortRange {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER SessionId
        Parameter description

    .PARAMETER PolicyId
        Parameter description

    .PARAMETER Port
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
        # Nessus session Id
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('Index')]
        [int32]$SessionId,
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [int32[]]$PolicyId,
        [Parameter(Mandatory, Position = 2, ValueFromPipelineByPropertyName)]
        [string[]]$Port,
        [switch]$EnableException
    )

    begin {
        $sessions = Get-AcasSession | Select-Object -ExpandProperty sessionid
        if ($SessionId -notin $sessions) {
            throw "SessionId $($SessionId) is not present in the current sessions."
        }
        $Session = Get-AcasSession -SessionId $SessionId
    }
    process {
        foreach ($PolicyToChange in $PolicyId) {
            try {
                $Policy = Get-AcasPolicyDetail -SessionId $Session.SessionId -PolicyId $PolicyToChange
                $Ports = "$($Policy.settings.portscan_range),$($Port -join ",")"
                $RequestParams = @{
                    'SessionObject' = $Session
                    'Path'          = "/policies/$($PolicyToChange)"
                    'Method'        = 'PUT'
                    'ContentType'   = 'application/json'
                    'Parameter'     = "{`"settings`": {`"portscan_range`": `"$($Ports)`"}}"
                }

                Invoke-AcasRequest @RequestParams | Out-Null
                Get-AcasPolicyPortRange -SessionId $SessionId -PolicyId $PolicyToChange
            }
            catch {
                Stop-Function -Message "Failure" -ErrorRecord $_ -Continue
            }
        }
    }
}