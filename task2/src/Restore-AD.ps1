# Christopher King-Parra 011956373
Import-Module ActiveDirectory

# If Finance already exists delete it
function Get-FinanceOU {
  Get-ADOrganizationalUnit `
    -Filter {(ObjectClass -eq 'organizationalunit') -and (Name -eq "Finance")}
}

if (Get-FinanceOU) {
  # Get-FinanceOU returns a result that is not $null or empty
  try {
    Write-Output "Finance already exists, deleting Finance"
    Remove-ADOrganizationalUnit -Recursive -Confirm:$false $(Get-FinanceOU)
  } catch {
    throw "Failed to delete the Finance OU. Error: $_"
  }
} else {
  Write-Output "Finance does not exist, continuing"
}

# Create Finance OU
Write-Output "Creating Finance OU"
New-ADOrganizationalUnit -Name "Finance" `
  -ProtectedFromAccidentalDeletion $false
if (Get-FinanceOU) {
  Write-Output "Created new Finance OU"
}

# Import data from financePersonnel.csv into the finance OU.
$users = Import-Csv "financePersonnel.csv"
foreach ($user in $users) {
  $FullName = "$($user.First_Name) $($user.Last_Name)"
  Write-Output "Creating user $FullName"
  try {
    New-ADUser `
      -Name $FullName `
      -GivenName $user.First_Name `
      -Surname $user.Last_Name `
      -SamAccountName $user.samAccount `
      -DisplayName $FullName `
      -PostalCode $user.PostalCode `
      -MobilePhone $user.MobilePhone `
      -OfficePhone $user.OfficePhone `
      -Path $(Get-FinanceOU)
  } catch {
    Write-Error "Failed to create user $FullName. Error: $_"
  }
}

try {
  Get-ADUser `
    -Filter * `
    -SearchBase "ou=Finance,dc=consultingfirm,dc=com" `
    -Properties DisplayName,PostalCode,OfficePhone,MobilePhone `
    > "AdResults.txt"
} catch {
  Write-Error "Failed to retrieve AD users or save results. Error: $_"
}
