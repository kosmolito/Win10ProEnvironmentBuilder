$ErrorActionPreference = "Stop"

# Check if the script is running as Administrator
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $IsAdmin) {
    Write-Output "You need to run this script as Administrator."
    exit
}

function Get-MainMenu {
    [cmdletbinding()]
    Param(
        $Title = "Main Menu"
    )
    Write-Output "`n################## $Title ##################"
    Write-Output " A. Run All"
    Write-Output " 1. Rename Computer"
    Write-Output " 2. Taskbar Cleanup & Desktop Background Color Set"
    Write-Output " 3. Install PowerShell Modules"
    Write-Output " 4. Enable SSH-Agent Service"
    Write-Output " 5. Update Help for PowerShell Modules"
    Write-Output " 6. Install Applications by Winget"
    Write-Output " 7. PowerShell Profile (`$PROFILE) Setup"
    Write-Output " 8. Windows Terminal Settings (Requires Windows Terminal to be installed)"
    Write-Output " 9. Enable Hyper-V and PowerShell Direct"
    Write-Output " E. Exit"
}

function Rename-MyCompuer {
    write-output "################## Rename Computer ##################"
    $ComputerName = read-host "Enter the Computer Name you want to use"
    $ComputerName = $ComputerName.ToUpper()
    $CurrentComputerName = $env:COMPUTERNAME.ToUpper()
    if  ($ComputerName -eq "") {
        Write-Output "Computer Name cannot be empty. Please enter a valid Computer Name."
        exit
    } elseif ($ComputerName -eq $CurrentComputerName) {
        write-output "Computer Name is already set to $ComputerName. No changes made."
    } else {
        Write-Output "Changing Computer Name from $CurrentComputerName to $ComputerName"
        Rename-Computer -NewName $ComputerName -Force -Verbose
    }
}

function Invoke-TaskbarCleanup {
    Write-Output "################## Taskbar Cleanup ##################"
    #Remove News and Interest Using Powershell | 0 = Show Icon and Text, 1 = Show Icon Only, 2 = Turn Off
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Value 2 -Force -Verbose

    # Remove Cortana from Taskbar
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Value 2 -Force -Verbose

    # Remove Search Icon from Taskbar
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Force -Verbose
}

function Set-DesktopBackgroundColor {
    param (
        [Parameter(Mandatory=$false)]
        [string]$RGBColor = "56,56,56"
    )
    Write-Output "################## Setting the Desktop Background Color ##################"
    # Define the solid color you want as the wallpaper
    $color = "rgb($($RGBColor))"  # Change this to the RGB color of your choice

    # Define the Registry path for the wallpaper setting
    $registryPath = "HKCU:\Control Panel\Colors"

    # Set the wallpaper color in the Registry
    Set-ItemProperty -Path $registryPath -Name "Background" -Value $color
    }

function Install-PowerShellModules {
    Write-Output "################## Installing Powershell Modules ##################"
    $Modules = @(
        "powershell-yaml",
        "dbatools",
        "HttpListener",
        "PSWindowsUpdate",
        "PnP.PowerShell",
        "Az",
        "ImportExcel",
        "Microsoft.PowerShell.SecretManagement"
        "AWS.Tools.Common",
        "AWS.Tools.Installer",
        "AWS.Tools.EC2",
        "AWS.Tools.S3",
        "AWS.Tools.ElasticLoadBalancingV2",
        "AWS.Tools.CloudFormation",
        "AWSCompleter"
        )

    $Modules | ForEach-Object {
        $IsModuleInstalled = Get-InstalledModule -Name $_ -ErrorAction SilentlyContinue
        if ($IsModuleInstalled) {
            Write-Output "Module: $_ is already installed. Skipping installation."
            Write-Output "############################################"
        } else {
            Write-Output "Module: $_ is not installed. Installing now."
            Install-Module -Name $_ -Force -Verbose
            Write-Output "Module: $_ Installed"
            Write-Output "############################################"
        }
    }
}

function Enable-SSHAgentService {
    Write-Output "################## Enabling SSH-Agent Service ##################"
    $ServiceName = "ssh-agent"
    $ServiceStatus = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if (($ServiceStatus.Status -eq "Running") -and ($ServiceStatus.StartType -eq "Automatic")) {
        Write-Output "Service: $ServiceName is already running. Skipping service start."
    } else {
        Write-Output "Service: $ServiceName is not running. Starting service now."
        Start-Service -Name $ServiceName -Verbose
        Set-Service -Name $ServiceName -StartupType Automatic -Verbose
        Write-Output "Service: $ServiceName Started"
    }
}

function Update-PowerShellHelp {
    Write-Output "################## Updating Help for PowerShell Modules ##################"
    Update-Help -Verbose -ErrorAction SilentlyContinue
}

function Install-ApplicationsByWinget {
    param (
        [Parameter(Mandatory=$false)]
        [string]$PackageFile = $PSScriptRoot + "\winget-packages.json"
    )
    Write-Output "################## Installing Applications by Winget ##################"
    if (Test-Path $PackageFile) {
        Write-Output "############### Installing Windows Packages ###############"
        winget import $PackageFile --no-upgrade --accept-package-agreements --accept-source-agreements --ignore-unavailable --disable-interactivity --verbose
    }

    Write-Output "################## Registering AWS CLI Completer ##################"
    try {
        Import-Module -Name AWSCompleter -ErrorAction Stop
        Register-AWSCompleter
    }
    catch {
        Write-Output "AWSCompleter Module is not installed. Skipping AWSCompleter Registration."
    }

    try {
        cfn-lint --version
    }
    catch {
        try {
            Write-Output "################## Installing cfn-lint ##################"
            pip install cfn-lint
        }
        catch {
            Write-Output "cfn-lint installation error. Skipping cfn-lint installation."
        }
    }

}



function Set-PowerShellProfile {
    Write-Output "################## PowerShell Profile ##################"

    $ProfilePath = $env:USERPROFILE + "\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    $RepoProfilePath = $PSScriptRoot + "\PowerShellProfile.ps1"

    if (!(Test-Path $ProfilePath)) {
        try {
            Write-Output "############### Copying PowerShell Profile From Repository ###############"
            Copy-Item -Path $RepoProfilePath -Destination $ProfilePath -Force -Verbose -ErrorAction Stop
        }
        catch {
            Write-Output $_.Exception.Message
        }
    }
}

function Set-WindowsTerminalSettings {
    Write-Output "################## Configuration of Windows Terminal Settings ##################"
    $WindowsTerminalSettingsFolder = $env:USERPROFILE + "\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    $SettingsFile = $PSScriptRoot + "\windows-terminal-settings.json"

    if ((Test-Path $SettingsFile) -and (Test-Path $WindowsTerminalSettingsFolder)) {
        Write-Output "############### Installing Windows Terminal Settings ###############"
        Copy-Item -Path $SettingsFile -Destination "$($WindowsTerminalSettingsFolder)\settings.json" -Force -Verbose
    }

    $gmayOhMyPoshTheme = $PSScriptRoot + "\gmay.omp.json"
    try {
        Copy-Item $gmayOhMyPoshTheme -Destination "$($env:USERPROFILE)\AppData\Local\Programs\oh-my-posh\themes\gmay.omp.json" -Force -Verbose -ErrorAction Stop
    }
    catch {
        Write-Output "oh-my-posh is not installed. Skipping oh-my-posh theme installation."
    }
}

function Enable-HyperVFeature {
Write-Output "################## Enabling Hyper-V and PowerShell Direct ##################"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart -Verbose
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell -All -NoRestart -Verbose
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Hypervisor -All -NoRestart -Verbose
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Services -All -NoRestart -Verbose
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Tools-All -All -NoRestart -Verbose
}

function Restart-MyComputer {
    Write-Output "You need to restart your computer in order to changes to take effect."
    $RestartConfirmation = read-host "Do you want to restart your computer now? (Y/N)"
    if ($RestartConfirmation -eq "Y") {
        restart-computer -force
    }
    else {
        Write-Output "Restart Aborted. Please restart your computer manually to apply changes."
    }
}


do {
    Get-MainMenu -Title "Environtment Automation Script Menu"
    $Selection = Read-Host "Please make a selection, separated by commas if multiple selections are made"
    if ($Selection -like "A") {
        Write-Output "You have selected to run all options."
        $ProceedConfirmation = read-host "Do you want to proceed? (Y/N)"
        if ($ProceedConfirmation -eq "Y") {
            Write-Output "Running all options."
        }
        else {
            Write-Output "Aborting."
            $Selection = ""
        }
    } elseif ($Selection -like "E") {
        Write-Output "You have selected to exit."
    } else {
        # Split the selection by comma to allow multiple selections
        $Selection = $Selection.Split(",") | ForEach-Object { 
            # Validate the selection to ensure only numbers are selected
            if ($_ -match "^[1-9]+$") {
                Invoke-Expression $_
            }}
    }

    switch ($Selection) {
        1 {Rename-MyCompuer}
        2 {Invoke-TaskbarCleanup;Set-DesktopBackgroundColor}
        3 {Install-PowerShellModules}
        4 {Enable-SSHAgentService}
        5 {Update-PowerShellHelp}
        6 {Install-ApplicationsByWinget}
        7 {Set-PowerShellProfile}
        8 {Set-WindowsTerminalSettings}
        9 {Enable-HyperVFeature}
        "A" 
        {
            Rename-MyCompuer
            Invoke-TaskbarCleanup
            Set-DesktopBackgroundColor
            Install-PowerShellModules
            Enable-SSHAgentService
            Update-PowerShellHelp
            Install-ApplicationsByWinget
            Set-PowerShellProfile
            Set-WindowsTerminalSettings
            Enable-HyperVFeature
            Restart-MyComputer
        }
        default {Write-Output "Invalid Selection!"}

    }
} until (
    $Selection -like "E"
)