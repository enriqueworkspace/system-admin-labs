Overview



This lab demonstrates automated user management in Linux, simulating a real-world onboarding process used by system administrators. It highlights scripting, group management, permissions, and basic access control.



Objectives



Automate creation of multiple users from a CSV file



Manage primary and secondary groups automatically



Set secure initial passwords and enforce first-login password change



Apply correct home directory permissions (chmod 700)



Demonstrate basic offboarding (user disabling)




Files Description



onboarding.sh: Bash script that reads users.csv and:



Creates users and home directories



Creates primary and secondary groups if they don’t exist



Sets a default password and forces first-login change



Applies secure permissions to home directories



Demonstrates account disabling (offboarding)



users.csv: CSV file structured as:



```

username,full_name,primary_group,secondary_groups

jdoe,John Doe,development,"sales,management"

asmith,Alice Smith,sales,"development"

rbrown,Robert Brown,management,"sales"

```



Usage Instructions



Ensure the CSV file is in Unix format:



```

dos2unix users.csv

```



Make the script executable:



```

chmod +x onboarding.sh

```



Run the script as root:



```

sudo .onboarding.sh

```



Expected Output



Users jdoe, asmith, and rbrown are created with correct primary and secondary groups.



Home directories are created with chmod 700.



Default password is set to Welcome123! and forced to change at first login.



User rbrown is automatically disabled to demonstrate offboarding.



Verification Commands

```

# List users

awk -F: '$3 >= 1000 {print $1}' /etc/passwd



# List groups

getent group | grep -E 'development|sales|management'



# Check home directories

ls -ld /home/jdoe /home/asmith /home/rbrown



# Check disabled account

sudo passwd -S rbrown

```

