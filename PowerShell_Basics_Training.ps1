# Powershell syntax
# Cmdlets - Generally Verb-Noun, eg: Get-Service; Stop-Process; New-ADUser
# Parameters, or "switches" as is common venacular, are accessed via a dash (-), eg: Get-Service -ComputerName PC01

Get-Process
Get-Service
Get-Service -Name Dhcp
Get-ChildItem -Directory

# PowerShell often accepts wildcards, generally on filter commands, but try it if you're unsure.

Get-ChildItem -Filter *.txt # * replaces any number of chars
Get-Service -Name d*
Get-ChildItem -Filter *.do?x # ? relaces a single char

# THE HELP SYSTEM
# The help system in powershell is very powerful
# It's recommended you download the latest version of the help files "every now and again"

Update-Help

Get-Help Get-Service
Get-Help *service
Get-Help Get-Service -Detailed
Get-Help Get-Service -Online
Get-Help Get-Service -ShowWindow
Get-Help Get-Service -Examples

# Aliases are shortened or alternate commands that will call a Cmdlet
# PowerShell accepts many "linux" commands as aliases to PowerShell Cmdlets

cd C:\Users # Set-Location -Path C:\Users
ls # Get-ChildItem
pwd # Get-Location

# Cmdlet to find aliases

Get-Alias
Get-Alias ls
Get-Alias -Definition Get-ChildItem

# Get-Command will allow us to locate additional Cmdlets based on wildcard entries

Get-Command *Alias # Find Cmdlets for dealing with Aliases
Get-Command Get-Alias -Syntax # See the syntax of a Cmdlet
Get-Command -ParameterName "ComputerName" # List Cmdlets that have a -ComputerName parameter

# Grouping Operator
(10 + 1) # Grouping Expression
((10 + 1) * 10) # You can group statements here, not just basic maths
(Get-Date).AddDays(-30) # Get the date 30 days in the past

# Range Operator
1..10
-1..-10

# Basic data types

# 32bit Int
(1).GetType().FullName
# Double
(1.1).GetType().FullName
# String 
("a").GetType().FullName # By default, PowerShell will store a single character and a string
# Char
([char]"a")GetType().FullName # Casting a variable to a type
# Array
("One","Two","Three").GetType().FullName # The [] at the end of System.Object[] denotes that it is an array

# Casting
'String'
"Also String"
"1" -as [int]
1 -as [String]

# Other ways to represent an array
@()
,"One"

# Referencing arrays
@(1..10)[0] # PowerShell arrays are 0 indexed
@(1..10)[1, 3, 6]
@(1..10)[-1..-3] # Use negative numbers to start from the end of the array. -1 is the last element

# Variables

$Test = "Hello" # Assign variables using $VariableName = Value
# Assignment Operators:
$test = 1 # = to assisgn a variable
$test += 2 # Add to existing value stored in variable. Equivilent to $test = $test + 2
$test -= 1 # Subtract from existing value, similar to above
$test++ # Add 1
# The above behaviour will change depending on the data type, more on that later
 
Write-Output "This is a $Test" # Double quotes will evalute the variable
Write-Output 'This is a $Test' # Single quotes will not
# System variables
# PowerShell has some build in variables, more than is reasonable to list...
$ErrorActionPreference
$PSVersionTable.PSVersion
# I will demonstrate a way to find these later

# Using Cmdlets and Pipeline
# Filtering and output
# Rule: Filter on the left, sort and format on the right

# The pipeline allows you to push data from one Cmdlet to another Cmdlet, provided it accepts that data
# Cmdlets with the same noun can often be piped

Get-Service -DisplayName "DFS Namespace" | Stop-Service
Get-Service -DisplayName "DFS Namespace" | Start-Service
New-Item test.txt -ItemType 'file'
Get-ChildItem test.txt | Remove-Item

# You can also pipe cmdlets to filter, sort and format data
# The $_ variable refers to the object being received through the pipeline

Get-Service -Name N* | Where-Object {$_.Status -eq "Running"}  | Sort-Object DisplayName
# $_.Status refers to the Status property of the object parsed by Get-Service - More info after Comparison Operators

# Logical Operators
# "Is x <something y"
1 -gt 0 # Greater than
1 -lt 0 # Less than
1 -eq 0 # Equal to
1 -ne 0 # Not equal to

# Connect Operators
(1 -is [int] -and 'one' -is [string]) # Will only return true if both are true
(1 -is [int] -or 'one' -is [int]) # Will only return true if both are true

# Comparison Operators
"This is a string" -like "*string" # Compare with wildcards
"This is a string" -notlike "*strang" # Opposite of the above
"One","Two","Three" -contains "One" # Check if an array contains a value
"One","Two","Three" -notcontains "Four" # Check if an array does NOT contain a value
"One" -in "One","Two","Three" # Like contains, but opposite direction
"Four" -notin "One","Two","Three" # Like contains, but opposite direction

# Regular Expressions
"C:\Somefilepath\file.txt" -match "^[a-zA-Z]:\\.+[.]txt" # Match based on regular expression
"C:\Somefilepath\file.txt" -imatch "^[a-zA-Z]:\\.+[.]txt" # Match based on regular expression, ignoring case
"C:\Somefilepath\file.txt" -cmatch "^[a-z]:\\.+[.]txt" # Match based on regular expression, enforcing case
"C:\Somefilepath\file.txt" -notmatch "^[a-z]:\\.+[.]txt" # Check if it doesn't match based on regular expression

# Piping to Get-Member allows you to see all the member properties and methods for the object produced by that Cmdlet

Get-Service | Get-Member 
Get-ChildItem | Get-Member -MemberType Property
Get-Process | gm -View all # Sometimes Get-Member will not show all available properties or methods
# There are some cases where this won't show you all available properties for a cmdlet.
# One example is the Get-ADUser cmdlet for Active Directory
# Compare the following (on a domain controller 2008 R2+)
Get-ADUser administrator | gm
# With this command
Get-ADUser administrator -Properties * | gm
# The second command should provide you with a lot more properties
<# This behaviour is rather unique to the Get-ADUser cmdlet. Not all properties will be available
down the pipeline, unless they are specifically requested using the -Properties parameter. #>

# Selecting information
# Piping to Select-Object will let you choose the properies of the object you want to view

New-Item test2.txt -ItemType 'file'
Get-Item "test.txt" # Basic information about the file
Get-Item "test.txt" | gm # See the properties of the object
Get-Item "test.txt" | Select-Object Name, Extension, CreationTime # Select the information to see

# Formatting information
# We can also use formatting commands to select properties and output to the shell
Get-Service d* | Format-Table Name, Status, CanStop, StartType
# Depending on the PS Version, this might look a bit ugly, but we can force PowerShell to resize it
# On Windows 10 the following probably won't look any different
Get-Service d* | Format-Table Name, Status, CanStop, StartType -AutoSize # Format-Table alias is ft
Get-Service d* | Format-List Name, Status, CanStop, StartType # Format-List alias is fl

# Exporting data
# Often you want to export information to a format that can be sent to a client or IT manager

# Piping to Export-CSV followed by a path+filename will export what would have been the console output to a CSV file 
Get-Service | Export-Csv C:\Users\Administrator\Desktop\test.csv
# You can use Select-Object to choose which information you want to display
# The -NoTypeInformation parameter switch will suppress the type information at the top of the CSV file
Get-Service | Select Name, Status, CanStop | Export-CSV test.csv -NoTypeInformation
# Open in MS Excel to make it easier to see and edit the information
# Don't use formatting commands when exporting to a file.
# Run the following:
Get-Service | Format-Table Name, Status | Export-Csv text2.csv -NoTypeInformation
<# You'll notice that the output is nothing but complete nonsense. This is actually formatting data used
by PowerShell to format the console output, as a result the Format Cmdlets should only used while within
the terminal #>

# Object Orientation in PowerShell
# In PowerShell, everything is considered an object. With all objects referring to the .Net object it represents
# Eg. Get-Service produces a collection of System.ServiceProcess.ServiceController objects
# The collection is select is a System.Object[] array

(Get-Service dhcp).GetType().FullName
(Get-Service).GetType().FullName
(Get-Service).GetType() # Here we can actually see the BaseType of System.Array

# Understanding this object model is key to understanding PowerShell