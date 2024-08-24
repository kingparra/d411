# Christopher King-Parra 011956373
# Run various sysadmin tasks from an interactive menu.


function appendLogFileNames {
  "appendLogFileNames"
}


function displayAscendingFiles {
  "displayAscendingFiles"
}

function Validate-Directory($dir) {
  if ((Test-Path $dir) -eq $false) {
    throw "File does not exist or is inaccesible"
  } elseif (Test-Path -PathType Leaf $dir) {
    throw "Directory must be directory not a file"
  } else {
    $true
  }
}


function Validate-File($file) {
  if (Test-Path -PathType Container $file) {
    throw "OutFile must be a file, not a directory"
  } else {
    $true
  }
}


function appendLogFileNames {
  [CmdletBinding()]
  param (
    # Directory to list *.log files from
    [Parameter(Mandatory=$true)]
    [String]
    $Directory,

    # File to append list of existing log files to
    [Parameter(Mandatory=$true)]
    [String]
    $OutFile,

    # Whether to append to the file or output directly
    [Parameter(Mandatory=$false)]
    [Switch]
    $ValueOnly
  )
  if ((Validate-Directory $Directory) -and (Validate-File $OutFile)) {
    $names = Get-ChildItem $Directory |
    Where-Object { $_.Name -cmatch '.*\.log$' } |
    ForEach-Object { $_.Name }
    if ($names.Count -eq 0) {
      $names = @("[no_files_found]")
    }
    $date = Get-Date -Format "HH:mm:dd"
    $result = "$date $names`n"
    if ($ValueOnly) {
      # Output object directly
      $result
    } else {
      Write-Output "Wrote log entry to $OutFile."
      # Append results to a file.
      $result >> $OutFile
    }
  }
}


function displayCpuMemUsage {
  "displayCpuMemUsage"
}


function displayProcessesByVss {
  [CmdletBinding()]
  param (
    # Output objects or formatted text
    [Parameter(Mandatory=$false)]
    [Switch]
    $AsObjects
  )
  $processes = Get-Process
  # Sort by virtual size least to greatest
  $sorted = $processes | Sort-Object { $_.VirtualMemorySize }
  # Show Vss column in output table
  $columnated = $sorted | Select-Object Id, VirtualMemorySize, BasePriority, CommandLine
  if ($AsObjects) {
    # return columnated objects
    $columnated
  } else {
    # convert to text with unlimited line width
    $formated = $columnated | Out-String -Width 100000000
    # return formatted text
    $formated
  }

}


function Show-Menu {
@"
Administrative tasks:

1. Record list of *.log files in Requirements1 to Requirements1/DailyLog.txt with timestamp.

2. List files in Requirements1 in tabular format, sorted in ascending alphabetical order.

3. List current CPU and memory usage

4. List running processes sorted by virtual size (least to greatest) in a gird format

5. Exit the script
"@
}


function Run-Menu {
  param (
    # Provide an answer for the menu.
    # This will run over and over again in a loop
    # unless the -RunOne switch is also used.
    [Parameter(Mandatory=$false)]
    [ValidateSet(1,2,3,4,5)]
    [Int]
    $Answer,

    # Whether to hide the menu an only print the
    # prompt and response from the dispatched function.
    [Parameter(Mandatory=$false)]
    [Switch]
    $HideMenu,

    # Only run the menu selection dialouge once.
    [Parameter(Mandatory=$false)]
    [switch]
    $RunOnce = $false
  )
  while ($true) {
    if ($HideMenu -eq $false) {
      Show-Menu
    }
    if ($answer -eq "") {
      [Int]$answer = Read-Host "`nEnter task number [1-5]"
    }
    switch ($answer) {
      1 { appendLogFileNames -Directory "$env:PROJ_ROOT/data" -OutFile "$env:PRROJ_ROOT/data/DailyLog.txt" }
      2 { displayAscendingFiles | more }
      3 { displayCpuMemUsage | more }
      4 { displayProcessesByVss | more }
      5 { exit }
      Default { "Invalid input. Only 1-5 are recognized. Press 5 to exit."}
    }
    if ($RunOnce) {
      break
    }
    Clear-Variable answer
    Clear-Host
  }
}

# Only execute Run-Menu if called as a script,
# rather than dot sourced or called using an
# operator.
If ((Resolve-Path -Path $MyInvocation.InvocationName).ProviderPath -eq $MyInvocation.MyCommand.Path) {
  Run-Menu
}
