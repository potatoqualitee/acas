function Set-TenUserPassword {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER UserId
        Parameter description

    .PARAMETER Password
        Parameter description

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS> Get-Ten

    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int32[]]$UserId,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [securestring]$Password,
        [switch]$EnableException
    )
    process {
        foreach ($session in (Get-TenSession)) {
            foreach ($uid in $UserId) {
                Write-PSFMessage -Level Verbose -Message "Updating user with Id $uid"
                $params = @{'password' = $([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))) }
                $paramJson = ConvertTo-Json -InputObject $params -Compress
                Invoke-TenRequest -SessionObject $session -Path "/users/$uid/chpasswd" -Method 'PUT' -Parameter $paramJson -ContentType 'application/json'
            }
        }
    }
}