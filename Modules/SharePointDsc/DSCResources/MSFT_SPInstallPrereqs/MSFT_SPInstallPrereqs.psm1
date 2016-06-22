function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]  [System.String]  $InstallerPath,
        [parameter(Mandatory = $true)]  [System.Boolean] $OnlineMode,
        [parameter(Mandatory = $false)] [System.String]  $SXSpath,
        [parameter(Mandatory = $false)] [System.String]  $SQLNCli,        
        [parameter(Mandatory = $false)] [System.String]  $PowerShell,        
        [parameter(Mandatory = $false)] [System.String]  $NETFX,        
        [parameter(Mandatory = $false)] [System.String]  $IDFX,        
        [parameter(Mandatory = $false)] [System.String]  $Sync,        
        [parameter(Mandatory = $false)] [System.String]  $AppFabric,        
        [parameter(Mandatory = $false)] [System.String]  $IDFX11,        
        [parameter(Mandatory = $false)] [System.String]  $MSIPCClient,        
        [parameter(Mandatory = $false)] [System.String]  $WCFDataServices,        
        [parameter(Mandatory = $false)] [System.String]  $KB2671763,        
        [parameter(Mandatory = $false)] [System.String]  $WCFDataServices56,
        [parameter(Mandatory = $false)] [System.String]  $MSVCRT11,
        [parameter(Mandatory = $false)] [System.String]  $MSVCRT14,
        [parameter(Mandatory = $false)] [System.String]  $KB3092423,
        [parameter(Mandatory = $false)] [System.String]  $ODBC,
        [parameter(Mandatory = $false)] [System.String]  $DotNetFx,
        [parameter(Mandatory = $false)] [ValidateSet("Present","Absent")] [System.String] $Ensure = "Present"
    )
    
    $returnValue = @{}
    Write-Verbose -Message "Detecting SharePoint version from binaries"
    $majorVersion = (Get-SPDSCAssemblyVersion -PathToAssembly $InstallerPath)
    if ($majorVersion -eq 15) {
        Write-Verbose -Message "Version: SharePoint 2013"
    }
    if ($majorVersion -eq 16) {
        Write-Verbose -Message "Version: SharePoint 2016"
    }

    Write-Verbose -Message "Getting installed windows features"
        
    if ($majorVersion -eq 15) {
        $WindowsFeatures = Get-WindowsFeature -Name Application-Server, AS-NET-Framework, AS-TCP-Port-Sharing, AS-Web-Support, AS-WAS-Support, AS-HTTP-Activation, AS-Named-Pipes, AS-TCP-Activation, Web-Server, Web-WebServer, Web-Common-Http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect, Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Dyn-Compression, Web-Security, Web-Filtering, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Cert-Auth, Web-IP-Security, Web-Url-Auth, Web-Windows-Auth, Web-App-Dev, Web-Net-Ext, Web-Net-Ext45, Web-Asp-Net, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Tools, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Lgcy-Scripting, Web-WMI, Web-Scripting-Tools, NET-Framework-Features, NET-Framework-Core, NET-Framework-45-ASPNET, NET-WCF-HTTP-Activation45, NET-WCF-Pipe-Activation45, NET-WCF-TCP-Activation45, Server-Media-Foundation, Windows-Identity-Foundation, PowerShell-V2, WAS, WAS-Process-Model, WAS-NET-Environment, WAS-Config-APIs, XPS-Viewer
    }
    if ($majorVersion -eq 16) {
        $osVersion = [System.Environment]::OSVersion.Version.Major
        if ($osVersion -eq 10) {
            # Server 2016
            $WindowsFeatures = Get-WindowsFeature -Name Web-Server, Web-WebServer, Web-Common-Http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Dyn-Compression, Web-Security, Web-Filering, Web-Basic-Auth, Web-Digest-Auth, Web-Windows-Auth, Web-App-Dev, Web-Net-Ext, Web-Net-Ext45Web-Asp-Net, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Tools, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Lgcy-Scripting, Web-WMI, NET-Framework-Features, NET-HTTP-Activation, NET-Non-HTTP-Activ, NET-Framework-45-ASPNET, NET-WCF-Pipe-Activation45, Windows-Identity-Foundation, WAS, WAS-Process-Model, WAS-NET-Environment, WAS-Config-APIs, XPS-Viewer
        } else {
            # Server 2012 R2
            $WindowsFeatures = Get-WindowsFeature -Name Application-Server, AS-NET-Framework, AS-Web-Support, Web-Server, Web-WebServer, Web-Common-Http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect, Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Performance, Web-Stat-Compression, Web-Dyn-Compression, Web-Security, Web-Filtering, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Cert-Auth, Web-IP-Security, Web-Url-Auth, Web-Windows-Auth, Web-App-Dev, Web-Net-Ext, Web-Net-Ext45, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Tools, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Lgcy-Mgmt-Console, Web-Lgcy-Scripting, Web-WMI, Web-Scripting-Tools, NET-Framework-Features, NET-Framework-Core, NET-HTTP-Activation, NET-Non-HTTP-Activ, NET-Framework-45-ASPNET, NET-WCF-HTTP-Activation45, Windows-Identity-Foundation, PowerShell-V2, WAS, WAS-Process-Model, WAS-NET-Environment, WAS-Config-APIs    
        }
        
    }
    
    foreach ($feature in $WindowsFeatures) {
        $returnValue.Add($feature.Name, $feature.Installed)
    }

    Write-Verbose -Message "Checking windows packages"
	$installedItemsX86 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher
	$installedItemsX64 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher
	$installedItems = $installedProductsX86+$installedProductsX64 | Sort-Object -Property DisplayName -Unique	
    
    #Common prereqs
    $returnValue.Add("AppFabric 1.1 for Windows Server", (($installedItems | ? {$_.DisplayName -eq "AppFabric 1.1 for Windows Server"}) -ne $null))
    $returnValue.Add("Microsoft CCR and DSS Runtime 2008 R3", (($installedItems | ? {$_.DisplayName -eq "Microsoft CCR and DSS Runtime 2008 R3"}) -ne $null))
    $returnValue.Add("Microsoft Identity Extensions", (@(Get-ChildItem HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\ -Recurse | ? {$_.GetValue("DisplayName") -eq "Microsoft Identity Extensions" }).Count -gt 0))    
    $returnValue.Add("Microsoft Sync Framework Runtime v1.0 SP1 (x64)", (($installedItems | ? {$_.DisplayName -eq "Microsoft Sync Framework Runtime v1.0 SP1 (x64)"}) -ne $null))
    $returnValue.Add("WCF Data Services 5.6.0 Runtime", (($installedItems | ? {$_.DisplayName -eq "WCF Data Services 5.6.0 Runtime"}) -ne $null))

    #SP2013 prereqs
    if ($majorVersion -eq 15) {
        $returnValue.Add("Active Directory Rights Management Services Client 2.*", (($installedItems | ? {$_.DisplayName -like "Active Directory Rights Management Services Client 2.*"}) -ne $null))
        $returnValue.Add("Microsoft SQL Server 2008 R2 Native Client", (($installedItems | ? {$_.DisplayName -eq "Microsoft SQL Server 2008 R2 Native Client"}) -ne $null))
        $returnValue.Add("WCF Data Services 5.0 (for OData v3) Primary Components", (($installedItems | ? {$_.DisplayName -eq "WCF Data Services 5.0 (for OData v3) Primary Components"}) -ne $null))
    }

    #SP2016 prereqs
    if ($majorVersion -eq 16) {
        $returnValue.Add("Active Directory Rights Management Services Client 2.1", (($installedItems | ? {$_.DisplayName -eq "Active Directory Rights Management Services Client 2.1"}) -ne $null))
        $returnValue.Add("Microsoft SQL Server 2012 Native Client", (($installedItems | ? {$_.DisplayName -ne $null -and $_.DisplayName.Trim() -eq "Microsoft SQL Server 2012 Native Client"}) -ne $null))    
        $returnValue.Add("Microsoft ODBC Driver 11 for SQL Server", (($installedItems | ? {$_.DisplayName -eq "Microsoft ODBC Driver 11 for SQL Server"}) -ne $null))    
        $returnValue.Add("Microsoft Visual C++ 2012 x64 Minimum Runtime - 11.0.61030", (($installedItems | ? {$_.DisplayName -eq "Microsoft Visual C++ 2012 x64 Minimum Runtime - 11.0.61030"}) -ne $null))    
        $returnValue.Add("Microsoft Visual C++ 2012 x64 Additional Runtime - 11.0.61030", (($installedItems | ? {$_.DisplayName -eq "Microsoft Visual C++ 2012 x64 Additional Runtime - 11.0.61030"}) -ne $null))
        $returnValue.Add("Microsoft Visual C++ 2015 x64 Minimum Runtime - 14.0.23026", (($installedItems | ? {$_.DisplayName -eq "Microsoft Visual C++ 2015 x64 Minimum Runtime - 14.0.23026"}) -ne $null))    
        $returnValue.Add("Microsoft Visual C++ 2015 x64 Additional Runtime - 14.0.23026", (($installedItems | ? {$_.DisplayName -eq "Microsoft Visual C++ 2015 x64 Additional Runtime - 14.0.23026"}) -ne $null))            
    }
        
    $results = @{
        InstallerPath = $InstallerPath
        OnlineMode = $OnlineMode
        SQLNCli = $SQLNCli      
        PowerShell = $PowerShell        
        NETFX = $NETFX    
        IDFX = $IDFX        
        Sync = $Sync        
        AppFabric = $AppFabric        
        IDFX11 = $IDFX11      
        MSIPCClient = $MSIPCClient        
        WCFDataServices = $WCFDataServices        
        KB2671763 = $KB2671763   
        WCFDataServices56 = $WCFDataServices56        
        KB2898850 = $KB2898850 
        MSVCRT11 = $MSVCRT11
        MSVCRT14 = $MSVCRT14
        KB3092423 = $KB3092423
        ODBC = $ODBC
        DotNet452 = $DotNet452
    }
    
    if (($returnValue.Values | Where-Object { $_ -eq $false }).Count -gt 0) {
        $results.Ensure = "Absent"
    } else {
        $results.Ensure = "Present"
    }
    
    return $results
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]  [System.String]  $InstallerPath,
        [parameter(Mandatory = $true)]  [System.Boolean] $OnlineMode,
        [parameter(Mandatory = $false)] [System.String]  $SXSpath,
        [parameter(Mandatory = $false)] [System.String]  $SQLNCli,        
        [parameter(Mandatory = $false)] [System.String]  $PowerShell,        
        [parameter(Mandatory = $false)] [System.String]  $NETFX,        
        [parameter(Mandatory = $false)] [System.String]  $IDFX,        
        [parameter(Mandatory = $false)] [System.String]  $Sync,        
        [parameter(Mandatory = $false)] [System.String]  $AppFabric,        
        [parameter(Mandatory = $false)] [System.String]  $IDFX11,        
        [parameter(Mandatory = $false)] [System.String]  $MSIPCClient,        
        [parameter(Mandatory = $false)] [System.String]  $WCFDataServices,        
        [parameter(Mandatory = $false)] [System.String]  $KB2671763,        
        [parameter(Mandatory = $false)] [System.String]  $WCFDataServices56,        
        [parameter(Mandatory = $false)] [System.String]  $MSVCRT11,
        [parameter(Mandatory = $false)] [System.String]  $MSVCRT14,
        [parameter(Mandatory = $false)] [System.String]  $KB3092423,
        [parameter(Mandatory = $false)] [System.String]  $ODBC,
        [parameter(Mandatory = $false)] [System.String]  $DotNetFx,
        [parameter(Mandatory = $false)] [ValidateSet("Present","Absent")] [System.String] $Ensure = "Present"
    )

    if ($Ensure -eq "Absent") {
        throw [Exception] "SharePOintDSC does not support uninstalling SharePoint or its prerequisites. Please remove this manually."
        return
    }

Write-Verbose -Message "Detecting SharePoint version from binaries"
    $majorVersion = (Get-SPDSCAssemblyVersion -PathToAssembly $InstallerPath)
    if ($majorVersion -eq 15) {
        $dotNet46Check = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse | Get-ItemProperty -name Version,Release -EA 0 | Where { $_.PSChildName -match '^(?!S)\p{L}' -and $_.Version -like "4.6.*"}
        if ($dotNet46Check -ne $null -and $dotNet46Check.Length -gt 0) {
            throw [Exception] "A known issue prevents installation of SharePoint 2013 on servers that have .NET 4.6 already installed. See details at https://support.microsoft.com/en-us/kb/3087184"
            return
        }
        
        Write-Verbose -Message "Version: SharePoint 2013"
        $requiredParams = @("SQLNCli","PowerShell","NETFX","IDFX","Sync","AppFabric","IDFX11","MSIPCClient","WCFDataServices","KB2671763","WCFDataServices56")
        $WindowsFeatures = Get-WindowsFeature -Name Application-Server, AS-NET-Framework, AS-TCP-Port-Sharing, AS-Web-Support, AS-WAS-Support, AS-HTTP-Activation, AS-Named-Pipes, AS-TCP-Activation, Web-Server, Web-WebServer, Web-Common-Http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect, Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Dyn-Compression, Web-Security, Web-Filtering, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Cert-Auth, Web-IP-Security, Web-Url-Auth, Web-Windows-Auth, Web-App-Dev, Web-Net-Ext, Web-Net-Ext45, Web-Asp-Net, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Tools, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Lgcy-Scripting, Web-WMI, Web-Scripting-Tools, NET-Framework-Features, NET-Framework-Core, NET-Framework-45-ASPNET, NET-WCF-HTTP-Activation45, NET-WCF-Pipe-Activation45, NET-WCF-TCP-Activation45, Server-Media-Foundation, Windows-Identity-Foundation, PowerShell-V2, WAS, WAS-Process-Model, WAS-NET-Environment, WAS-Config-APIs, XPS-Viewer
    }
    if ($majorVersion -eq 16) {
        Write-Verbose -Message "Version: SharePoint 2016"
        $requiredParams = @("SQLNCli","Sync","AppFabric","IDFX11","MSIPCClient","KB3092423","WCFDataServices56","DotNetFx","MSVCRT11","MSVCRT14","ODBC")
        $osVersion = [System.Environment]::OSVersion.Version.Major
        if ($osVersion -eq 10) {
            # Server 2016
            $WindowsFeatures = Get-WindowsFeature -Name Web-Server, Web-WebServer, Web-Common-Http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Dyn-Compression, Web-Security, Web-Filering, Web-Basic-Auth, Web-Digest-Auth, Web-Windows-Auth, Web-App-Dev, Web-Net-Ext, Web-Net-Ext45Web-Asp-Net, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Tools, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Lgcy-Scripting, Web-WMI, NET-Framework-Features, NET-HTTP-Activation, NET-Non-HTTP-Activ, NET-Framework-45-ASPNET, NET-WCF-Pipe-Activation45, Windows-Identity-Foundation, WAS, WAS-Process-Model, WAS-NET-Environment, WAS-Config-APIs, XPS-Viewer
        } else {
            # Server 2012 R2
            $WindowsFeatures = Get-WindowsFeature -Name Application-Server, AS-NET-Framework, AS-Web-Support, Web-Server, Web-WebServer, Web-Common-Http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect, Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Performance, Web-Stat-Compression, Web-Dyn-Compression, Web-Security, Web-Filtering, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Cert-Auth, Web-IP-Security, Web-Url-Auth, Web-Windows-Auth, Web-App-Dev, Web-Net-Ext, Web-Net-Ext45, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Tools, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Lgcy-Mgmt-Console, Web-Lgcy-Scripting, Web-WMI, Web-Scripting-Tools, NET-Framework-Features, NET-Framework-Core, NET-HTTP-Activation, NET-Non-HTTP-Activ, NET-Framework-45-ASPNET, NET-WCF-HTTP-Activation45, Windows-Identity-Foundation, PowerShell-V2, WAS, WAS-Process-Model, WAS-NET-Environment, WAS-Config-APIs    
        }
    }
    
    if ($SXSpath){ #SXSstore for feature install specified, we will manually install features from the store, rather then relying on the prereq installer to download them
        Write-Verbose -Message "Getting installed windows features"
        foreach ($feature in $WindowsFeatures) {
         if ($feature.Installed -ne $true) {
            $FeatureParms = @{name = $feature.name}
            $FeatureParms.Add("Source",$SXSpath) 
            Write-Verbose "Installing $($feature.name)"
            $FeatureInstallResult = Install-WindowsFeature @FeatureParms
            if ($FeatureInstallResult.restartneeded -eq "yes") {$global:DSCMachineStatus = 1}
            if ($FeatureInstallResult.Success -ne $true) { throw "Error installing $($feature.name) "}
         }
       }
    
       #see if we need to reboot after feature install
       if ($global:DSCMachineStatus -eq 1) {return} 
    
    }
    
    $prereqArgs = "/unattended"
    if ($OnlineMode -eq $false) {
        $requiredParams | ForEach-Object {
            if (($PSBoundParameters.ContainsKey($_) -and [string]::IsNullOrEmpty($PSBoundParameters.$_)) -or (-not $PSBoundParameters.ContainsKey($_))) {
                throw "In offline mode for version $majorVersion parameter $_ is required"
            }
            if ((Test-Path $PSBoundParameters.$_) -eq $false) {
                throw "The $_ parameter has been passed but the file cannot be found at the path supplied: `"$($PSBoundParameters.$_)`""
            }
        }
        $requiredParams | ForEach-Object {
            $prereqArgs += " /$_`:`"$($PSBoundParameters.$_)`""
        }
    }

    Write-Verbose -Message "Calling the SharePoint Pre-req installer"
    Write-Verbose -Message "Args for prereq installer are: $prereqArgs"
    $process = Start-Process -FilePath $InstallerPath -ArgumentList $prereqArgs -Wait -PassThru

    switch ($process.ExitCode) {
        0 {
            Write-Verbose -Message "Prerequisite installer completed successfully."
        }
        1 {
            throw "Another instance of the prerequisite installer is already running"
        }
        2 {
            throw "Invalid command line parameters passed to the prerequisite installer"
        }
        1001 {
            Write-Verbose -Message "A pending restart is blocking the prerequisite installer from running. Scheduling a reboot."
            $global:DSCMachineStatus = 1
        }
        3010 {
            Write-Verbose -Message "The prerequisite installer has run correctly and needs to reboot the machine before continuing."
            $global:DSCMachineStatus = 1
        }
        default {
            throw "The prerequisite installer ran with the following unknown exit code $($process.ExitCode)"
        }
    }
    
    if ( `
        ((Get-Item 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' -ErrorAction SilentlyContinue) -ne $null) `
         -or `
        ((Get-Item 'HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' -ErrorAction SilentlyContinue) -ne $null) `
        -or `
        ((Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' | Get-ItemProperty).PendingFileRenameOperations.count -gt 0) `
        ) {
            Write-Verbose -Message "xSPInstallPrereqs has detected the server has pending a reboot. Flagging to the DSC engine that the server should reboot before continuing."
            $global:DSCMachineStatus = 1   
        }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]  [System.String]  $InstallerPath,
        [parameter(Mandatory = $true)]  [System.Boolean] $OnlineMode,
        [parameter(Mandatory = $false)] [System.String]  $SXSpath,
        [parameter(Mandatory = $false)] [System.String]  $SQLNCli,        
        [parameter(Mandatory = $false)] [System.String]  $PowerShell,        
        [parameter(Mandatory = $false)] [System.String]  $NETFX,        
        [parameter(Mandatory = $false)] [System.String]  $IDFX,        
        [parameter(Mandatory = $false)] [System.String]  $Sync,        
        [parameter(Mandatory = $false)] [System.String]  $AppFabric,        
        [parameter(Mandatory = $false)] [System.String]  $IDFX11,        
        [parameter(Mandatory = $false)] [System.String]  $MSIPCClient,        
        [parameter(Mandatory = $false)] [System.String]  $WCFDataServices,        
        [parameter(Mandatory = $false)] [System.String]  $KB2671763,        
        [parameter(Mandatory = $false)] [System.String]  $WCFDataServices56,        
        [parameter(Mandatory = $false)] [System.String]  $MSVCRT11,
        [parameter(Mandatory = $false)] [System.String]  $MSVCRT14,
        [parameter(Mandatory = $false)] [System.String]  $KB3092423,
        [parameter(Mandatory = $false)] [System.String]  $ODBC,
        [parameter(Mandatory = $false)] [System.String]  $DotNetFx,
        [parameter(Mandatory = $false)] [ValidateSet("Present","Absent")] [System.String] $Ensure = "Present"
    )

    if ($Ensure -eq "Absent") {
        throw [Exception] "SharePointDsc does not support uninstalling SharePoint or its prerequisites. Please remove this manually."
        return
    }

    $PSBoundParameters.Ensure = $Ensure
    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Checking installation of SharePoint prerequisites"
    
    return Test-SPDSCSpecificParameters -CurrentValues $CurrentValues -DesiredValues $PSBoundParameters -ValuesToCheck @("Ensure")
}

Export-ModuleMember -Function *-TargetResource

