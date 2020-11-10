function New-TNCredential {
    <#
    .SYNOPSIS
        Adds an organization

    .DESCRIPTION
        Adds an organization

    .PARAMETER Name
        Parameter description

    .PARAMETER ZoneSelection
        Parameter description

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS>  $params = @{
              Name = "Windows Scanner Account"
              Type = "windows"
              AuthType = "password"
              Credential = "ad\nessus"
        }
        PS>  New-TNCredential @params -Verbose

    #>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [string]$Name,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Description,
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [ValidateSet("apiGateway", "database", "windows", "snmp", "ssh")]
        [string]$Type,
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [ValidateSet("BeyondTrust", "cyberark", "Hashicorp", "kerberos", "lieberman", "lm", "ntlm", "password", "thycotic", "ibmDPGateway", "certificate", "publickey")]
        [string]$AuthType,
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [pscredential]$Credential,
        [hashtable]$CredentialHash,
        [switch]$EnableException
    )
    begin {
        if ($Type -notin "windows", "ssh" -and -not $PSBoundParameters.CredentailHash) {
            Stop-PSFFunction -Message "You must specify a CredentialHash when Type is $Type"
            return
        }
        if ($AuthType -eq "certificate" -and -not $PSBoundParameters.CredentailHash) {
            Stop-PSFFunction -Message "You must specify a CredentialHash when AuthType is $AuthType"
            return
        }
    }
    process {
        if (Test-PSFFunctionInterrupt) { return }

        foreach ($session in (Get-TNSession)) {
            if (-not $session.sc) {
                Stop-PSFFunction -Message "Only tenable.sc supported" -Continue
            }

            if (-not $PSBoundParameters.CredentailHash) {
                $body = @{
                    name        = $Name
                    description = $Description
                    type        = $Type
                    authType    = $AuthType
                }
            } else {
                $body = $PSBoundParameters.CredentailHash
                $body.Add("name", $Name)
                $body.Add("description", $Description)
                $body.Add("type", $Type)
                $body.Add("authType", $AuthType)
            }

            if ($PSBoundParameters.Credential) {
                if ($Type -eq "windows" -and $Credential.UserName -match "\\") {
                    $domain, $username = $Credential.UserName -split "\\"
                    $body.Add("domain", $domain)
                } else {
                    $username = $Credential.UserName
                }

                $body.Add("username", $username)
                $body.Add("password", ($Credential.GetNetworkCredential().Password))
            }

            $params = @{
                Path            = "/credential"
                Method          = "POST"
                Parameter       = $body
                EnableException = $EnableException
            }
            Invoke-TNRequest @params | ConvertFrom-TNRestResponse
        }
    }
}