Function Convert-ToBase64 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$String
    )
    process {
        [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String))
    }
}

Function Convert-FromBase64 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$String
    )
    process {
        [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($String))
    }
}


$SSHConfig = "$env:USERPROFILE\.ssh\config"

function Set-SSHConfig {
	notepad++ $SSHConfig
}

function Invoke-ServerAction {
    # Add parameter names Action with options of PowerOn, PowerOff, Status
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("t320","r730")]
        [string]$ServerName,
        [Parameter(Mandatory=$true)]
        [ValidateSet("PowerOn","PowerOff","PowerStatus")]
        [string]$Action
    )

    switch ($Action) {
        "PowerOn" {
            # Power on the Server
            ssh $ServerName "racadm serveraction powerup"
        }
        "PowerOff" {
            # Power off the Server
            ssh $ServerName "racadm serveraction powerdown"
        }
        "PowerStatus" {
            # Get the Power Status of the Server
            ssh $ServerName "racadm serveraction powerstatus"
        }
    }
}

$SSHConfig = "$env:USERPROFILE\.ssh\config"
function Set-SSHConfig {
    try {
        notepad++ $SSHConfig -ErrorAction Stop
    } 
    catch {
        notepad $SSHConfig
    }
	notepad++ $SSHConfig
}

function Start-WSLImageBackup {
    [CmdletBinding()]
    param(
    [string]$Distro = "Debian",
    [string]$BackupDestinationPath = "D:\wsl_backups"
    )

    if ((Test-Path $BackupDestinationPath) -eq $false) {
        Write-Verbose "Creating backup destination folder [$($BackupDestinationPath)].."
        New-Item -Path $BackupDestinationPath -ItemType Directory -Force | Out-Null
    }

    $DateTime = get-date -Format "yyyy-MM-dd-HHmm"
    $BackupFile = "$($BackupDestinationPath)\$($Distro)-$($DateTime).tar"
    Write-Verbose "Shutting down the WSL before Backup.."
    wsl --shutdown
    Start-Sleep -Seconds 5
    Write-Verbose "Making WSL image backup for [$($Distro)] to [$($BackupFile)].."
    wsl --export $Distro $BackupFile
}