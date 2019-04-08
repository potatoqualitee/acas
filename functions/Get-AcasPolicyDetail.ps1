function Get-AcasPolicyDetail {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER SessionId
    Parameter description

    .PARAMETER PolicyId
    Parameter description

    .PARAMETER Name
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param
    (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'All')]
        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(ParameterSetName = 'ByID')]
        [Alias('Index')]
        [int32[]]$SessionId,
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByID')]
        [int32]$PolicyId,
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [string]$Name
    )

    begin {
        $ToProcess = @()

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
            switch ($PSCmdlet.ParameterSetName) {
                'ByName' {
                    $Pol = Get-AcasPolicy -Name $Name -SessionId $Connection.SessionId
                    if ($Pol -ne $null) {
                        $PolicyId = $Pol.PolicyId
                    } else {
                        throw "Policy with name $($Name) was not found."
                    }
                }

            }
            Write-PSFMessage -Level Verbose -Mesage "Getting details for policy with id $($PolicyId)."
            $Policy = InvokeNessusRestRequest -SessionObject $Connection -Path "/policies/$($PolicyId)" -Method 'GET'
            $Policy
        }
    }
}