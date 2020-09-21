function Get-AcasUser {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER SessionId
        ID of a valid Nessus session. This is auto-populated after a connection is made using Connect-AcasService.

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
        [int32[]]$SessionId = $script:NessusConn.SessionId,
        [switch]$EnableException
    )
    process {
        foreach ($session in (Get-AcasSession -SessionId $SessionId)) {
            $origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
            if ($session.sc) {
                $path = '/user'
            } else {
                $path = '/users'
            }
            $results = Invoke-AcasRequest -SessionObject $session -Path $path -Method 'Get'
            if ($results.users) {
                $users = $results.users
            } else {
                $users = $results
            }
            foreach ($user in $users) {
                [pscustomobject]@{ 
                    Name       = $user.name
                    UserName   = $user.username
                    Email      = $user.email
                    UserId     = $user.id
                    Type       = $user.type
                    Permission = $permidenum[$user.permissions]
                    LastLogin  = $origin.AddSeconds($user.lastlogin).ToLocalTime()
                    SessionId  = $session.SessionId
                }
            }
        }
    }
}