# Christopher King-Parra 011956373
# Recreate ClientDB then import data from NewClientData.csv into the Client_A_Contacts table.

# The SqlServer exposes the hierarchy of SQL server objects as a virtual file system (psdrive)
if (Get-Module SqlServer) {
  Import-Module SqlServer
} else {
  Install-Module SqlServer
  Import-Module SqlServer
}

# Check that SQL server service is running
if ((Get-Service -Name "MSSQL`$SQLEXPRESS").Status -ne "Running") {
  throw "MSSQL service is not running, bailing out"
}

# Set default parameter values so we don't have to type the host and dbname every time.
# See about_Parameters_Default_Values for more.
$PSDefaultParameterValues = @{
  # Use the server named SQLEXPRESS on the current host
  '*-Sql*:ServerInstance' = '.\SQLEXPRESS'
  # Default to using the ClientDB for sql commands
  'Invoke-Sqlcmd:Database' = 'ClientDB'
}

# Output whether ClientDB exists
if (Get-SqlDatabase -Name "ClientDB") {
  Write-Output "ClientDB exists, deleting ClientDB"
  # Delete ClientDB
  Invoke-Sqlcmd -Database "master" -Query "DROP DATABASE ClientDB"
}

# Create a new database named ClientDB and output that it was created
Write-Output "Recreating ClientDB"
Invoke-Sqlcmd -Database "master" -Query "CREATE DATABASE ClientDB"

# Create the Client_A_Contacts table and output that it was created
Write-Debug "Checking if Client_A_Contacts already exists, and deleting old table"
Invoke-Sqlcmd "if OBJECT_ID('Client_A_Contacts', 'U') is not NULL drop table Client_A_Contacts;"

Write-Output "Creating Client_A_Contacts table in ClientDB"
Invoke-Sqlcmd -Query @"
CREATE TABLE Client_A_Contacts (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(100),
    last_name NVARCHAR(100),
    city NVARCHAR(100),
    county NVARCHAR(100),
    zip NVARCHAR(10),
    officePhone NVARCHAR(30),
    mobilePhone NVARCHAR(30)
)
"@

# Import data from NewClientData.csv
$csvData = Import-Csv "NewClientData.csv"
foreach ($row in $csvData) {
  $insertQuery = @"
    INSERT INTO Client_A_Contacts
      (first_name, last_name, city, county, zip, officePhone, mobilePhone)
    VALUES ('$($row.first_name)',
            '$($row.last_name)',
            '$($row.city)',
            '$($row.county)',
            '$($row.zip)',
            '$($row.officePhone)',
            '$($row.mobilePhone)')
"@
  Invoke-Sqlcmd -Query $insertQuery
}

# Generate output file for submission
Invoke-Sqlcmd -Query 'SELECT * FROM dbo.Client_A_Contacts' > .\SqlResults.txt
