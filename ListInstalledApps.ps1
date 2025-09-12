function GetInfo {
param($tempApps)

try { $temp = Get-ItemProperty -Path $tempApps.PSPath -ErrorAction Stop }

catch { return } 

if ([string]::IsNullOrWhiteSpace([string]$temp.DisplayName)) { return }

if ([int]$temp.SystemComponent -eq 1) { return }

if($temp.ReleaseType -match '\b(update|hotfix|security update|service pack|rollup)\b') { return }

$dolly = $temp.DisplayName.Trim()

if ($appsSeen.Add($dolly)) { [void]$appsUnique.Add($temp) }
}

$appsLoc = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall',
'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall',
'HKCU:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'

$appsKey = Get-ChildItem -Path $appsLoc -ErrorAction SilentlyContinue
$appsSeen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$appsUnique, $appsExport = [System.Collections.Generic.List[object]]::new(), [System.Collections.Generic.List[object]]::new() 

try {$appsOther = Get-AppxPackage -AllUsers -ErrorAction Stop }
catch { $appsOther = Get-AppxPackage -ErrorAction SilentlyContinue }

foreach ($abc in $appsKey){ GetInfo $abc }

foreach ($edge in $appsOther) {
	if ($edge.IsFramework) { continue }
	if ($edge.NonRemovable) { continue }
	if ($edge.IsResourcePackage) { continue }
	if ($edge.SignatureKind -ne 'Store') { continue }
	if ([string]::IsNullOrWhiteSpace($edge.Name)) { continue }
	if($appsSeen.Add($edge.Name.Trim())) {
		$pub = if (-not [string]::IsNullorWhiteSpace($edge.PublisherDisplayName)) { $edge.PublisherDisplayname.Trim() }
		elseif (-not [string]::IsNullOrWhiteSpace($edge.Publisher)){
		if ($edge.Publisher -match 'CN=([^,]+)') { $matches[1].Trim() } else {$edge.Publisher.Trim() }
		} else { '???' }
		[void]$appsUnique.Add([pscustomobject]@{
			DisplayName = $edge.Name.Trim()
			Publisher = $pub 
		})
	}
}

$appsUnique = $appsUnique | Sort-Object DisplayName

foreach ($buddy in $appsUnique){
	$a = $buddy.DisplayName.Trim()
	if ([string]::IsNullOrWhiteSpace($buddy.Publisher)) { $b = "???" }
	else { $b = $buddy.Publisher.Trim() }
	[void]$appsExport.add([pscustomobject]@{
		Name = $a
		Publisher = $b
	})
}

$appsExport | Export-Csv '.\apps.csv' -NoTypeInformation -Encoding UTF8
Start-Process notepad.exe '.\apps.csv'
