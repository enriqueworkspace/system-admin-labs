NTFS Permissions and Shared Folders Lab

Objective



Configure NTFS permissions for folders.



Create shared folders.



Assign specific access per group.



Demonstrate mastery of access control.



This lab demonstrates how to securely organize folder access in a Windows Server environment using Active Directory groups, NTFS permissions, and network shares. Each group has access only to its designated folder.



Step 1: Create Active Directory Groups



Each group represents a department or role in the organization. They will control access to their respective folders.



HR\_Group

```

New-ADGroup -Name "HR_Group" -SamAccountName "HR_Group" -GroupScope Global -Path "OU=HR,DC=corp,DC=local"

```



IT\_Group

```

New-ADGroup -Name "IT_Group" -SamAccountName "IT_Group" -GroupScope Global -Path "OU=IT,DC=corp,DC=local"

```



Finance\_Group

```

New-ADGroup -Name "Finance_Group" -SamAccountName "Finance_Group" -GroupScope Global -Path "OU=HR,DC=corp,DC=local"

```



-GroupScope Global allows the group to contain users from the domain.



Each group is placed in its department OU to keep Active Directory organized.



Step 2: Create Folders



Create a folder for each group in C:\\NTFS-Lab. Each folder will store department-specific data.

```

New-Item -Path "C:\NTFS-Lab\HR" -ItemType Directory -Force

New-Item -Path "C:\NTFS-Lab\IT" -ItemType Directory -Force

New-Item -Path "C:\NTFS-Lab\Finance" -ItemType Directory -Force

```



-Force ensures the command succeeds even if the folder already exists.



Step 3: Assign NTFS Permissions



NTFS permissions determine who can access files and folders on the server. We assign Modify rights to each group, allowing them to read, write, and delete files within their folder, while preventing other groups from accessing it.



HR Folder Permissions

```

$folder = "C:\NTFS-Lab\HR"

$acl = Get-Acl $folder

$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("HR_Group", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")

$acl.SetAccessRule($rule)

Set-Acl -Path $folder -AclObject $acl

```



IT Folder Permissions

```

$folder = "C:\NTFS-Lab\IT"

$acl = Get-Acl $folder

$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("IT_Group", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")

$acl.SetAccessRule($rule)

Set-Acl -Path $folder -AclObject $acl

```



Finance Folder Permissions

```

$folder = "C:\NTFS-Lab\Finance"

$acl = Get-Acl $folder

$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Finance_Group", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")

$acl.SetAccessRule($rule)

Set-Acl -Path $folder -AclObject $acl

```



ContainerInherit,ObjectInherit ensures permissions apply to all files and subfolders.



SYSTEM and Administrators retain full control by default.



Other users (not in the group) have no write access, maintaining security.



Step 4: Share Folders



Network shares allow users to access folders over the network. Each folder is shared with Full Access for the corresponding group only.

```

New-SmbShare -Name "HR_Group" -Path "C:\NTFS-Lab\HR" -FullAccess "HR_Group"

New-SmbShare -Name "IT_Group" -Path "C:\NTFS-Lab\IT" -FullAccess "IT_Group"

New-SmbShare -Name "Finance_Group" -Path "C:\NTFS-Lab\Finance" -FullAccess "Finance_Group"

```



Only members of the specific group can access their folder through the network share.



Other groups or users cannot access folders outside their permissions.



Step 5: Verify Access Control



Even without active users, we can verify permissions and shares using PowerShell. This ensures the configuration is correct.



NTFS Permissions Verification

```

Get-Acl "C:\NTFS-Lab\HR" | Format-List

Get-Acl "C:\NTFS-Lab\IT" | Format-List

Get-Acl "C:\NTFS-Lab\Finance" | Format-List

```



Confirms each group has Modify access to its folder.



Confirms SYSTEM and Administrators retain full control.



Confirms other users do not have unnecessary access.



Share Permissions Verification

```

Get-SmbShare

Get-SmbShareAccess -Name "HR_Group"

Get-SmbShareAccess -Name "IT_Group"

Get-SmbShareAccess -Name "Finance_Group"

```



Confirms each share exists.



Confirms each group has Full Access to its share.



Confirms no other users or groups have access to these shares.

