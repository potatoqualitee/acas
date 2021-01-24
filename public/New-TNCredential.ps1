﻿function New-TNCredential {
    <#
    .SYNOPSIS
        Creates new credentials

    .DESCRIPTION
        Creates new credentials

    .PARAMETER SessionObject
        Optional parameter to force using specific SessionObjects. By default, each command will connect to all connected servers that have been connected to using Connect-TNServer

    .PARAMETER Name
        The name of the target credential

    .PARAMETER Description
        Description for Description

    .PARAMETER Type
        The type of credential

    .PARAMETER AuthType
        Description for AuthType

    .PARAMETER Credential
        The credential object (from Get-Credential) used to log into the target server. Specifies a user account that has permission to send the request.

    .PARAMETER CredentialHash
        Description for CredentialHash

    .PARAMETER PrivilegeEscalation
        Description for PrivilegeEscalation

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with 'sea of red' exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this 'nice by default' feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS C:\> $params = @{
              Name = "Windows Scanner Account"
              Type = "windows"
              AuthType = "password"
              Credential = "ad\nessus"
        }
        PS C:\> New-TNCredential @params -Verbose

        Creates a new Windows credential for ad\nessus

    .EXAMPLE
        PS C:\> $params = @{
              Name = "Linux Scanner Account"
              Type = "ssh"
              AuthType = "password"
              Credential = "acasaccount"
              PrivilegeEscalation = "sudo"
        }

        PS C:\> New-TNCredential @params -Verbose

        Creates a new SSH credential for acasaccount and sets the escalation type to sudo
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "")]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]$SessionObject = (Get-TNSession),
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
        [psobject]$Credential,
        [hashtable]$CredentialHash,
        [ValidateSet("none", "su", "sudo", "su+sudo", "dzdo", "pbrun", "cisco", ".k5login")]
        [string]$PrivilegeEscalation = "none",
        [switch]$EnableException
    )
    begin {
        if ($Type -notin "windows", "ssh" -and -not $PSBoundParameters.CredentialHash) {
            Stop-PSFFunction -Message "You must specify a CredentialHash when Type is $Type"
            return
        }
        if ($AuthType -eq "certificate" -and -not $PSBoundParameters.CredentialHash) {
            Stop-PSFFunction -Message "You must specify a CredentialHash when AuthType is $AuthType"
            return
        }

        if ($Credential -isnot [pscredential]) {
            $Credential = Get-Credential $Credential -Message "Enter the username and password for the $Name credential"
        }
    }
    process {
        if (Test-PSFFunctionInterrupt) { return }

        foreach ($session in $SessionObject) {
            if (-not $session.sc) {
                Stop-PSFFunction -EnableException:$EnableException -Message "Only tenable.sc supported" -Continue
            }

            if (-not $PSBoundParameters.CredentialHash) {
                $body = @{
                    name        = $Name
                    description = $Description
                    type        = $Type.ToLower()
                    authType    = $AuthType.ToLower()
                }
            } else {
                $body = $PSBoundParameters.CredentialHash
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

                if ($Type -eq "ssh") {
                    $body.Add("privilegeEscalation", $PrivilegeEscalation.ToLower())
                }
                $body.Add("username", $username)
                $body.Add("password", ($Credential.GetNetworkCredential().Password))
            }

            $params = @{
                SessionObject   = $session
                Path            = "/credential"
                Method          = "POST"
                Parameter       = $body
                EnableException = $EnableException
            }

            Invoke-TNRequest @params | ConvertFrom-TNRestResponse
        }
    }
}