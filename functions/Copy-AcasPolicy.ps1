function Copy-AcasPolicy {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER SessionId
    Parameter description

    .PARAMETER PolicyId
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('Index')]
        [int32[]]$SessionId = $global:NessusConn.SessionId,
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [int32]$PolicyId,
        [switch]$EnableException
    )
    process {
        $collection = @()

        foreach ($id in $SessionId) {
            $connections = $global:NessusConn

            foreach ($connection in $connections) {
                if ($connection.SessionId -eq $id) {
                    $collection += $connection
                }
            }
        }

        foreach ($connection in $collection) {
            $CopiedPolicy = Invoke-AcasRequest -SessionObject $connection -Path "/policies/$($PolicyId)/copy" -Method 'Post'
            [PSCustomObject]@{
                Name      = $CopiedPolicy.Name
                PolicyId  = $CopiedPolicy.Id
                SessionId = $connection.SessionId
            }
        }
    }
}