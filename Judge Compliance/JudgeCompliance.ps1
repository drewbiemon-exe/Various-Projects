<#This script allows us to see what applications installed on a system are compliant with risk assessment
We do this by comparing two csv files against each other and exporting a new one

This script requires you have two things in the same folder as this one
1) apps.csv
	#This is our list of applications installed. Generated through ListInstalledApps.ps1
2) complianceList.csv
	This is our list of assessed applications. This includes headers for:
		# Compliant Applications
		# Compliant Publishers
		# Non-Compliant Applications
		# Non-Compliant Publishers
Once cross-checking between both scripts, we export a new one with fields that tell us what is and isn't compliant. It also tells us what part of it (program or publisher) makes it compliant or not.
	For edge cases, I also include an "Unassessed" field. This could be useful for people with the ability to install whatever they want without first checking with IT #>


$ErrorActionPreference = 'Stop'

#Precedence: Non-Compliant (publisher) > Non-Compliant (app) > Compliant (publisher) > Compliant (app) > Unassessed
#Return: Name, Publisher, Compliance, Which factor makes this compliant?
function GetInfo {
	param($tempApp)
	$nam = $tempApp | Select-Object -ExpandProperty 'Name'
	$pub = $tempApp | Select-Object -ExpandProperty 'Publisher'
	
	#Instead of iterating through each of these lists with a foreach loop, we just look to see if it's contained anywhere in there
	#Note: all of $nam or $pub still need to match what they're being compared against (not case sensitive)
	#EX: If $Pub = "Microsoft" it will only match entries that say "Microsoft", not "Microsoft Apps"
	
	if($nonCompliantPublishers -contains $pub) { return $nam, $pub,"Non-Compliant", "$pub is Non-Compliant" }
	if($nonCompliantApps -contains $nam) { return $nam, $pub,"Non-Compliant", "$nam is Non-Compliant" }
	if($compliantPublishers -contains $pub) { return $nam, $pub,"Compliant", "$pub is Compliant" }
	if($compliantApps -contains $nam) { return $nam, $pub,"Compliant", "$nam is Compliant" }
	return $nam, $pub,"Unassessed", "$nam - $pub has NOT been Assessed"
}

#This reads our compliance list file and saves it
$complianceRules = Import-csv -Path ".\complianceList.csv"
if (-not $complianceRules) { throw "complianceList.csv empty or not found" }

$compliantApps = 
	$complianceRules | Select-Object -ExpandProperty 'Compliant Applications'|
	ForEach-Object { $_.Trim() } | Where-Object { $_ } | Sort-Object -Unique

$compliantPublishers = 
	$complianceRules | Select-Object -ExpandProperty 'Compliant Publishers'|
	ForEach-Object { $_.Trim() } | Where-Object { $_ } | Sort-Object -Unique

$nonCompliantApps = 
	$complianceRules | Select-Object -ExpandProperty 'Non-Compliant Applications'|
	ForEach-Object { $_.Trim() } | Where-Object { $_ } | Sort-Object -Unique

$nonCompliantPublishers = 
	$complianceRules | Select-Object -ExpandProperty 'Non-Compliant Publishers'|
	ForEach-Object { $_.Trim() } | Where-Object { $_ } | Sort-Object -Unique

#This reads our apps file and saves it
$applicationsList = Import-csv -Path ".\apps.csv"
if (-not $applicationsList) { throw "apps.csv empty or not found" }

#Our blank list to put all of our completed objects into
$complianceExport = [System.Collections.Generic.List[object]]::new()


foreach($brave in $applicationsList) {
	
	#Calls the GetInfo function while passing through our $brave object
	$dummy = Getinfo $brave
	
	#Creates our new object to place into the object we're going to export
	[void]$complianceExport.add([pscustomobject]@{
		#Could use $brave for these two, but we're already getting objects returned, so might as well use those instead of longer code
		Name = $dummy[0]
		Publisher = $dummy[1]
		
		Compliance = $dummy[2]
		Reason = $dummy[3]
})
}

#Exports the CSV file
$complianceExport | Export-Csv '.\appCompliance.csv' -NoTypeInformation -Encoding UTF8
Invoke-Item '.\appCompliance.csv'
