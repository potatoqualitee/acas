﻿function Remove-TNSession {
    <#
    .SYNOPSIS
        Removes a list of sessions

    .DESCRIPTION
        Removes a list of sessions

    .PARAMETER SessionId
        The target session ID

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with 'sea of red' exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this 'nice by default' feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS C:\> Remove-TNSession

        Removes a list of sessions

#>
    [CmdletBinding()]
    param(
        [int[]]$SessionId,
        [switch]$EnableException
    )
    process {
        # Finding and saving sessions in to a different Array so they can be
        # removed from the main one so as to not generate an modification
        # error for a collection in use.
        $sessions = $script:NessusConn
        $toremove = New-Object -TypeName System.Collections.ArrayList

        if ($SessionId.Count -gt 0) {
            foreach ($id in $SessionId) {
                Write-PSFMessage -Level Verbose -Message "Removing server session $id"

                foreach ($session in $sessions) {
                    if ($session.SessionId -eq $id) {
                        [void]$toremove.Add($session)
                    }
                }
            }

            foreach ($session in $toremove) {
                if (-not $session.sc) {
                    $uri = "/session"
                } else {
                    $uri = "/token"
                }
                Write-PSFMessage -Level Verbose -Message "Disposing of connection"
                $params = @{
                    SessionObject = $session
                    Method        = "DELETE"
                    Path          = $uri
                    ErrorVariable = "DisconnectError"
                    ErrorAction   = "SilentlyContinue"
                }
                try {
                    Invoke-TNRequest @params | ConvertFrom-TNRestResponse
                } catch {
                    Stop-PSFFunction -EnableException:$EnableException -Message "Session with Id $($session.SessionId) seems to have expired" -Continue -ErrorRecord $_
                }

                Write-PSFMessage -Level Verbose -Message "Removing session from `$script:NessusConn"
                $null = $script:NessusConn.Remove($session)
                Write-PSFMessage -Level Verbose -Message "Session $id removed"
            }
        }
    }
}