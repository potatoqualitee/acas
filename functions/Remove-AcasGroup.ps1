function Remove-AcasGroup {
    <#
    .SYNOPSIS
        Short description
    
    .DESCRIPTION
        Long description
    
    .PARAMETER SessionId
        ID of a valid Nessus session. This is auto-populated after a connection is made using Connect-AcasService.
    
    .PARAMETER GroupId
        Parameter description

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS> Get-Acas
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('Index')]
        [int32[]]$SessionId = $global:NessusConn.SessionId,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [Int32]$GroupId,
        [switch]$EnableException
    )
    process {
        foreach ($session in (Get-AcasSession -SessionId $SessionId)) {
            $serverparams = @{
                SessionObject = $session
                Path          = '/server/properties'
                Method        = 'GET'
            }

            $Server = Invoke-AcasRequest @serverparams

            if ($Server.capabilities.multi_user -eq 'full') {
                $groupparams = @{
                    SessionObject = $session
                    Path          = "/groups/$($GroupId)"
                    Method        = 'DELETE '
                }

                Invoke-AcasRequest @groupparams
            }
            else {
                Write-PSFMessage -Level Warning -Message "Server for session $($connection.sessionid) is not licenced for multiple users."
            }
        }
    }
}