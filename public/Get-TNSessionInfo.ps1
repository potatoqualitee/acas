﻿function Get-TNSessionInfo {
    <#
    .SYNOPSIS
        Gets a list of session infos

    .DESCRIPTION
        Gets a list of session infos

    .PARAMETER SessionObject
        Optional parameter to force using specific SessionObjects. By default, each command will connect to all connected servers that have been connected to using Connect-TNServer

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with 'sea of red' exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this 'nice by default' feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS C:\> Get-TNSessionInfo

        Gets a list of session infos

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
            $PSDefaultParameterValues["*:SessionObject"] = $session
            Write-PSFMessage -Level Verbose -Message "Getting server session $id"

            $RestMethodParams = @{
                Method          = 'Get'
                'URI'           = "$($session.URI)/session"
                'Headers'       = @{'X-Cookie' = "token=$($session.Token)" }
                'ErrorVariable' = 'NessusSessionError'
            }
            $SessInfo = Invoke-RestMethod @RestMethodParams
            [pscustomobject]@{
                Id         = $SessInfo.id
                Name       = $SessInfo.name
                UserName   = $SessInfo.UserName
                Email      = $SessInfo.Email
                Type       = $SessInfo.Type
                Permission = $permidenum[$SessInfo.permissions]
                LastLogin  = $origin.AddSeconds($SessInfo.lastlogin).ToLocalTime()
                Groups     = $SessInfo.groups
                Connectors = $SessInfo.connectors
            }
        }
    }
}