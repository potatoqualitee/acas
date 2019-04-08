function Get-AcasSession {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER SessionId
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('Index')]
        [int32[]]$SessionId
    )
    process {
        if ($Index.Count -gt 0) {
            foreach ($i in $SessionId) {
                foreach ($Connection in $Global:NessusConn) {
                    if ($Connection.SessionId -eq $i) {
                        $Connection
                    }
                }
            }
        } else {
            # Return all sessions.
            $return_sessions = @()
            foreach ($s in $Global:NessusConn) {$s}
        }
    }
}