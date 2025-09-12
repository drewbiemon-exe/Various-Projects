<#
.SYNOPSIS
    Generates MSBT entries for char1 and char2 entries for use with Super Smash Brothers Ultimate

.DESCRIPTION
    This script takes a comma-separated list of names, a starting index, and an internal
    character identifier. It outputs two sets of entries:
      - char1: Title Case (used for character select)
      - char2: Uppercase (used for entering/winning matches)

.PARAMETER Name
    Single string converted to comma-separated list of character names. Example: "kirby, pikachu, perfect cell" results in "kirby" "pikachu" "perfect cell"

.PARAMETER StartAt
    Starting index for numbering. Useful when skin IDs begin at a non-zero value.

.PARAMETER InternalName
    Internal character identifier used by the game (e.g. "demon" for Kazuya).

.EXAMPLE
    ./MsbtNameGenerator.ps1 -Name "kirby, pikachu, coach" -StartAt 0 -InternalName "demon"

    Produces MSBT entries with labels nam_char1_00_demon … nam_char2_02_demon.

.NOTES
    Author: Drew Stauft
    Created: 09/05/2025
    License: MIT
#>


# What data this script will take. This data is mandatory
Param ( 

# The names we're using to fill the fields. The data type isn't specified because this is converted into an array after receiving.
[Parameter(Mandatory = $true)]
$name, 

# Where we want to start counting at. If you only have three skins (5, 6, 7) you can start the count at 5 to get the accurate results ready to copy paste.
[Parameter(Mandatory = $true)]
[int]$startat, 


# The name the base character is referred to internally by the game. For example, Kazuya's internal name is 'demon'
[Parameter(Mandatory = $true)]
[string]$internalname )


# Splits the names provided by where the comma is placed
$name = $name -split "," | ForEach-Object { $_.Trim() }

# We're using another variable to count here because we need to preserve startat for resetting after the first loop
$num = $startat

# This lets us get our sentence case standard
$SentenceInfo = [System.Globalization.CultureInfo]::CurrentCulture


# Outputs the char1 part of the msbt (the name that shows up when you select them)
foreach($n in $name) {
	Write-Output "	<entry label=`"nam_chr1_0$($num)_$($internalname)`">"
	Write-Output "		<text>$($SentenceInfo.TextInfo.ToTitleCase($n.ToLower()))</text>"
	Write-Output "	</entry>"
	$num++
}

# Resets our counter so our second loop can function like the first
$num = $startat

# Outputs the char2 part of the msbt (the name that shows up when you enter + win a match)
foreach($n in $name) {
	Write-Output "	<entry label=`"nam_chr2_0$($num)_$($internalname)`">"
	Write-Output "		<text>$($n.ToUpper())</text>"
	Write-Output "	</entry>"
	$num++
}
