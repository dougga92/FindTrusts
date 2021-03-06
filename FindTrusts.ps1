#This Sample Code is provided for the purpose of illustration only
#and is not intended to be used in a production environment.  THIS
#SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT
#WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
#LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS
#FOR A PARTICULAR PURPOSE.  We grant You a nonexclusive, royalty-free
#right to use and modify the Sample Code and to reproduce and distribute
#the object code form of the Sample Code, provided that You agree:
#(i) to not use Our name, logo, or trademarks to market Your software
#product in which the Sample Code is embedded; (ii) to include a valid
#copyright notice on Your software product in which the Sample Code is
#embedded; and (iii) to indemnify, hold harmless, and defend Us and
#Our suppliers from and against any claims or lawsuits, including
#attorneys' fees, that arise or result from the use or distribution
#of the Sample Code. 

Import-module ActiveDirectory
$DomainDNS = (Get-ADDomain).DNSRoot

$stale =@{}
$StaleDate = (Get-date).addDays(-31)

Write-output "Get list of AD Domain Trusts in $DomainDNS `r"
$ADDomainTrusts = Get-ADObject -Filter {ObjectClass -eq "trustedDomain"} -Properties *
$ADDomainTrustsCount = ($ADDomainTrusts | Measure-Object).count

Write-Output "Discovered $ADDomainTrustsCount trusts in $DomainDNS"

IF ($ADDomainTrustscount -ge 1)
{ ## OPEN IF ($ADDomainTrustsCount -ge 1)
ForEach ($Trust in $ADDomainTrusts)
{ ## OPEN ForEach ($Trust in $ADDomainTrusts)


$TrustName = $Trust.Name
$TrustDescription = $Trust.Description
$TrustCreated = $Trust.Created
$TrustModified = $Trust.Modified
$TrustDirectionNumber = $Trust.trustDirection
$TrustTypeNumber = $Trust.trustType
$TrustAttributesNumber = $Trust.trustAttributes

# Capture StaleTrusts
If ($TrustModified -lt $StaleDate)
    {
     $Stale.add($TrustName,$TrustModified)
    }

SWITCH ($TrustTypeNumber)
{ ## OPEN SWITCH ($TrustTypeNumber)
1 { $TrustType = "Downlevel (Windows NT domain external"}
2 { $TrustType = "Uplevel (Active Directory domain - parent-child, root domain, shortcut, external, or forest"}
3 { $TrustType = "MIT (non-Windows) Kerberos version 5 realm"}
4 { $TrustType = "DCE (Theoretical trust type - DCE refers to Open Group's Distributed Computing Environment specification."}
} ## CLOSE SWITCH ($TrustTypeNumber)

IF (!$TrustType) { $TrustType = $TrustTypeNumber }


# https://msdn.microsoft.com/en-us/library/cc223779.aspx
SWITCH ($TrustAttributesNumber)
{ ## OPEN SWITCH ($TrustTypeNumber)
1 { $TrustAttributes = "Non-Transitive"}
2 { $TrustAttributes = "Uplevel clients only (Windows 2000 or newer"}
4 { $TrustAttributes = "Quarantined Domain (External)"}
8 { $TrustAttributes = "Cross-Forest Trust"}
10 { $TrustAttributes = "Cross-Organizational Trust (Selective Authentication)"}
20 { $TrustAttributes = "Intra-Forest Trust (trust within the forest)"}
} ## CLOSE SWITCH ($TrustTypeNumber)

IF (!$TrustAttributes) { $TrustAttributes = $TrustAttributesNumber }

SWITCH ($TrustDirectionNumber)
{ ## OPEN SWITCH ($TrustTypeNumber)
1 { $TrustDirection = "Inbound (TrustING domain)"}
2 { $TrustDirection = "Outbound (TrustED domain)"}
3 { $TrustDirection = "Bidirectional (two-way trust)"}
} ## CLOSE SWITCH ($TrustTypeNumber)

IF (!$TrustDirection) { $TrustDirection = $TrustDirectionNumber }

Write-output "Trust Name: $TrustName `r "
Write-output "Trust Description: $TrustDescription `r "
Write-output "Trust Created: $TrustCreated `r "
Write-output "Trust Modified: $TrustModified `r "
Write-output "Trust Direction: $TrustDirection `r "
Write-output "Trust Type: $TrustType `r "
Write-output "Trust Attributes: $TrustAttributes `r "
Write-output " `r "

} ## CLOSE ForEach ($Trust in $ADDomainTrusts)
} ## CLOSE IF ($ADDomainTrustsCount -ge 1)

$CountStale=$stale.count
Write-Host " "
Write-host "Found $ADDomainTrustsCount trust(s)"
Write-Host "Found $CountStale stale trust(s)"
$Stale



Write-Host ""
write-Host "Explanation of Trust Type"
Write-Host "https://msdn.microsoft.com/en-us/library/cc223771.aspx"

Write-host ""
Write-Host "Explanation of Trust Direction"
Write-host "https://msdn.microsoft.com/en-us/library/cc223768.aspx"

Write-host ""
Write-Host "Explanation of Trust Attributes"
Write-Host "https://msdn.microsoft.com/en-us/library/cc223779.aspx"

Write-host ""
Write-Host "Active Directory : Design Considerations and Best Practices"
Write-Host "https://social.technet.microsoft.com/wiki/contents/articles/52587.active-directory-design-considerations-and-best-practices.aspx"

Write-host ""
Write-Host "Active Directory Forest Trust: Attention Points"
Write-Host "https://social.technet.microsoft.com/wiki/contents/articles/50969.active-directory-forest-trust-attention-points.aspx"