function Set-TNPolicyPortRange {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER PolicyId
        Parameter description

    .PARAMETER Port
        Parameter description

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS> Get-TN

    #>

    [CmdletBinding()]
    [OutputType([int])]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [int32[]]$PolicyId,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$Port,
        [switch]$EnableException
    )
    process {
        foreach ($session in (Get-TNSession)) {
            foreach ($policy in $PolicyId) {
                $params = @{
                    SessionObject = $session
                    Path          = "/policies/$policy"
                    Method        = 'PUT'
                    ContentType   = 'application/json'
                    Parameter     = "{`"settings`": {`"portscan_range`": `"$($Port -join ",")`"}}"
                }

                $null = Invoke-TNRequest @params
                Get-TNPolicyPortRange -SessionId $session.SessionId -PolicyId $policy
            }
        }
    }
}