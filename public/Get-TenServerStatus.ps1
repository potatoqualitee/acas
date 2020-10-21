function Get-TenServerStatus {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

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
        [switch]$EnableException
    )
    process {
        foreach ($session in (Get-TenSession)) {
            Invoke-TenRequest -SessionObject $session -Path '/server/status' -Method GET
        }
    }
}
# need bare invoker
# {"code":503,"progress":100,"status":"loading"}
# {"code":200,"progress":null,"status":"ready"}