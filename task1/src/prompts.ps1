# Christopher King-Parra 011956373
# Run various sysadmin tasks from an interactive menu.


function appendLogFileNames {
  "appendLogFileNames"
}


function displayAscendingFiles {
  "displayAscendingFiles"
}


function displayCpuMemUsage {
  "displayCpuMemUsage"
}


function displayProcessesByVss {
  "displayProcessByVss"
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
    if (-not $HideMenu) {
      Show-Menu
    }
    if ($answer -eq "") {
      [Int]$answer = Read-Host "`nEnter task number [1-5]"
    }
    switch ($answer) {
      1 { appendLogFileNames -Directory "$env:PROJ_ROOT/data" -OutFile "$env:PRROJ_ROOT/data/DailyLog.txt" }
      2 { displayAscendingFiles }
      3 { displayCpuMemUsage }
      4 { displayProcessesByVss }
      5 { exit }
      Default { "Invalid input. Only 1-5 are recognized. Press 5 to exit."}
    }
    if ($RunOnce) {
      exit
    }
  }
}
