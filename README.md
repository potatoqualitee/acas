<img align="left" src=https://user-images.githubusercontent.com/8278033/55955866-d3b64900-5c62-11e9-8175-92a8427d7f94.png alt="tentools logo"> tentools is PowerShell module automates tenable.sc and Nessus. It is a rewrite of Tenable's [Posh-Nessus](https://github.com/tenable/Posh-Nessus), which was created by [Carlos Perez](https://www.trustedsec.com/team/carlos-perez/).

This toolset extends Posh-Nessus by adding more functionality, including the ability to work with tenable.sc / SecurityCenter.

## Key links for reference:

- [ACAS overview](https://www.ask-ten.info/overview/) for discussion around contributing to the project
- [Tenable ACAS Blog](https://www.tenable.com/blog/tenable-selected-for-disa-s-ten-vulnerability-management-solution) for general discussion on the module and asking questions

## Installer

tentools works on PowerShell Core. This means that you can run all commands on <strong>Windows</strong>, <strong>Linux</strong> and <strong>macOS </strong>.

Run the following to install tentools from the PowerShell Gallery (to install on a server or for all users, remove the `-Scope` parameter and run in an elevated session):

```powershell
Install-Module tentools -Scope CurrentUser
```

If you need to install this module to an offline server, you can run

```powershell
Save-Module tentools -Path C:\temp
```
And it will save all dependent modules. You can also [download the zip](https://github.com/potatoqualitee/tentools/archive/master.zip) from our repo, but you'll also need to download [PSFramework](https://github.com/PowershellFrameworkCollective/psframework/archive/development.zip).

Please rename the folders from `name-master` to `name` and store in your `$Env:PSModulePath`.

## Usage scenarios

- Deploy standardized implementations
- Manage Nessus and tenable.sc at scale
- Manage some objects that are not available in the web interface

## Usage examples

Initalize a newly setup Nessus server with a license and username

```powershell
Initialize-TNServer -ComputerName securitycenter01 -Path $home\Downloads\nessus.license -Credential admin
```

Get a list of Organizations and Repositories using an Administrator account then create an Organization

```powershell
$admin = Get-Credential acasadmin
Connect-TNServer -ComputerName acas -Credential $admin
Get-TNOrganization
Get-TNRepository
New-TNOrganization -Name "Acme Corp"
```

Get a list of Scans using an Security Manager account

```powershell
$cred = Get-Credential secman
Connect-TNServer -ComputerName acas -Credential $cred
Get-TNScan
```

## Support

| Command | Nessus  | tenable.sc
|---|---|---|
|  Su-Tn | x  | x  |
|   |   |   |
|   |   |   |


* PowerShell v3 and above
* Windows, macOS and Linux
