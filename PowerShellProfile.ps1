# Useful function for managing Dell Servers with iDRAC
# In this example, I have two servers named t320 and r730. the server names are stored in the ssh config file, which is defined in the $env:USERPROFILE\.ssh\config file.
# Example of the config file:
# Host t320
#     HostName 192.168.10.10
#     User root
#     IdentityFile ~/.ssh/id_rsa
#     Port 22


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