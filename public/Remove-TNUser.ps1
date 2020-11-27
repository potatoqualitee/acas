function Remove-TNUser {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER UserId
        Parameter description

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS> Get-TN
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]$SessionObject = (Get-TNSession),
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int32[]]$UserId,
        [switch]$EnableException
    )
    process {
        foreach ($session in $SessionObject) {
            foreach ($uid in $UserId) {
                Write-PSFMessage -Level Verbose -Message "Deleting user with Id $uid"
                Invoke-TNRequest -SessionObject $session -EnableException:$EnableException -Path "/users/$uid" -Method 'Delete'
            }
        }
    }
}