﻿#
# Module manifest for module 'acastools'
#
# Generated by: Chrissy LeMaire & Joseph Warren
#
# Generated on: 4/8/2019
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule         = 'acastools.psm1'

    # Version number of this module.
    ModuleVersion      = '0.0.1'

    # ID used to uniquely identify this module
    GUID               = '1e19a8e4-ef98-4f0a-bd7d-f6613c3b7375'

    # Author of this module
    Author             = 'Chrissy LeMaire & Joseph Warren'

    # Company or vendor of this module
    CompanyName        = ''

    # Copyright statement for this module
    Copyright          = 'Copyright (c) 2019, licensed under MIT'

    # Description of the functionality provided by this module
    Description        = 'Automation for DISA ACAS, Tenable Nessus and more'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion  = '3.0'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules    = @('PSFramework', 'PoshRSJob')

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @('bin\RestSharp.dll')

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess   = @()

    # Functions to export from this module
    FunctionsToExport  = @(
        'Add-AcasGroupUser',
        'Add-AcasPluginRule',
        'Add-AcasPolicyPortRange',
        'Copy-AcasPolicy',
        'Disable-AcasPolicyLocalPortEnumeration',
        'Disable-AcasPolicyPortScanner',
        'Edit-AcasPluginRule',
        'Enable-AcasPolicyLocalPortEnumeration',
        'Enable-AcasPolicyPortScanner',
        'Export-AcasPolicy',
        'Export-AcasScan',
        'Get-AcasFolder',
        'Get-AcasGroup',
        'Get-AcasPluginFamily',
        'Get-AcasPluginRule',
        'Get-AcasPolicy',
        'Get-AcasPolicyDetail',
        'Get-AcasPolicyLocalPortEnumeration',
        'Get-AcasPolicyPortRange',
        'Get-AcasPolicyPortScanner',
        'Get-AcasPolicyTemplate',
        'Get-AcasScan',
        'Get-AcasScanTemplate',
        'Get-AcasServerInfo',
        'Get-AcasServerStatus',
        'Get-AcasSession',
        'Get-AcasSessionInfo',
        'Get-AcasUser',
        'Import-AcasPolicy',
        'Import-AcasScan',
        'New-AcasGroup',
        'New-AcasPolicy',
        'New-AcasScan',
        'Connect-AcasService',
        'New-AcasUser',
        'Remove-AcasGroup',
        'Remove-AcasGroupUser',
        'Remove-AcasPluginRule',
        'Remove-AcasPolicy',
        'Remove-AcasScan',
        'Remove-AcasScanHistory',
        'Remove-AcasSession',
        'Remove-AcasUser',
        'Rename-AcasGroup',
        'Resume-AcasScan',
        'Save-AcasPlugin',
        'Set-AcasPolicyPortRange',
        'Set-AcasUserPassword',
        'Get-AcasGroupMember',
        'Get-AcasPlugin',
        'Get-AcasPluginFamilyDetails',
        'Get-AcasScanDetail',
        'Get-AcasScanHistory',
        'Get-AcasScanHost',
        'Get-AcasScanHostDetail',
        'Start-AcasScan',
        'Stop-AcasScan',
        'Suspend-AcasScan',
        'Test-AcasAccessibility'
    )

    # Cmdlets to export from this module
    CmdletsToExport    = @()

    # Variables to export from this module
    VariablesToExport  = @()

    # Aliases to export from this module
    AliasesToExport    = @()

    PrivateData        = @{
        # PSData is module packaging and gallery metadata embedded in PrivateData
        # It's for rebuilding PowerShellGet (and PoshCode) NuGet-style packages
        # We had to do this because it's the only place we're allowed to extend the manifest
        # https://connect.microsoft.com/PowerShell/feedback/details/421837
        PSData = @{
            # The primary categorization of this module (from the TechNet Gallery tech tree).
            Category     = "Security"

            # Keyword tags to help users find this module via navigations and search.
            Tags         = @('nessus', 'tenable', 'acas', 'security', 'disa', 'dod')

            # The web address of an icon which can be used in galleries to represent this module
            IconUri      = "https://user-images.githubusercontent.com/8278033/55955866-d3b64900-5c62-11e9-8175-92a8427d7f94.png"

            # The web address of this module's project or support homepage.
            ProjectUri   = "https://github.com/potatoqualitee/acas"

            # The web address of this module's license. Points to a page that's embeddable and linkable.
            LicenseUri   = "https://opensource.org/licenses/MIT"

            # Release notes for this particular version of the module
            ReleaseNotes = ""

            # If true, the LicenseUrl points to an end-user license (not just a source license) which requires the user agreement before use.
            # RequireLicenseAcceptance = ""

            # Indicates this is a pre-release/testing version of the module.
            IsPrerelease = 'True'
        }
    }
}
