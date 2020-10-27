function Remove-TNScanHistory {
    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER ScanId
        Parameter description

    .PARAMETER HistoryId
        Parameter description

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS> Get-TN
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int32]$ScanId,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int32]$HistoryId,
        [switch]$EnableException
    )
    process {
        foreach ($session in (Get-TNSession)) {
            Write-PSFMessage -Level Verbose -Message "Removing history Id ($HistoryId) from scan Id $ScanId"
            Invoke-TNRequest -SessionObject $session -EnableException:$EnableException -Path "/scans/$ScanId/history/$HistoryId" -Method 'Delete' -Parameter $params
            Write-PSFMessage -Level Verbose -Message 'History Removed'
        }
    }
}