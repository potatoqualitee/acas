function Add-AcasPluginRule {
    <#
    .SYNOPSIS
    Creates a new Nessus plugin rule

    .DESCRIPTION
    Can be used to alter report output for various reasons. i.e. vulnerability acceptance, verified
    false-positive on non-credentialed scans, alternate mitigation in place, etc...

    .PARAMETER SessionId
    ID of a valid Nessus session

    .PARAMETER PluginId
    ID number of the plugin which would you like altered

    .PARAMETER ComputerName
    Name, IP address, or Wildcard (*), which defines the the host(s) affected by the rule

    .PARAMETER Type
    Severity level you would like future scan reports to display for the defined host(s)

    .PARAMETER Expiration
    Date/Time object, which defines the time you would like the rule to expire

    .EXAMPLE
    Add-AcasPluginRule -SessionId 0 -PluginId 15901 -ComputerName 'WebServer' -Type Critical
    Creates a rule that changes the default severity of 'Medium', to 'Critical' for the defined computer and plugin ID

    .EXAMPLE
    $WebServers | % {Add-AcasPluginRule -SessionId 0 -PluginId 15901 -ComputerName $_ -Type Critical}
    Creates a rule for a list computers, using the defined options
    #>
    [CmdletBinding()]
    param
    (
        # Nessus session Id
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('Index')]
        [int32[]]$SessionId = $global:NessusConn.SessionId,
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [int32]$PluginId,
        [Parameter(Position = 2, ValueFromPipelineByPropertyName)]
        [Alias('IPAddress', 'IP', 'Host')]
        [String]$ComputerName = '*',
        [Parameter(Mandatory, Position = 3, ValueFromPipelineByPropertyName)]
        [ValidateSet('Critical', 'High', 'Medium', 'Low', 'Info', 'Exclude')]
        [String]$Type,
        [Parameter(Position = 4, ValueFromPipelineByPropertyName)]
        [datetime]$Expiration,
        [switch]$EnableException
    )

    begin {
        $collection = @()

        foreach ($i in $SessionId) {
            $connections = $global:NessusConn

            foreach ($connection in $connections) {
                if ($connection.SessionId -eq $i) {
                    $collection += $connection
                }
            }
        }

        $origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
    }

    process {
        foreach ($connection in $collection) {
            $dtExpiration = $null

            If ($Expiration) {

                $dtExpiration = (New-TimeSpan -Start $origin -end $Expiration).TotalSeconds.ToInt32($null)
            }

            $dicType = @{
                'Critical' = 'recast_critical'
                'High'     = 'recast_high'
                'Medium'   = 'recast_medium'
                'Low'      = 'recast_low'
                'Info'     = 'recast_info'
                'Exclude'  = 'exclude'
            }

            $strType = $dicType[$Type]

            $pRulehash = @{
                'plugin_id' = $PluginId
                'host'      = $ComputerName
                'type'      = $strType
                'date'      = $dtExpiration
            }

            $pRuleJson = ConvertTo-Json -InputObject $pRulehash -Compress

            Invoke-AcasRequest -SessionObject $connection -Path '/plugin-rules' -Method 'Post' `
                -Parameter $pRuleJson -ContentType 'application/json'
        }
    }
}