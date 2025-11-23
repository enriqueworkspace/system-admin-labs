# GPO Administration Lab

This lab configures and manages Group Policy Objects (GPOs) on Windows Server 2022 to enforce drive mappings, Control Panel restrictions, wallpapers, and security settings. GPOs are linked to existing OUs (IT, HR, Automation) and verified for application using PowerShell and Group Policy Management Console (GPMC).

## 1. Plan GPOs
Three GPOs are defined:
- **GPO-DriveMapping**: Maps network drives for users in IT and HR OUs.
- **GPO-BlockControlPanel**: Prohibits Control Panel access domain-wide.
- **GPO-WallpaperSecurity**: Applies desktop wallpaper and security configurations for Automation OU users.

This leverages existing OUs and employs descriptive naming for maintainability.

## 2. Create GPOs
Load the GroupPolicy module and generate GPOs:
```
Import-Module GroupPolicy
New-GPO -Name "GPO-DriveMapping" -Comment "Maps network drives for IT and HR users"
New-GPO -Name "GPO-BlockControlPanel" -Comment "Blocks access to Control Panel for users"
New-GPO -Name "GPO-WallpaperSecurity" -Comment "Sets wallpaper and security settings for Automation users"
```

Verify:
```
Get-GPO -All | Select-Object DisplayName, Id, CreationTime
```
Expected: All three GPOs listed with creation timestamps.

## 3. Link GPOs to OUs
Link GPO-BlockControlPanel to all OUs:
```
$ous = @(
    "OU=IT,DC=corp,DC=local",
    "OU=HR,DC=corp,DC=local",
    "OU=Automation,DC=corp,DC=local"
)
foreach ($ou in $ous) {
    New-GPLink -Name "GPO-BlockControlPanel" -Target $ou
}
```

Link GPO-DriveMapping:
```
New-GPLink -Name "GPO-DriveMapping" -Target "OU=IT,DC=corp,DC=local"
New-GPLink -Name "GPO-DriveMapping" -Target "OU=HR,DC=corp,DC=local"
```

Link GPO-WallpaperSecurity:
```
New-GPLink -Name "GPO-WallpaperSecurity" -Target "OU=Automation,DC=corp,DC=local"
```

Verify inheritance:
```
Get-GPInheritance -Target "OU=IT,DC=corp,DC=local" | Select-Object GpoName, Enforced
Get-GPInheritance -Target "OU=HR,DC=corp,DC=local" | Select-Object GpoName, Enforced
Get-GPInheritance -Target "OU=Automation,DC=corp,DC=local" | Select-Object GpoName, Enforced
```
Expected: Linked GPOs displayed per OU, without enforcement overrides.

## 4. Configure GPO Settings
### 4a. Drive Mapping (GPO-DriveMapping)
In GPMC: User Configuration → Preferences → Windows Settings → Drive Maps.
- Action: Create
- Location: `\\ServerName\ShareName`
- Drive Letter: Z:
- Label as: Department Share
- Reconnect: Enabled

### 4b. Control Panel Restriction (GPO-BlockControlPanel)
In GPMC: User Configuration → Administrative Templates → Control Panel → Enable "Prohibit access to Control Panel and PC settings".

PowerShell alternative:
```
Set-GPRegistryValue -Name "GPO-BlockControlPanel" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1
```

### 4c. Wallpaper and Security (GPO-WallpaperSecurity)
In GPMC: User Configuration → Administrative Templates → Desktop → Desktop → Desktop Wallpaper → Configure path (if image available).

Additional: Computer Configuration → Windows Settings → Security Settings for policies like account lockout or auditing.

## 5. Force GPO Update and Verify
Refresh policies:
```
gpupdate /force
```

Check applied GPOs:
```
gpresult /r
```
Expected: Target GPOs listed under "Applied Group Policy Objects".

Review OU inheritance:
```
Get-GPInheritance -Target "OU=IT,DC=corp,DC=local"
```

Policies apply to domain-joined machines and users in linked OUs.

## 6. Verification Commands
- List all GPOs: `Get-GPO -All`
- View OU-linked GPOs: `Get-GPInheritance -Target <OU>`
- Refresh policies: `gpupdate /force`
- Report applied GPOs: `gpresult /r`

## Summary
- GPOs created: GPO-DriveMapping, GPO-BlockControlPanel, GPO-WallpaperSecurity.
- Linked to IT, HR, and Automation OUs as required.
- Settings configured for drive mapping, restrictions, and security.
- Application verified via refresh and reporting commands.

This establishes centralized policy enforcement for domain management.
