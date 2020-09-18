<img align="left" src=https://user-images.githubusercontent.com/8278033/55955866-d3b64900-5c62-11e9-8175-92a8427d7f94.png alt="acastools logo">  acas is PowerShell module helps automate DISA ACAS. It is a rewrite of Tenable's [Posh-Nessus](https://github.com/tenable/Posh-Nessus).

This toolset does this and that. If you have requests, please add them to the issues tab. Writing words here for now until better words can be worked out.

## Key links for reference:

- [acas overview](https://www.ask-Sc.info/overview/) for discussion around contributing to the project
- [Tenable Acas Blog](https://www.tenable.com/blog/tenable-selected-for-disa-s-Sc-vulnerability-management-solution) for general discussion on the module and asking questions

## Installer

acastools works on PowerShell Core (aka PowerShell 6+). This means that you can run all commands on <strong>Windows</strong>, <strong>Linux</strong> and <strong>macOS </strong>.

Run the following to install acastools from the PowerShell Gallery (to install on a server or for all users, remove the `-Scope` parameter and run in an elevated session):

```powershell
Install-Module acastools -Scope CurrentUser
```

If you need to install this module to an offline server, you can run

```powershell
Save-Module acastools -Path C:\temp
```
And it will save all dependent modules. You can also [download the zip](https://github.com/potatoqualitee/acas/archive/master.zip) from our repo, but you'll also need to download [PSFramework](https://github.com/PowershellFrameworkCollective/psframework/archive/development.zip) and [PoshRSJob](https://github.com/proxb/PoshRSJob/archive/master.zip).

Please rename the folders from `name-master` to `name` and store in your `$Env:PSModulePath`.

## Usage scenarios

- Do this
- Do that
- Do this

## Usage examples

Bunch of examples

```powershell
Connect-ScService -ComputerName acas -Credential acasadmin
```

## Support

* PowerShell v3 and above
* Windows, macOS and Linux
