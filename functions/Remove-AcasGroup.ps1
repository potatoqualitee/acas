function Remove-AcasGroup {
    ##
    
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('Index')]
        [int32[]]$SessionId = $global:NessusConn.SessionId,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [Int32]$GroupId
    )

    begin {
        foreach ($id in $SessionId) {
            $connections = $global:NessusConn

            foreach ($connection in $connections) {
                if ($connection.SessionId -eq $id) {
                    $collection += $connection
                }
            }
        }
    }
    process {
        foreach ($connection in $collection) {
            $ServerTypeParams = @{
                'SessionObject' = $connection
                'Path'          = '/server/properties'
                'Method'        = 'GET'
            }

            $Server = Invoke-AcasRequest @ServerTypeParams

            if ($Server.capabilities.multi_user -eq 'full') {
                $GroupParams = @{
                    'SessionObject' = $connection
                    'Path'          = "/groups/$($GroupId)"
                    'Method'        = 'DELETE '
                }

                Invoke-AcasRequest @GroupParams
            } else {
                Write-PSFMessage -Level Warning -Mesage "Server for session $($connection.sessionid) is not licenced for multiple users."
            }
        }
    }
}