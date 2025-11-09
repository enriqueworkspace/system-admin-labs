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

# Get-HardwareInfo.ps1
# Collect hardware information and save to CSV

$inventoryFolder = "C:\SystemInventory"
$csvPath = Join-Path $inventoryFolder "HardwareReport.csv"

# Create CSV with header if it doesn't exist
if (-not (Test-Path $csvPath)) {
    "Name,Manufacturer,Model,TotalPhysicalMemory,ProcessorName,Cores,LogicalProcessors" | Out-File -FilePath $csvPath
}

# List of computers
$computers = @('localhost')

foreach ($computer in $computers) {
    Write-Host "Collecting hardware info for $computer" -ForegroundColor Cyan

    $sys = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computer
    $cpu = Get-WmiObject -Class Win32_Processor -ComputerName $computer

    # Build object to export
    $obj = [PSCustomObject]@{
        Name = $sys.Name
        Manufacturer = $sys.Manufacturer
        Model = $sys.Model
        TotalPhysicalMemory = $sys.TotalPhysicalMemory
        ProcessorName = $cpu.Name
        Cores = $cpu.NumberOfCores
        LogicalProcessors = $cpu.NumberOfLogicalProcessors
    }

    $obj | Export-Csv -Path $csvPath -NoTypeInformation -Append
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
# Get-SoftwareInfo.ps1
# Collect installed software and save to CSV

$inventoryFolder = "C:\SystemInventory"
$csvPath = Join-Path $inventoryFolder "SoftwareReport.csv"

# Create CSV with header if it doesn't exist
if (-not (Test-Path $csvPath)) {
    "ComputerName,Name,Version,Vendor" | Out-File -FilePath $csvPath
}

# List of computers
$computers = @('localhost')

foreach ($computer in $computers) {
    Write-Host "Collecting software info for $computer" -ForegroundColor Cyan

    Get-CimInstance -ClassName Win32_Product -ComputerName $computer | ForEach-Object {
        [PSCustomObject]@{
            ComputerName = $computer
            Name = $_.Name
            Version = $_.Version
            Vendor = $_.Vendor
        } | Export-Csv -Path $csvPath -NoTypeInformation -Append
    }
}

```



Explanation:



Get-CimInstance -ClassName Win32\_Product retrieves installed software details.



A custom object \[PSCustomObject] stores the computer name and software information.



Export-Csv -Append writes the data to SoftwareReport.csv, creating the file with headers if it doesn’t exist.



Write-Host outputs progress messages for each computer scanned.

