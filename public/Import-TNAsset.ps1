function Import-TNAsset {
    <#
    .SYNOPSIS
        Imports asset files

    .DESCRIPTION
        Imports asset files

    .PARAMETER SessionObject
        Optional parameter to force using specific SessionObjects. By default, each command will connect to all connected servers that have been connected to using Connect-TNServer

    .PARAMETER FilePath
        The path to the asset file

    .PARAMETER NoRename
        By default, this command will remove "Imported Nessus Policy - " from the title of the imported file. Use this switch to keep the whole name "Imported Nessus Policy - Title of Policy"

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with 'sea of red' exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this 'nice by default' feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS C:\> Get-ChildItem C:\sc\asset_lists\acas_asset-Bad-Authentication-Capable-or-Credentials-Not-Provided.xml | Import-TNAsset

        Imports all .asset files matching DISA v2r2
#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]$SessionObject = (Get-TNSession),
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias("FullName")]
        [ValidateScript( { Test-Path -Path $_ })]
        [string[]]$FilePath,
        [switch]$EnableException
    )
    process {
        foreach ($session in $SessionObject) {
            if (-not $session.sc) {
                Stop-PSFFunction -EnableException:$EnableException -Message "Only tenable.sc supported" -Continue
            }

            foreach ($file in $FilePath) {
                $body = $file | Publish-File -Session $session -EnableException:$EnableException -Type Asset

                $params = @{
                    SessionObject = $session
                    Method        = "POST"
                    Path          = "/asset/import"
                    Parameter     = $body
                    ContentType   = "application/json"
                }

                Invoke-TnRequest @params | ConvertFrom-TNRestResponse
            }
        }
    }
}