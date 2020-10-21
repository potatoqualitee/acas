function Remove-TenPolicy {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER PolicyId
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
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int32]$PolicyId,
        [switch]$EnableException
    )
    process {
        foreach ($session in (Get-TenSession)) {
            Write-PSFMessage -Level Verbose -Message "Deleting policy with id $PolicyId"
            Invoke-TenRequest -SessionObject $session -Path "/policies/$PolicyId" -Method 'DELETE'
            Write-PSFMessage -Level Verbose -Message 'Policy deleted.'
        }
    }
}