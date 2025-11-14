# PowerShell System Inventory: Hardware and Software Reporting

This lab develops PowerShell scripts to automate collection of hardware and software details from Windows systems, exporting results to CSV files for asset management and analysis. It targets local or remote computers via WMI/CIM queries.

## Hardware Information Script (Get-HardwareInfo.ps1)
This script gathers system details including name, manufacturer, model, memory, and processor specs.

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

- `Get-WmiObject`: Queries Win32_ComputerSystem and Win32_Processor classes.
- `[PSCustomObject]`: Assembles data into a structured object.
- `Export-Csv -Append`: Adds rows to `HardwareReport.csv` in `C:\SystemInventory\`, initializing headers if absent.
- Console output via `Write-Host` tracks progress.

## Software Information Script (Get-SoftwareInfo.ps1)
This script enumerates installed applications, capturing name, version, and vendor.

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

- `Get-CimInstance`: Retrieves Win32_Product class data.
- `[PSCustomObject]`: Includes computer name with software details.
- `Export-Csv -Append`: Appends to `SoftwareReport.csv` in `C:\SystemInventory\`, creating headers if needed.
- Progress tracked via `Write-Host`.

## Usage
Execute scripts in PowerShell as Administrator:
```
.\Get-HardwareInfo.ps1
.\Get-SoftwareInfo.ps1
```
Modify `$computers` array for remote targets (requires network access and credentials if needed). Outputs generate `HardwareReport.csv` and `SoftwareReport.csv`.

## Summary
- Hardware script exports system and CPU details to CSV.
- Software script lists applications with metadata to CSV.
- Both support multi-computer scanning and idempotent file handling.

This solution enables scalable IT inventory without manual intervention.
