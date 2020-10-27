function New-TNUser {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER Credential
    Credential for connecting to the Nessus Server

    .PARAMETER Permission
        Parameter description

    .PARAMETER Type
        Parameter description

    .PARAMETER Email
        Parameter description

    .PARAMETER Name
        Parameter description

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS> Get-TN
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory)]
        [ValidateSet('Read-Only', 'Regular', 'Administrator', 'Sysadmin')]
        [string]$Permission,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Local', 'LDAP')]
        [string]$Type = 'Local',
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Email,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Name,
        [switch]$EnableException
    )
    process {
        foreach ($session in (Get-TNSession)) {
            $params = @{ }
            $params.Add('type', $Type.ToLower())
            $params.Add('permissions', $permenum[$Permission])
            $params.Add('username', $Credential.GetNetworkCredential().UserName)
            $params.Add('password', $Credential.GetNetworkCredential().Password)

            if ($Email.Length -gt 0) {
                $params.Add('email', $Email)
            }

            if ($Name.Length -gt 0) {
                $params.Add('name', $Name)
            }

            Invoke-TNRequest -SessionObject $session -EnableException:$EnableException -Path '/users' -Method 'Post' -Parameter $params
        }
    }
}