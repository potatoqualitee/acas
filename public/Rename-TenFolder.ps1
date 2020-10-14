function Rename-TenFolder {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER SessionId
        ID of a valid Nessus session. This is auto-populated after a connection is made using Connect-TenServer.

    .PARAMETER FolderId
        Parameter description

    .PARAMETER Name
        Parameter description

    .EXAMPLE
        PS> Get-Ten
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Index')]
        [int32[]]$SessionId = $script:NessusConn.SessionId,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Int]$FolderId,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Name,
        [switch]$EnableException
    )
    process {
        foreach ($session in (Get-TenSession)) {
            Invoke-TenRequest -SessionObject $session -Path "/folders/$($FolderId)" -Method 'PUT' -Parameter @{'name' = $Name }
        }
    }
}