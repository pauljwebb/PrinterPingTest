$Printers = Get-Printer
$Count = $Printers.Count
$Index = 0
$Results = foreach ($Printer in $Printers) {
    $Index++
    $Port = Get-PrinterPort -Name $Printer.PortName
    $IP = $Port.PrinterHostAddress
    if ([string]::IsNullOrWhiteSpace($IP)) { continue }

    $Percent = ($Index / $Count) * 100
    Write-Progress -Activity "Testing" -Status "$($Printer.Name)" -PercentComplete $Percent

    $Ping = Test-Connection -ComputerName $IP -Count 1 -Quiet
    $Status = if ($Ping) { "Online" } else { "Offline" }

    # Console output with result
    $ResultText = if ($Ping) { "Success" } else { "Failed" }
    Write-Host "Tested $($Printer.Name) at $IP - $ResultText"

    [PSCustomObject]@{
        PrinterName = $Printer.Name
        PrinterIP   = $IP
        Status      = $Status
        Timestamp   = Get-Date
    }
}
Write-Progress -Activity "Testing" -Completed
$Results | Export-Csv C:\Scripts\printer_report.csv -NoTypeInformation
