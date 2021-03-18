function Get-TNOS {
    <#
    .SYNOPSIS
        Gets a list of assets

    .DESCRIPTION
        Gets a list of assets

    .PARAMETER SessionObject
        Optional parameter to force using specific SessionObjects. By default, each command will connect to all connected servers that have been connected to using Connect-TNServer

    .PARAMETER Name
        The name of the target asset

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with 'sea of red' exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this 'nice by default' feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS C:\> Get-TNAsset

        Gets a list of assets

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]$SessionObject = (Get-TNSession),
        [switch]$EnableException
    )
    process {
        foreach ($session in $SessionObject) {
            if (-not $session.sc) {
                Stop-PSFFunction -EnableException:$EnableException -Message "Only tenable.sc supported" -Continue
            }

            # $recentscan ?
            foreach ($os in (Get-TNAnalysis -Tool listos)) {
                foreach ($name in $os.Name) {
                    # too generic
                    if ($name -eq "Windows") { continue }
                    $filters = @(
                        @{
                            filterName = 'pluginID'
                            operator   = '='
                            value      = '11936, 1'
                        }
                        @{
                            filterName = 'pluginText'
                            operator   = '='
                            value      = $name
                        }
                    )

                    $results = Get-TNAnalysis -Tool sumip -SourceType cumulative -Filter $filters
                    foreach ($result in $results) {
                        if ($result.OsCPE -match "linux_kernel") {
                            Write-PSFMessage -Level Warning -Message "$($result.Ip) is running too generic of a Linux distro. Moving on."
                            continue
                        }
                        [pscustomobject]@{
                            ServerUri       = $result.ServerUri
                            OperatingSystem = $name
                            OsCPE           = $result.OsCPE
                            DnsName         = $result.DnsName
                            NetbiosName     = $result.NetbiosName
                            Ip              = $result.Ip
                        }
                    }
                }
            }
        }
    }
}