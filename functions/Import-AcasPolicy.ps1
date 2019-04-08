function Import-AcasPolicy {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER SessionId
    Parameter description

    .PARAMETER File
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param
    (
        # Nessus session Id
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true)]
        [Alias('Index')]
        [int32[]]
        $SessionId,

        [Parameter(Mandatory = $true,
            Position = 1,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateScript( {Test-Path -Path $_})]
        [string]
        $File
    )

    begin {

        $ContentType = 'application/octet-stream'
        $URIPath = 'file/upload'

        $netAssembly = [Reflection.Assembly]::GetAssembly([System.Net.Configuration.SettingsSection])

        if ($netAssembly) {
            $bindingFlags = [Reflection.BindingFlags] "Static,GetProperty,NonPublic"
            $settingsType = $netAssembly.GetType("System.Net.Configuration.SettingsSectionInternal")

            $instance = $settingsType.InvokeMember("Section", $bindingFlags, $null, $null, @())

            if ($instance) {
                $bindingFlags = "NonPublic", "Instance"
                $useUnsafeHeaderParsingField = $settingsType.GetField("useUnsafeHeaderParsing", $bindingFlags)

                if ($useUnsafeHeaderParsingField) {
                    $useUnsafeHeaderParsingField.SetValue($instance, $true)
                }
            }
        }

        $origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
    }
    process {
        $ToProcess = @()

        foreach ($i in $SessionId) {
            $Connections = $Global:NessusConn

            foreach ($Connection in $Connections) {
                if ($Connection.SessionId -eq $i) {
                    $ToProcess += $Connection
                }
            }
        }

        foreach ($Connection in $ToProcess) {
            $fileinfo = Get-ItemProperty -Path $File
            $FilePath = $fileinfo.FullName
            $RestClient = New-Object RestSharp.RestClient
            $RestRequest = New-Object RestSharp.RestRequest
            $RestClient.UserAgent = 'Posh-SSH'
            $RestClient.BaseUrl = $Connection.uri
            $RestRequest.Method = [RestSharp.Method]::POST
            $RestRequest.Resource = $URIPath

            [void]$RestRequest.AddFile('Filedata', $FilePath, 'application/octet-stream')
            [void]$RestRequest.AddHeader('X-Cookie', "token=$($Connection.Token)")
            $result = $RestClient.Execute($RestRequest)
            if ($result.ErrorMessage.Length -gt 0) {
                Write-Error -Message $result.ErrorMessage
            } else {
                $RestParams = New-Object -TypeName System.Collections.Specialized.OrderedDictionary
                $RestParams.add('file', "$($fileinfo.name)")
                if ($Encrypted) {
                    $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList 'user', $Password
                    $RestParams.Add('password', $Credentials.GetNetworkCredential().Password)
                }

                $impParams = @{ 'Body' = $RestParams }
                $Policy = Invoke-RestMethod -Method Post -Uri "$($Connection.URI)/policies/import" -header @{'X-Cookie' = "token=$($Connection.Token)"} -Body (ConvertTo-Json @{'file' = $fileinfo.name; } -Compress) -ContentType 'application/json'
                $PolProps = [ordered]@{}
                $PolProps.Add('Name', $Policy.Name)
                $PolProps.Add('PolicyId', $Policy.id)
                $PolProps.Add('Description', $Policy.description)
                $PolProps.Add('PolicyUUID', $Policy.template_uuid)
                $PolProps.Add('Visibility', $Policy.visibility)
                $PolProps['Shared'] = & { if ($Policy.shared -eq 1) {$True}else {$False}}
                $PolProps.Add('Owner', $Policy.owner)
                $PolProps.Add('UserId', $Policy.owner_id)
                $PolProps.Add('NoTarget', $Policy.no_target)
                $PolProps.Add('UserPermission', $Policy.user_permissions)
                $PolProps.Add('Modified', $origin.AddSeconds($Policy.last_modification_date).ToLocalTime())
                $PolProps.Add('Created', $origin.AddSeconds($Policy.creation_date).ToLocalTime())
                $PolProps.Add('SessionId', $Connection.SessionId)
                $PolObj = [PSCustomObject]$PolProps
                $PolObj.pstypenames.insert(0, 'Nessus.Policy')
                $PolObj
            }
        }
    }
    end {}
}