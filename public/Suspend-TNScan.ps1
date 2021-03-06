﻿function Suspend-TNScan {
<#
    .SYNOPSIS
        Suspends a list of scans

    .DESCRIPTION
        Suspends a list of scans

    .PARAMETER SessionObject
        Optional parameter to force using specific SessionObjects. By default, each command will connect to all connected servers that have been connected to using Connect-TNServer

    .PARAMETER ScanId
        The ID of the target scan

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with 'sea of red' exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this 'nice by default' feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS C:\> Suspend-TNScan

        Suspends a list of scans

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]$SessionObject = (Get-TNSession),
        [Parameter(ValueFromPipelineByPropertyName)]
        [int32]$ScanId,
        [switch]$EnableException
    )
    process {
        foreach ($session in $SessionObject) {
            $PSDefaultParameterValues["*:SessionObject"] = $session
            foreach ($scan in (Invoke-TNRequest -SessionObject $session -EnableException:$EnableException -Path "/scans/$ScanId/pause" -Method 'Post').scan) {
                [pscustomobject]@{
                    Name            = $scan.name
                    ScanId          = $ScanId
                    HistoryId       = $scan.id
                    Status          = $scan.status
                    Enabled         = $scan.enabled
                    Owner           = $scan.owner
                    AlternateTarget = $scan.ownalt_targetser
                    IsPCI           = $scan.is_pci
                    UserPermission  = $permidenum[$scan.user_permissions]
                    CreationDate    = $origin.AddSeconds($scan.creation_date).ToLocalTime()
                    LastModified    = $origin.AddSeconds($scan.last_modification_date).ToLocalTime()
                    StartTime       = $origin.AddSeconds($scan.starttime).ToLocalTime()
                    SessionId       = $session.SessionId
                }
            }
        }
    }
}