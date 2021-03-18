﻿function Get-TNPluginFamily {
    <#
    .SYNOPSIS
        Gets a list of plugin familys

    .DESCRIPTION
        Gets a list of plugin familys

    .PARAMETER SessionObject
        Optional parameter to force using specific SessionObjects. By default, each command will connect to all connected servers that have been connected to using Connect-TNServer

    .PARAMETER FamilyId
        The ID of the target family

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with 'sea of red' exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this 'nice by default' feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS C:\> Get-TNPluginFamily -FamilyId 10, 11

        Gets a list of plugin familys with ID 10, 11

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]$SessionObject = (Get-TNSession),
        [Parameter(Mandatory)]
        [int32[]]$FamilyId,
        [switch]$EnableException
    )
    process {
        foreach ($session in $SessionObject) {
            $PSDefaultParameterValues["*:SessionObject"] = $session
            foreach ($id in $FamilyId) {
                $family = Invoke-TNRequest -SessionObject $session -EnableException:$EnableException -Path "/plugins/families/$FamilyId" -Method GET
                [pscustomobject]@{
                    FamilyId = $family.id
                    Name     = $family.name
                    Count    = $family.plugins.count
                    Plugins  = $family.plugins
                }
            }
        }
    }
}