Lab Overview



In this lab, I created a system inventory solution using PowerShell to collect hardware and software information from Windows computers. The main goal was to automate IT asset reporting and store the results in CSV files for easy review and analysis.



The lab demonstrates how to:



Collect hardware details such as computer name, manufacturer, model, memory, and processor specifications.



Collect installed software information including name, version, and vendor.



Generate organized reports automatically.



Hardware Information Script (Get-HardwareInfo.ps1)



The hardware script is responsible for collecting key system information.



I defined a list of computers in a variable $computers. By default, it contains 'localhost' to target the local machine. You can add other computer names to scan multiple systems.

```

\# Get-HardwareInfo.ps1

\# Collect hardware information and save to CSV



$inventoryFolder = "C:\\SystemInventory"

$csvPath = Join-Path $inventoryFolder "HardwareReport.csv"



\# Create CSV with header if it doesn't exist

if (-not (Test-Path $csvPath)) {

&nbsp;   "Name,Manufacturer,Model,TotalPhysicalMemory,ProcessorName,Cores,LogicalProcessors" | Out-File -FilePath $csvPath

}



\# List of computers

$computers = @('localhost')



foreach ($computer in $computers) {

&nbsp;   Write-Host "Collecting hardware info for $computer" -ForegroundColor Cyan



&nbsp;   $sys = Get-WmiObject -Class Win32\_ComputerSystem -ComputerName $computer

&nbsp;   $cpu = Get-WmiObject -Class Win32\_Processor -ComputerName $computer



&nbsp;   # Build object to export

&nbsp;   $obj = \[PSCustomObject]@{

&nbsp;       Name = $sys.Name

&nbsp;       Manufacturer = $sys.Manufacturer

&nbsp;       Model = $sys.Model

&nbsp;       TotalPhysicalMemory = $sys.TotalPhysicalMemory

&nbsp;       ProcessorName = $cpu.Name

&nbsp;       Cores = $cpu.NumberOfCores

&nbsp;       LogicalProcessors = $cpu.NumberOfLogicalProcessors

&nbsp;   }



&nbsp;   $obj | Export-Csv -Path $csvPath -NoTypeInformation -Append

}

```



Explanation:



Get-WmiObject retrieves hardware data from the local or remote computer.



A custom object \[PSCustomObject] is built to combine system and processor information.



Export-Csv -Append writes each computer’s data to HardwareReport.csv, creating the file if it does not exist.



Write-Host outputs progress messages to the console.



Software Information Script (Get-SoftwareInfo.ps1)



The software script collects all installed applications and stores them in a CSV.

```

\# Get-SoftwareInfo.ps1

\# Collect installed software and save to CSV



$inventoryFolder = "C:\\SystemInventory"

$csvPath = Join-Path $inventoryFolder "SoftwareReport.csv"



\# Create CSV with header if it doesn't exist

if (-not (Test-Path $csvPath)) {

&nbsp;   "ComputerName,Name,Version,Vendor" | Out-File -FilePath $csvPath

}



\# List of computers

$computers = @('localhost')



foreach ($computer in $computers) {

&nbsp;   Write-Host "Collecting software info for $computer" -ForegroundColor Cyan



&nbsp;   Get-CimInstance -ClassName Win32\_Product -ComputerName $computer | ForEach-Object {

&nbsp;       \[PSCustomObject]@{

&nbsp;           ComputerName = $computer

&nbsp;           Name = $\_.Name

&nbsp;           Version = $\_.Version

&nbsp;           Vendor = $\_.Vendor

&nbsp;       } | Export-Csv -Path $csvPath -NoTypeInformation -Append

&nbsp;   }

}

```



Explanation:



Get-CimInstance -ClassName Win32\_Product retrieves installed software details.



A custom object \[PSCustomObject] stores the computer name and software information.



Export-Csv -Append writes the data to SoftwareReport.csv, creating the file with headers if it doesn’t exist.



Write-Host outputs progress messages for each computer scanned.

