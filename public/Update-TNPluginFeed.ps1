function Update-TNPlugin {
    <#
    .SYNOPSIS
        Starts a list of scans

    .DESCRIPTION
        Starts a list of scans

    .PARAMETER SessionObject
        Optional parameter to force using specific SessionObjects. By default, each command will connect to all connected servers that have been connected to using Connect-TNServer

    .PARAMETER ScanId
        The ID of the target scan

    .PARAMETER AlternateTarget
        Description for AlternateTarget

    .PARAMETER Wait
        Wait for scan to finish before outputting results

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with 'sea of red' exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this 'nice by default' feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS C:\> Get-TNScan | Start-TNScan

        Starts every scan asynchronously

    .EXAMPLE
        PS C:\> Get-TNScan | Where-Object Id -eq 3 | Start-TNScan -Wait

        Starts a specific scan and waits for the scan to finish before outputting the results

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]$SessionObject = (Get-TNSession),
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript( { Test-Path -Path $_ })]
        [string]$FilePath,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet("Feed","ActivePlugin")]
        [string]$Type,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Wait,
        [switch]$EnableException
    )
    begin {
        switch ($Type) {
            "Feed" { $configtype = "feedUpdate"; $path = "sc" }
            "ActivePlugins" { $configtype = "pluginUpdate"; $path = "active" }
            "PassivePlugins" { $configtype = "passivePluginUpdate"; $path = "passive" }
            "Lce" { $configtype = "lcePluginUpdate"; $path = "lce" }
        }
    }
    process {
        foreach ($session in $SessionObject) {
            if (-not $session.sc) {
                Stop-PSFFunction -EnableException:$EnableException -Message "Only tenable.sc supported" -Continue
            }

            $files = Get-ChildItem -Path $FilePath

            foreach ($file in $files.FullName) {
                Write-ProgressHelper -TotalSteps 1 -StepNumber 1 -Activity "Uploading $file" -Message "Uploading..." -ExcludePercent
                $body = $file | Publish-File -Session $session -EnableException:$EnableException

                $params = @{
                    SessionObject = $session
                    Method        = "POST"
                    Path          = "/feed/$path/process"
                    Parameter     = $body
                    ContentType   = "application/json"
                }

                $null = Invoke-TnRequest @params | ConvertFrom-TNRestResponse
                if (-not $Wait) {
                    Get-TNFeedStatus -Session $session
                } else {
                    $stepnumber = 0
                    Start-Sleep 3
                    <#
                    SecurityCenterUpdateRunning : True
                    ActivePluginsUpdateRunning  : False
                    PassivePluginsUpdateRunning : False
                    IndustrialUpdateRunning     : False
                    LceRunning                  : False
                    #>
                    $result = Get-TNFeedStatus | Select-Object *Running
                    while ($result.SecurityCenterUpdateRunning -ne $true -and
                        $result.ActivePluginsUpdateRunning -ne $true -and
                        $result.PassivePluginsUpdateRunning -ne $true -and
                        $result.IndustrialUpdateRunning -ne $true -and
                        $result.LceRunning -ne $true -and
                        $stepnumber -lt 100) {
                        # Wait for it to start
                        Write-ProgressHelper -TotalSteps 100 -StepNumber ($stepnumber++) -Activity "Running update for $Type" -Message "Status: File uploaded, waiting for update to start"
                        Start-Sleep 1
                        $result = Get-TNFeedStatus | Select-Object *Running
                        $result
                    }
                    while ($result.SecurityCenterUpdateRunning -eq $true -or
                        $result.ActivePluginsUpdateRunning -eq $true -or
                        $result.PassivePluginsUpdateRunning -eq $true -or
                        $result.IndustrialUpdateRunning -eq $true -or
                        $result.LceRunning -eq $true) {
                        Start-Sleep -Seconds 1
                        if ($stepnumber -eq 100) {
                            $stepnumber = 0
                        } else {
                            Write-ProgressHelper -TotalSteps 100 -StepNumber ($stepnumber++) -Activity "Running update for $Type" -Message "Status: Updating $thing"
                        }
                        $result = Get-TNFeedStatus | Select-Object *Running
                    }
                    Get-TNFeedStatus -Session $session
                }
            }
        }
    }
}