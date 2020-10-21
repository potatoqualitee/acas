function Restart-TenService {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER ScanId
        Parameter description

    .PARAMETER AlternateTarget
        Parameter description

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS> Get-Ten
    #>
    [CmdletBinding()]
    param
    (
        # Nessus session Id
        [switch]$EnableException
    )
    begin {
        $params = @{ }
        $paramJson = ConvertTo-Json -InputObject $params -Compress
    }
    process {
        foreach ($session in (Get-TenSession)) {
            Invoke-TenRequest -SessionObject $session -Path "/server/restart" -Method 'Post' -Parameter $paramJson -ContentType 'application/json'
        }
    }
}