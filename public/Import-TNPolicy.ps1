function Import-TNPolicy {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER File
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
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript( { Test-Path -Path $_ })]
        [string[]]$FilePath,
        [switch]$EnableException
    )
    process {
        foreach ($session in (Get-TNSession)) {
            foreach ($file in $FilePath) {
                $fileinfo = Get-ItemProperty -Path $file
                $fullname = $fileinfo.FullName
                $restclient = New-Object RestSharp.RestClient
                $restrequest = New-Object RestSharp.RestRequest
                $restclient.UserAgent = 'tentools'
                $restclient.BaseUrl = $session.uri
                $restrequest.Method = [RestSharp.Method]::POST
                $restrequest.Resource = 'file/upload'
                $restclient.CookieContainer = $session.WebSession.Cookies
                [void]$restrequest.AddFile('Filedata', $fullname, 'application/octet-stream')

                foreach ($header in $session.Headers) {
                    [void]$restrequest.AddHeader($header.Keys, $header.Values)
                }
                $result = $restclient.Execute($restrequest)

                if ($result.ErrorMessage) {
                    Stop-PSFFunction -Message $result.ErrorMessage -Continue
                }
                $restparams = New-Object -TypeName System.Collections.Specialized.OrderedDictionary
                $restparams.add('file', "$($fileinfo.name)")
                if ($session.sc) {
                    $filename = ($result.Content | ConvertFrom-Json | Select-Object Response | ConvertFrom-TNRestResponse).Filename
                    $body = ConvertTo-Json @{'filename' = $filename; } -Compress
                } else {
                    $body = ConvertTo-Json @{'file' = $fileinfo.name; } -Compress
                }

                Invoke-TnRequest -Method Post -Path "/policies/import" -Parameter $body -ContentType 'application/json' -SessionObject $session |
                    ConvertFrom-TNRestResponse
            }
        }
    }
}