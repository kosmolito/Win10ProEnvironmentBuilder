# Check if the script is running as Administrator
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $IsAdmin) {
    Write-Output "You need to run this script as Administrator."
    exit
}

$ErrorActionPreference = "Stop"
$ComputerName = read-host "Enter the Computer Name you want to use:"
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

Write-Output "############### Taskbar Cleanup ###############"

#Remove News and Interest Using Powershell | 0 = Show Icon and Text, 1 = Show Icon Only, 2 = Turn Off
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Value 2 -Force -Verbose

# Remove Cortana from Taskbar
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Value 2 -Force -Verbose

# Remove Search Icon from Taskbar
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Force -Verbose
Write-Output "############### Taskbar Cleanup Done ###############"

## Change the Windows 10 Wallpaper Color
# Define the solid color you want as the wallpaper
$color = "rgb(56,56,56)"  # Change this to the RGB color of your choice

# Define the Registry path for the wallpaper setting
$registryPath = "HKCU:\Control Panel\Colors"

# Set the wallpaper color in the Registry
Set-ItemProperty -Path $registryPath -Name "Background" -Value $color


# Installing PowerShell Modules
$Modules = @("dbatools","HttpListener","PSWindowsUpdate","PnP.PowerShell","Az","ImportExcel", "Microsoft.PowerShell.SecretManagement")

Write-Output "############### Installing PowerShell Modules ###############"
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

Write-Output "############### Updating Help for PowerShell Modules ###############"
$Modules | ForEach-Object {
    Update-Help -Force -Verbose -ErrorAction SilentlyContinue
}

$PackageFile = $PSScriptRoot + "\winget-packages.json"
if (Test-Path $PackageFile) {
    Write-Output "############### Installing Windows Packages ###############"
    winget import $PackageFile --no-upgrade --accept-package-agreements --accept-source-agreements --ignore-unavailable --verbose
}

$WindowsTerminalSettingsFolder = $env:USERPROFILE + "\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$SettingsFile = $PSScriptRoot + "\windows-terminal-settings.json"

if ((Test-Path $SettingsFile) -and (Test-Path $WindowsTerminalSettingsFolder)) {
    Write-Output "############### Installing Windows Terminal Settings ###############"
    Copy-Item -Path $SettingsFile -Destination "$($WindowsTerminalSettingsFolder)\setings.json" -Force -Verbose
}


# Enable Hyper-V and PowerShell Direct
Write-Output "############### Enabling Hyper-V and PowerShell Direct ###############"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart -Verbose
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell -All -NoRestart -Verbose
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Hypervisor -All -NoRestart -Verbose
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Services -All -NoRestart -Verbose
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Tools-All -All -NoRestart -Verbose

Write-Output "You need to restart your computer in order to changes to take effect."
$RestartConfirmation = read-host "Do you want to restart your computer now? (Y/N)"
if ($RestartConfirmation -eq "Y") {
    restart-computer -force
}
else {
    Write-Output "Restart Aborted. Please restart your computer manually to apply changes."
}