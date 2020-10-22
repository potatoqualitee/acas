function Copy-TNPolicy {
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
        PS> Get-TN
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int32]$PolicyId,
        [switch]$EnableException
    )
    process {
        foreach ($session in (Get-TNSession)) {
            $CopiedPolicy = Invoke-TNRequest -SessionObject $session -Path "/policies/$PolicyId/copy" -Method 'Post'
            [PSCustomObject]@{
                Name     = $CopiedPolicy.Name
                PolicyId = $CopiedPolicy.Id
            }
        }
    }
}