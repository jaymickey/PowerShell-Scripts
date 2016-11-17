# Ignore the default AD groups
$groupsToIgnore = @("Domain Computers", "Domain Controllers", "Schema Admins",
                    "Enterprise Admins", "Cert Publishers", "Domain Admins",
                    "Domain Users", "Domain Guests", "Group Policy Creator Owners", 
                    "RAS and IAS Servers", "Allowed RODC Password Replication Group", 
                    "Denied RODC Password Replication Group", "Read-only Domain Controllers", 
                    "Enterprise Read-only Domain Controllers", "Cloneable Domain Controllers", 
                    "Protected Users", "Key Admins", "Enterprise Key Admins", "DnsAdmins", 
                    "DnsUpdateProxy")
# Get all AD Groups that aren't in the Builtin container
$allGroups = Get-ADGroup -Filter * | Where {$_.DistinguishedName -notlike "*Builtin*" -and $_.Name -notin $groupsToIgnore}
# Empty array to store list of empty groups
$emptyGroups = @()

ForEach ($group in $allGroups) 
{
    # Get group members, including members of groups within the group
    $groupMembers = Get-ADGroupMember -Identity $group -Recursive
    # Empty array to store list of valid (enabled) members
    $validMembers = @()

    if ($groupMembers)
    {
        ForEach ($member in $groupMembers)
        {
            # Check the objectClass. Should be either a user or computer
            if ($member.objectClass -eq "user")
            {
                # Get the ADUser account
                $member = Get-ADUser $member
                # Check if it is enabled, if it is add to the valid members array
                if ($member.Enabled) {$validMembers += $member}
            }
            else
            {
                # Get the ADComputer account
                $member = Get-ADComputer $member
                # Check if it is enabled, if it is add to the valid members array
                if ($member.Enabled) {$validMembers += $member}
            }
        }

        # Check is there are any valid members, true if empty
        if (!($validMembers)) 
        {
            # Add to empty group array
            $emptyGroups += $group
        }
    } 
    else
    {
        $emptyGroups += $group
    }
}

if (Test-Path .\ScriptOutput)
{
    $emptyGroups.Name | Out-File .\ScriptOutput\EmptyGroups.txt
}
else
{
    New-Item .\ScriptOutput -ItemType Directory | Out-Null
    $emptyGroups.Name | Out-File .\ScriptOutput\EmptyGroups.txt
}