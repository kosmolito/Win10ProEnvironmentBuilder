## My Windows10 Pro Post Fresh Installation Script

This is a script that I use to install all the software I need after a fresh installation of Windows 10 Pro. The purpose of this script is to automate the installation of software and to make it easier to setup your desired environment. This script is not intended to be used by anyone else but me. However, if you find it useful, feel free to fork it and make it your own. I have included a list of software that I use on a daily basis.

### What this script does
- Renames the computer
- Removes Search, News and Interests and Cortana from the taskbar
- Sets the background to a solid colour [rgb(56, 56, 56)] / Dark Grey
- Installs the following PowerSHell modules:
    - PSWindowsUpdate
    - HttpListener
    - PnP.PowerShell
    - Az
    - Microsoft.PowerShell.SecretManagement
    - ImportExcel
- Install Winget Packages from json file in this repo
- Enables Hyper-V

### Prerequisites
- Windows 10 Pro (tested on 21H2), it may work on other versions but I have not tested it
- WinGet installed
- PowerShell 5.1 or higher (tested on 7.1.3)
- PowerShell Execution Policy set to RemoteSigned

### Instructions
1. Install Winget (App Installer) from the Microsoft Store
2. Open PowerShell as Administrator
3. Run the following command to set the Execution Policy to RemoteSigned
    
    Install git if you don't have it
    ```powershell
    winget install git
    ```
    Set the Execution Policy to RemoteSigned
    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
    ```
    Clone this repo
    ```powershell
    git clone https://github.com/kosmolito/Win10ProEnvironmentBuilder.git
    ```
    Change directory to the repo
    ```powershell
    cd .\Win10ProEnvironmentBuilder\
    ```

    Run the script
    ```powershell
    .\Win10ProEnvironmentBuilder.ps1
    ```
