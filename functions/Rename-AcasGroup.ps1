function Rename-AcasGroup {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER SessionId
    Parameter description

    .PARAMETER GroupId
    Parameter description

    .PARAMETER Name
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param
    (
        # Nessus session Id
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true)]
        [Alias('Index')]
        [int32[]]
        $SessionId,

        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [Int32]
        $GroupId,

        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [string]
        $Name
    )

    begin {
        foreach ($i in $SessionId) {
            $Connections = $Global:NessusConn

            foreach ($Connection in $Connections) {
                if ($Connection.SessionId -eq $i) {
                    $ToProcess += $Connection
                }
            }
        }
    }
    process {
        foreach ($Connection in $ToProcess) {
            $ServerTypeParams = @{
                'SessionObject' = $Connection
                'Path'          = '/server/properties'
                'Method'        = 'GET'
            }

            $Server = InvokeNessusRestRequest @ServerTypeParams

            if ($Server.capabilities.multi_user -eq 'full') {
                $GroupParams = @{
                    'SessionObject' = $Connection
                    'Path'          = "/groups/$($GroupId)"
                    'Method'        = 'PUT'
                    'ContentType'   = 'application/json'
                    'Parameter'     = (ConvertTo-Json -InputObject @{'name' = $Name} -Compress)
                }

                InvokeNessusRestRequest @GroupParams
            } else {
                Write-Warning -message "Server for session $($Connection.sessionid) is not licenced for multiple users."
            }
        }
    }
    end {
    }
}