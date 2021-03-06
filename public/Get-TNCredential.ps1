﻿function Get-TNCredential {
    <#
    .SYNOPSIS
        Gets a list of credentials

    .DESCRIPTION
        Gets a list of credentials

    .PARAMETER SessionObject
        Optional parameter to force using specific SessionObjects. By default, each command will connect to all connected servers that have been connected to using Connect-TNServer

    .PARAMETER Name
        The name of the target credential

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with 'sea of red' exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this 'nice by default' feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS C:\> Get-TNCredential

        Gets a list of all credentials

    .EXAMPLE
        PS C:\> Get-TNCredential -Name "Windows Scanner Credential", "Linux Scanner Credential"

        Returns the credential objects for "Windows Scanner Credential" and "Linux Scanner Credential"

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]$SessionObject = (Get-TNSession),
        [string[]]$Name,
        [switch]$EnableException
    )
    process {
        foreach ($session in $SessionObject) {
            $PSDefaultParameterValues["*:SessionObject"] = $session
            if (-not $session.sc) {
                Stop-PSFFunction -EnableException:$EnableException -Message "Only tenable.sc supported" -Continue
            }

            $params = @{
                Path            = "/credential?filter=usable&fields=name,tags,description,typeFields,createdTime,groups,name,type,owner,ownerGroup,groups,modifiedTime,canManage,canUse,tags"
                Method          = "GET"
                EnableException = $EnableException
            }

            if ($PSBoundParameters.Name) {
                Invoke-TNRequest @params | ConvertFrom-TNRestResponse | Where-Object Name -in $Name
            } else {
                Invoke-TNRequest @params | ConvertFrom-TNRestResponse
            }
        }
    }
}