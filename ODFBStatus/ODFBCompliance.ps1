<#
To be run in ConfigMgr Configration Item and deployed to a users collection. Make sure to deploy
the DLL files first via a 2nd ConfigMgr application.
#>

# If true, will use a debug dll
$debug = $false
$logFile = "$($env:LOCALAPPDATA)\temp\ODStatus.log"

# Location where the OneDriveLib.dll files are stored.
$DeployedDllPath = "c:\programdata\OneDriveStatus"

# Filter user to identify the correct Onedrive for business sync
$ODPathFilter = "*$(Split-Path -Path $env:OneDriveCommercial -leaf)*"

function main {
    if (!(IsElevated)){
        ImportDll
        $Status =  ((Get-ODStatus -Verbose -Debug) | % {
            [PSCustomObject] (@{
                'StatusString' = $_.StatusString;
                'ServiceType' = $_.ServiceType;
                'LocalPath' = $_.LocalPath;
                'UserSID' = $_.UserSID;
                'UserName' = $_.UserName
             })
        })
        
        if (!(test-path "$($env:LOCALAPPDATA)\Microsoft\OneDrive\OneDrive.exe")){
            write-host "Non-Compliant: Not Installed"
            log "Unable to find ""$($env:LOCALAPPDATA)\Microsoft\OneDrive\OneDrive.exe"""
            exit
        } elseif ($env:OneDriveCommercial -eq $null) {
            write-host "Non-Compliant: Not configured"
            log "%OneDriveCommercial% has not been set."
            exit
        } else {
            $ODStatus = $Status | ? {($_.ServiceType -eq 'Business1') -and ($_.LocalPath -like $ODPathFilter)} | Select-Object -ExpandProperty StatusString
            if ($ODStatus -eq $null -or $ODStatus -eq 'Error'){
                write-host "Non-Compliant: $ODStatus"
                log "Non-Compliant: $ODStatus"
                exit
            } else {
                write-host "Compliant: $ODStatus"
                log "Compliant: $ODStatus"
                exit
            }
        }
   } else {
    log "ERROR: Unable to run as elevated"
   }
}

function IsElevated {
    if ([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")){
        return $true
    } else {
        return $false
    }
}

function ImportDll {
    
    if ($SCRIPT:debug){
        $DllPath= "$DeployedDllPath\OneDriveLibDebug.dll";
    } else {
        $DllPath = "$DeployedDllPath\OneDriveLib.dll";
    }

    # Download dll if needed
    if (test-path $DllPath){
        Import-Module $DllPath -Scope Global
    } else {
        log "ERROR: Unable to find dll ""$DllPath"""
        exit
    }
}

function log {
    param (
        [string] $message
    )
    $dt = Get-Date -Format u
    #write-host ($dt + ' >> ' + $message)
    ($dt + ' >> ' + $message) | Out-File -FilePath $Script:LogFile -Encoding ascii -Append
}

main