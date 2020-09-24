function Remove-TenUser {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER SessionId
        ID of a valid Nessus session. This is auto-populated after a connection is made using Connect-TenServer.

    .PARAMETER UserId
        Parameter description

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS> Get-Ten
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('Index')]
        [int32[]]$SessionId = $script:NessusConn.SessionId,
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [int32[]]$UserId,
        [switch]$EnableException
    )
    process {
        foreach ($session in (Get-TenSession -SessionId $SessionId)) {
            foreach ($uid in $UserId) {
                Write-PSFMessage -Level Verbose -Message "Deleting user with Id $($uid)"
                Invoke-TenRequest -SessionObject $session -Path "/users/$($uid)" -Method 'Delete'
            }
        }
    }
}