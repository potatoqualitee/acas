function Get-TNQuery {
    <#
    .SYNOPSIS
        Gets a list of queries

    .DESCRIPTION
        Gets a list of queries

    .PARAMETER SessionObject
        Optional parameter to force using specific SessionObjects. By default, each command will connect to all connected servers that have been connected to using Connect-TNServer

    .PARAMETER Name
        The name of the target query

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with 'sea of red' exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this 'nice by default' feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS C:\> Get-TNQuery

        Gets a list of queries

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]$SessionObject = (Get-TNSession),
        [Parameter(ValueFromPipelineByPropertyName)]
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
                Path            = "/query?filter=usable&fields=browseColumns,browseSortColumn,browseSortDirection,canManage,canUse,context,createdTime,creator,description,filters,modifiedTime,name,owner,ownerGroup,status,tags,tool,type,groups"
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