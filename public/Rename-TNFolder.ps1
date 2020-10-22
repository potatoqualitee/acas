function Rename-TNFolder {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER FolderId
        Parameter description

    .PARAMETER Name
        Parameter description

    .EXAMPLE
        PS> Get-TN
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Int]$FolderId,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Name,
        [switch]$EnableException
    )
    process {
        foreach ($session in (Get-TNSession)) {
            Invoke-TNRequest -SessionObject $session -Path "/folders/$($FolderId)" -Method 'PUT' -Parameter @{'name' = $Name }
        }
    }
}