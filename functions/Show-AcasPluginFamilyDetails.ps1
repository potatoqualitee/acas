function Show-AcasPluginFamilyDetails {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER SessionId
        ID of a valid Nessus session. This is auto-populated after a connection is made using Connect-AcasService.

    .PARAMETER FamilyId
        Parameter description

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS> Get-Acas
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('Index')]
        [int32[]]$SessionId = $global:NessusConn.SessionId,
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [int]$FamilyId,
        [switch]$EnableException
    )
    process {
        foreach ($session in (Get-AcasSession -SessionId $SessionId)) {
            foreach ($detail in (Invoke-AcasRequest -SessionObject $session -Path "/plugins/families/$($FamilyId)" -Method 'Get')) {
                [pscustomobject]@{
                    Name     = $detail.name
                    FamilyId = $detail.id
                    Plugins  = $detail.plugins
                }
            }
        }
    }
}