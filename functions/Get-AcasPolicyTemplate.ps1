function Get-AcasPolicyTemplate {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER SessionId
    Parameter description

    .PARAMETER Name
    Parameter description

    .PARAMETER PolicyUUID
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
#>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param
    (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'All')]
        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(ParameterSetName = 'ByUUID')]
        [Alias('Index')]
        [int32[]]$SessionId = $global:NessusConn.SessionId,
        [Parameter(Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [string]$Name,
        [Parameter(Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByUUID')]
        [string]$PolicyUUID
    )
    process {
        $collection = @()

        foreach ($i in $SessionId) {
            $connections = $global:NessusConn

            foreach ($connection in $connections) {
                if ($connection.SessionId -eq $i) {
                    $collection += $connection
                }
            }
        }

        foreach ($connection in $collection) {
            $Templates = InvokeNessusRestRequest -SessionObject $connection -Path '/editor/policy/templates' -Method 'Get'

            if ($Templates -is [psobject]) {
                switch ($PSCmdlet.ParameterSetName) {
                    'ByName' {
                        $Templates2Proc = $Templates.templates | Where-Object {$_.name -eq $Name}
                    }

                    'ByUUID' {
                        $Templates2Proc = $Templates.templates | Where-Object {$_.uuid -eq $PolicyUUID}
                    }

                    'All' {
                        $Templates2Proc = $Templates.templates
                    }
                }

                foreach ($Template in $Templates2Proc) {
                    $TmplProps = [ordered]@{}
                    $TmplProps.add('Name', $Template.name)
                    $TmplProps.add('Title', $Template.title)
                    $TmplProps.add('Description', $Template.desc)
                    $TmplProps.add('PolicyUUID', $Template.uuid)
                    $TmplProps.add('CloudOnly', $Template.cloud_only)
                    $TmplProps.add('SubscriptionOnly', $Template.subscription_only)
                    $TmplProps.add('SessionId', $connection.SessionId)
                    $Tmplobj = New-Object -TypeName psobject -Property $TmplProps
                    $Tmplobj.pstypenames[0] = 'Nessus.PolicyTemplate'
                    $Tmplobj
                }
            }
        }
    }
}