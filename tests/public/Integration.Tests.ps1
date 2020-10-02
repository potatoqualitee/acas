﻿Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot\..\constants.ps1"


Describe "Integration Tests" -Tag "IntegrationTests" {
    BeforeAll {
        # Give it time to do whatever it needs to do
        Wait-TenServerReady -ComputerName localhost
    }
    BeforeEach {
        Write-Output -Message "Next test"
    }
    Context "Connect-TenServer" {
        It "Connects to a site" {
            $cred = New-Object -TypeName PSCredential -ArgumentList "admin", (ConvertTo-SecureString -String admin123 -AsPlainText -Force)
            $splat = @{
                ComputerName         = "localhost"
                AcceptSelfSignedCert = $true
                Credential           = $cred
                EnableException      = $true
                Port                 = 8834
            }
            (Connect-TenServer @splat).ComputerName | Should -Be "localhost"
        }
    }

    Context "Get-TenUser" {
        It "Returns a user" {
            Get-TenUser | Select-Object -ExpandProperty name | Should -Contain "admin"
        }
    }
    Context "Get-TenFolder" {
        It "Returns a folder" {
            Get-TenFolder | Select-Object -ExpandProperty name | Should -Contain "Trash"
        }
    }
    Context "Get-TenPlugin" {
        It "Returns proper plugin information" {
            $results = Get-TenPlugin -PluginId 10714
            $results | Select-Object -ExpandProperty Name | Should -Be 'ZyXEL Router Default Telnet Password Present'
            $results | Select-Object -ExpandProperty PluginId | Should -Be 10714
            ($results | Select-Object -ExpandProperty Attributes).fname | Should -Be 'zyxel_pwd.nasl'
        }
    }
}