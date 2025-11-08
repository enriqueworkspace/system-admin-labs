GPO Administration Lab

Objectives



Create and manage Group Policy Objects (GPOs) to:



Map network drives for users



Block access to Control Panel



Set wallpapers and apply security/configuration settings



Link GPOs to specific Organizational Units (OUs)



Verify GPO application for users and computers



Document all steps and commands for reproducibility



Environment



Windows Server 2022 with GUI in VirtualBox



Domain: corp.local



Existing OUs: IT, HR, Automation



Users exist in these OUs



All commands executed in elevated PowerShell and GPMC



Step 1: Plan GPOs



Three GPOs were implemented:



GPO-DriveMapping – Maps network drives for IT and HR users.



GPO-BlockControlPanel – Restricts access to Control Panel.



GPO-WallpaperSecurity – Sets wallpaper and applies security/configuration settings for Automation users.



Rationale:



Using existing OUs avoids unnecessary creation.



GPO names follow a clear naming convention.



Step 2: Create GPOs

```

Import-Module GroupPolicy



New-GPO -Name "GPO-DriveMapping" -Comment "Maps network drives for IT and HR users"

New-GPO -Name "GPO-BlockControlPanel" -Comment "Blocks access to Control Panel for users"

New-GPO -Name "GPO-WallpaperSecurity" -Comment "Sets wallpaper and security settings for Automation users"



\# Verify creation

Get-GPO -All | Select-Object DisplayName, Id, CreationTime

```



Purpose:



Creates each GPO in the domain.



Verification ensures they exist before linking.



Step 3: Link GPOs to OUs

```

# Link BlockControlPanel GPO to multiple OUs

$ous = @(

&nbsp;   "OU=IT,DC=corp,DC=local",

&nbsp;   "OU=HR,DC=corp,DC=local",

&nbsp;   "OU=Automation,DC=corp,DC=local"

)

foreach ($ou in $ous) {

&nbsp;   New-GPLink -Name "GPO-BlockControlPanel" -Target $ou

}



# Link DriveMapping GPO

New-GPLink -Name "GPO-DriveMapping" -Target "OU=IT,DC=corp,DC=local"

New-GPLink -Name "GPO-DriveMapping" -Target "OU=HR,DC=corp,DC=local"



# Link WallpaperSecurity GPO

New-GPLink -Name "GPO-WallpaperSecurity" -Target "OU=Automation,DC=corp,DC=local"



# Verify linked GPOs

Get-GPInheritance -Target "OU=IT,DC=corp,DC=local" | Select-Object GpoName, Enforced

Get-GPInheritance -Target "OU=HR,DC=corp,DC=local" | Select-Object GpoName, Enforced

Get-GPInheritance -Target "OU=Automation,DC=corp,DC=local" | Select-Object GpoName, Enforced

```



Purpose:



Attaches each GPO to the correct OU.



Looping avoids repeating commands manually.



Get-GPInheritance confirms successful linking.



Step 4: Configure GPO Settings

4a. Drive Mapping (GPO-DriveMapping)



User Configuration → Preferences → Windows Settings → Drive Maps



Create a mapped drive:



Action: Create



Location: \\\\ServerName\\ShareName



Drive Letter: Z:



Label as: Department Share



Reconnect: Checked



4b. Control Panel Restriction (GPO-BlockControlPanel)



User Configuration → Administrative Templates → Control Panel



Enable Prohibit access to Control Panel and PC settings



Optional PowerShell:

```

Set-GPRegistryValue -Name "GPO-BlockControlPanel" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1

```

4c. Wallpaper and Security (GPO-WallpaperSecurity)



User Configuration → Administrative Templates → Desktop → Desktop → Desktop Wallpaper



Configure wallpaper path if available



Additional security settings applied under Computer Configuration → Windows Settings → Security Settings



Step 5: Force GPO Update and Verify

```

# Force immediate refresh

gpupdate /force



# Check applied GPOs for user

gpresult /r



# Verify linked GPOs for OU

Get-GPInheritance -Target "OU=IT,DC=corp,DC=local"

```



Purpose:



Ensures GPOs are applied to users and computers.



Confirms functionality: drive mappings, Control Panel restriction, wallpaper, and security settings.



Note: Policies only apply on domain-joined machines and users in linked OUs.



Step 6: Verification Commands



Get-GPO -All → Lists all GPOs in the domain



Get-GPInheritance -Target <OU> → Shows GPOs linked to a specific OU



gpupdate /force → Refreshes policies immediately



gpresult /r → Confirms applied GPOs for a user

