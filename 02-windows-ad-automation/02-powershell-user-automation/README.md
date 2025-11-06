PowerShell Automated AD User Creation Lab

Overview



This lab demonstrates how to automate user creation in Active Directory using PowerShell. The goal was to create a dedicated OU called Automation to keep this automation lab independent from previous Active Directory setups. All users, groups, and actions are contained within this OU, ensuring no interference with existing OUs, groups, or users.



The lab covers:



Reading user data from a CSV file.



Creating or updating users in Active Directory.



Assigning users to specific groups.



Resetting passwords and forcing users to change passwords at next logon.



Logging all actions and errors with timestamps.



Ensuring idempotency so that repeated runs do not duplicate objects.



Lab Environment



Domain: corp.local



Existing OUs: IT, HR



Existing Groups: IT-Admins (OU=IT), HR-Staff (OU=HR)



Existing Users: John Smith (jsmith) in IT, Mary Jones (mjones) in HR



Target OU for this lab: Automation (newly created)



All operations in this lab target Automation OU exclusively.



Prerequisites



Windows Server 2022 with Active Directory Domain Services Tools installed.



Domain admin or equivalent permissions to create OUs, users, and groups.



PowerShell with execution policy set to allow script execution.



CSV file containing user data (NewUsers.csv).



CSV File Structure



The CSV contains the users to create or update. Columns:



Column	Description

Username	sAMAccountName for the user

FirstName	User’s first name

LastName	User’s last name

Password	Initial password for the user (script sets UserMustChangePasswordAtNextLogon)

Groups	Comma-separated list of groups the user should belong to inside Automation OU



Example CSV:

```

Username,FirstName,LastName,Password,Groups

asmith,Alice,Smith,Password123!,Automation-Users

bjones,Bob,Jones,Password123!,Automation-Users

```

Script Overview



The script Create-ADUsers.ps1 performs the following steps:



Logging Setup:

Creates a log file to record all actions and errors with timestamps.



Prerequisite Checks:



Verifies that the Active Directory PowerShell module is installed.



Confirms that the CSV file exists.



Ensures the log directory exists.



OU Management:



Checks if Automation OU exists.



Creates it if missing.



User Processing:

For each user in the CSV:



Checks if the user exists.



If yes, updates attributes like name and description.



If no, creates the user with a default password.



Forces password change at next logon.



Logs all actions.



Group Management:



Checks if the required groups exist in Automation OU.



Creates any missing groups.



Adds users to their groups, handling idempotency.



How to Run



Copy Create-ADUsers.ps1 and NewUsers.csv to a folder on the Windows Server.



Open PowerShell as Administrator.



Navigate to the folder:

```

cd "C:\\Path\\To\\Script"

```



Run the script:

```

.\\Create-ADUsers.ps1

```



Check the log file for details: C:\\AD\_Automation\\UserCreation.log.



Verification



After running the script, you can verify results using these commands:



List users in Automation OU:

```

Get-ADUser -Filter \* -SearchBase "OU=Automation,DC=corp,DC=local" | Select-Object SamAccountName, GivenName, Surname

```



Show group membership for a user (example: asmith):

```

Get-ADPrincipalGroupMembership -Identity "asmith" | Select-Object Name

```



Check if password must change at next logon:

```

(Get-ADUser -Identity "asmith" -Properties PwdLastSet).PwdLastSet -eq 0

```



Notes



The script is idempotent: re-running it does not duplicate users or groups.



Only the Automation OU is affected, leaving previous lab objects intact.



All actions are logged for auditing and troubleshooting purposes.

