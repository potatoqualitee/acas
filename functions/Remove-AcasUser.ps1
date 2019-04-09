function Remove-AcasUser {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER SessionId
    Parameter description

    .PARAMETER UserId
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('Index')]
        [int32[]]$SessionId = $global:NessusConn.SessionId,
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [int32[]]$UserId
    )

    begin {
        $ToProcess = @()
        foreach ($i in $SessionId) {
            $connections = $global:NessusConn

            foreach ($connection in $connections) {
                if ($connection.SessionId -eq $i) {
                    $ToProcess += $connection
                }
            }
        }
    }
    process {
        foreach ($connection in $ToProcess) {
            foreach ($uid in $UserId) {
                Write-PSFMessage -Level Verbose -Mesage "Deleting user with Id $($uid)"
                InvokeNessusRestRequest -SessionObject $connection -Path "/users/$($uid)" -Method 'Delete'
            }
        }
    }
}