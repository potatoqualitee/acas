function Edit-AcasPluginRule {
    <#
    .SYNOPSIS
    Edits a Nessus plugin rule

    .DESCRIPTION
    Can be used to change a previously defined, scan report altering rule

    .PARAMETER SessionId
    ID of a valid Nessus session

    .PARAMETER Id
    ID number of the rule which would you like removed/deleted

    .PARAMETER PluginId
    ID number of the plugin which would you like altered

    .PARAMETER ComputerName
    Name, IP address, or Wildcard (*), which defines the the host(s) affected by the rule

    .PARAMETER Type
    Severity level you would like future scan reports to display for the defined host(s)

    .PARAMETER Expiration
    Date/Time object, which defines the time you would like the rule to expire. Not required

    .EXAMPLE
    Edit-AcasPluginRule -SessionId 0 -Id 500 -ComputerName 'YourComputer' -Expiration (([datetime]::Now).AddDays(10)) -Type Low
    Will edit a plugin rule with an ID of 500, to have a new computer name. Rule expires in 10 days

    .EXAMPLE
    Get-AcasPluginRule -SessionId 0 | Edit-AcasPluginRule -Type High
    Will alter all rules to now have a serverity of 'Info'

    .EXAMPLE
    Get-AcasPluginRule -SessionId 0 | ? {$_.Host -eq 'myComputer'} | Edit-AcasPluginRule -Type 'High'
    Will find all plugin rules that match the computer name, and set their severity to high

    .INPUTS
    Can accept pipeline data from Get-AcasPluginRule

    .OUTPUTS
    Empty, unless an error is received from the server
    #>


    [CmdletBinding()]
    param
    (
        # Nessus session Id
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('Index')]
        [int32]$SessionId,
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [int32]$Id,
        [Parameter(Mandatory, Position = 2, ValueFromPipelineByPropertyName)]
        [int32]$PluginId,
        [Parameter(Position = 3, ValueFromPipelineByPropertyName)]
        [Alias('IPAddress', 'IP', 'Host')]
        [String]$ComputerName = '*',
        [Parameter(Mandatory, Position = 4, ValueFromPipelineByPropertyName)]
        [ValidateSet('Critical', 'High', 'Medium', 'Low', 'Info', 'Exclude')]
        [String]$Type,
        [Parameter(Position = 5, ValueFromPipelineByPropertyName)]
        [Object]$Expiration #TODO: Validate the Expiratoin date, but still allow nulls
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

                $dtExpiration = (New-TimeSpan -Start $origin -end $Expiration -ErrorAction SilentlyContinue).TotalSeconds.ToInt32($null)
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
            }

            If ($dtExpiration) {
                $pRulehash.Add('date', $dtExpiration)
            }

            $pRuleJson = ConvertTo-Json -InputObject $pRulehash -Compress

            $pRuleJson

            InvokeNessusRestRequest -SessionObject $connection -Path ('/plugin-rules/{0}' -f $Id) -Method 'Put' `
                -Parameter $pRuleJson -ContentType 'application/json'
        }
    }
}