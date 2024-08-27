*****************************
 Learn PowerShell by Example
*****************************
This file contains a transcript of my experimentation
with powershell at the prompt to learn the language.

The idea is to create a cheat-sheet just for me, that
doesn't include information that's too obvious (like
comparison operators or arithmetic), and goes into
depth on topics I'm interested (variables, functions,
classes, modules, .net interop).

This information comes from a variety of sources
including the official documentation, learnxinyminute.com,
a few pluralsight videos, and a smattering of blog articles.


Getting help
------------
::


  $ # Show the first 20 lines of the examples section
  $ help -Examples Select-Object | Select-Object -First 20
  ...
      ## Example 1: Select objects by property
      >>> Get-Process | Select-Object -Property ProcessName, Id, WS
  ...
      ## Example 2: Select objects by property and format the results
      >>> Get-Process Explorer |
          Select-Object `
            -Property ProcessName `
            -ExpandProperty Modules |
          Format-List

  $ # View the help rendered as HTML in a windows help window
  $ get-help -showWindow whatever


Configuration files
-------------------
https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/creating-profiles?view=powershell-7.4

Configuration files for shell sessions are known as profiles,
and there are several profile files depending on which
user/host combination you want to scope to.

::

  $ help about_Profiles

The one we care about for personal use is: CurrentUserCurrentHost

::

  $ $PROFILE | Select-Object *
  AllUsersAllHosts: /opt/microsoft/powershell/7/profile.ps1
  AllUsersCurrentHost: /opt/microsoft/powershell/7/Microsoft.PowerShell_profile.ps1
  CurrentUserAllHosts: /root/.config/powershell/profile.ps1
  CurrentUserCurrentHost: /root/.config/powershell/Microsoft.PowerShell_profile.ps1
  Length: 57


To allow execution of the profile files on shell startup, you'll
have to edit the executionPolicy. This change is persistent, and
stored in the registry.

::

  $ Set-ExecutionPolicy RemoteSigned


Now we can change the profile, let's start by customizing the
prompt.

::

    function Prompt {
        $env:COMPUTERNAME + "\" + (Get-Location) + "> "
    }

You can edit the path like this:

::

  # Load scripts from the following locations
  $env:Path += ";D:\SysAdmin\scripts\PowerShellBasics"
  $env:Path += ";D:\SysAdmin\scripts\Connectors"
  $env:Path += ";D:\SysAdmin\scripts\Office365"newpath"

Or if you want to prepend to it, use this:

::



You can start a new shell without any profile using.

::

  $ pwsh -NoProfile

Profiles aren't run automatically in remote sessions. To run it explicitly
from the controller, use this command:

::

  Invoke-Command -Session $s -FilePath $PROFILE


Safety features
---------------

Impact Level
^^^^^^^^^^^^
Commands in powershell are assigned an *impact level*, which is intended
to indicate how distruptive a command can be to a running system.
You can set a threshold for this using the ``$ConfirmPreference`` variable.

::

  PS /> $ConfirmPreference = [System.Management.Automation.ConfirmImpact]::Low
  PS /> Set-date 'Jan 10 2000'
  Confirm
  Are you sure you want to perform this action?
  Performing the operation "Set-Date" on target "1/10/2000 12:00:00 AM".
  [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help
  (default is "Y"):

If a command isn't explicity assigned an impact level, it get "medium" by default.

WhatIf
^^^^^^
Many destructive commands have a ``-WhatIf`` flag, which performs a dry run.
::

  PS /etc> Remove-Item -Path *.d -WhatIf
  What if: Performing the operation "Remove Directory" on target "/etc/cron.d".
  What if: Performing the operation "Remove Directory" on target "/etc/init.d".
  What if: Performing the operation "Remove Directory" on target "/etc/pam.d".
  What if: Performing the operation "Remove Directory" on target "/etc/profile.d".
  What if: Performing the operation "Remove Directory" on target "/etc/rc0.d".
  What if: Performing the operation "Remove Directory" on target "/etc/rc1.d".
  ...

Confirm
^^^^^^^
Commands that support ``-WhatIf`` also support ``-Confirm``.

::

  PS /etc> Remove-Item -Confirm ./rc0.d/
  Confirm
  Are you sure you want to perform this action?
  Performing the operation "Remove Directory" on target "/etc/rc0.d/".
  [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help
  (default is "Y"): N

Comments
--------
::

  PS /> # This is a comment
  PS /> <# This is a
  >>       multi-line
  >>       comment
  >>    #>


Help
----
::

  get-help
  update-help


Writing to the screen
---------------------
::

  PS /> "this" | Out-Host
  this


Writing to a file
-----------------
::

  echo "yo" | out-file -append yo.log

Write to the printer
--------------------
::

  get-mailbox | out-printer

Convert a PS value to another format
------------------------------------
::

  PS /root> gcm -verb ConvertTo | select Name | Format-wide -AutoSize
  ConvertTo-Csv              ConvertTo-Html            ConvertTo-Json
  ConvertTo-SecureString     ConvertTo-Xml

  PS /root> "one", "two", "three" | ConvertTo-Json
  [
    "one",
    "two",
    "three"
  ]

Strings
-------
The escape character in PowerShell is the backtick, not backslash.
::

  PS /> echo "one`ntwo"
  one
  two

Multi-line strings must have ``@`` markers on their own line.
::


  PS /> $st2 = `
  >> @"multi-line
  ParserError:
  Line |
     2 |  @"multi-line string
       |    ~
       | No characters are allowed after a here-string header but before the end of
       | the line.

  PS /> $st2 = `
  >> @"
  >> multi-line
  >> string
  >> "@

You can't indent the markers, either.
You can get around this by concatenating an array of strings.

::

  PS />     $workaround = (
  >>                       "first line",
  >>                       "second line"
  >>                      ) -join "`n"
  PS /> Write-Host $workaround
  first line
  second line

You can even omit the commas.


Control-Flow Constructs
-----------------------
::

  # selection
  0 ? 'yes' : 'no'
  if ($cond) { } elseif ($cond2) { } else { }
  switch ($var) {
      'Val1' { }
      'Val2' { }
      default { }
  }

  # loops
  for ($i = 0; $i -lt $limit; $i++) { }
  foreach ($item in $collection) { }
  while ($cond) { }
  do { } while ($cond)
  do { } until ($cond)

  # keywords
  break      # exit loop/switch
  continue   # skip to next iteration
  return     # exit with optional value

  # exception handling
  try { } catch { } finally { }


Program structuring mechanisms
------------------------
::

  # classes
  class MyClass {
      [string]$Property
      MyClass([string]$param) { $this.Property = $param }  # Constructor
      [void] MyMethod() { "Method executed: $($this.Property)" }
  }
  $myObject = [MyClass]::new("Hello")
  $myObject.MyMethod()  # Outputs: Method executed: Hello


  # modules (put this in a .psm1 file)
  function MyFunction {
      "Function executed"
  }
  Export-ModuleMember -Function MyFunction
  # Importing a module (if this were in ExampleModule.psm1):
  # Import-Module ./ExampleModule.psm1
  # MyFunction()  # Outputs: Function executed


  # functions
  function Greet-User { param($Name) "Hello, $Name!" }
  Greet-User -Name "Chris"  # Outputs: Hello, Chris!


  # scriptblocks
  $myScriptBlock = { param($x) $x * $x }
  &$myScriptBlock -x 5  # Outputs: 25

  # generics
  # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_calling_generic_methods?view=powershell-7.4


Classes
-------
What's the difference between an initialization method and a regular method?
Nothing, init methods just set properties. That's all. That's the difference.

::

  ·∾ class Tree {
   ⋮  [Int]$Height
   ⋮  [Int]$Age
   ⋮  [String]$Color
   ⋮ }

  # There are three ways to construct an object from a class.
  ·∾ $tree1 = New-Object Tree
  ·∾ $tree1.Height = 10; $tree1.Age = 5; $tree1.Color = "Red"
  ·∾ $tree2 = [Tree]::new()
  ·∾ $tree2.Height = 20; $tree2.Age = 10; $tree2.Color = "Green"
  ·∾ $tree4 = [Tree]::new(@{"Height" = 30; "Age" = 15; "Color" = "Blue"})
  ·∾ $tree4 = [Tree]@{"Height" = 30; "Age" = 15; "Color" = "Blue"}

  ·∾ $tree1
  Height Age Color
  ------ --- -----
      10   5 Red

  ·∾ $tree2
  Height Age Color
  ------ --- -----
      20  10 Green

  ·∾ $tree3
  Height Age Color
  ------ --- -----
      30  15 Blue

  ·∾ $tree4
  Height Age Color
  ------ --- -----
      30  15 Blue

  # Get all members of a class
  ·∾ [System.Math] | Get-Member -Static -MemberType All

  ·∾ class Tree {
   ⋮   [Int]$Height
   ⋮   [Int]$Age
   ⋮   [String]$Color
   ⋮
   ⋮   Tree() {
   ⋮     $this.Height = 1
   ⋮     $this.Age = 0
   ⋮     $this.Color = "Green"
   ⋮   }
   ⋮
   ⋮   Tree([Int]$Height, [Int]$Age, [String]$Color) {
   ⋮     $this.Height = $Height
   ⋮     $this.Age = $Age
   ⋮     $this.Color = $Color
   ⋮   }
   ⋮ }
  ·∾

  ·∾ $tree1 = [Tree]::new()
  ·∾ $tree2 = New-Object Tree 5, 2, "Red"

  ·∾ $tree1
  Height Age Color
  ------ --- -----
       1   0 Green

  ·∾ $tree2
  Height Age Color
  ------ --- -----
       5   2 Red

  ·∾ class Tree {
   ⋮   [Int]$Height
   ⋮   [Int]$Age
   ⋮   [String]$Color
   ⋮
   ⋮   Tree() {
   ⋮     $this.Height = 1
   ⋮     $this.Age = 0
   ⋮     $this.Color = "Green"
   ⋮   }
   ⋮
   ⋮   Tree([Int]$Height, [Int]$Age, [String]$Color) {
   ⋮     $this.Height = $Height
   ⋮     $this.Age = $Age
   ⋮     $this.Color = $Color
   ⋮   }
   ⋮
   ⋮   [Void]Grow() {
   ⋮     $heightIncrease = Get-Random -Min 1 -Max 5
   ⋮     $this.Height += $heightIncrease
   ⋮     $this.Age += 1
   ⋮   }
   ⋮ }

  ·∾ $tree = [Tree]::New()
  ·∾ for ($i = 0; $i -lt 10; $i++) { $tree.Grow(); $tree }
  Height Age Color
  ------ --- -----
       3   2 Green
       6   3 Green
      10   4 Green
      11   5 Green
      14   6 Green
      15   7 Green
      17   8 Green
      19   9 Green
      22  10 Green
      24  11 Green

  ·∾ # Where classes become useful is when you start to use inheritance
  ·∾ class Tree {
   ⋮   [Int]$Height
   ⋮   [Int]$Age
   ⋮   [String]$Color
   ⋮
   ⋮   Tree() {
   ⋮     $this.Height = 1
   ⋮     $this.Age = 0
   ⋮     $this.Color = "Green"
   ⋮   }
   ⋮
   ⋮   Tree([Int]$Height, [Int]$Age, [String]$Color) {
   ⋮     $this.Height = $Height
   ⋮     $this.Age = $Age
   ⋮     $this.Color = $Color
   ⋮   }
   ⋮
   ⋮   [Void]Grow() {
   ⋮     $heightIncrease = Get-Random -Min 1 -Max 5
   ⋮     $this.Height += $heightIncrease
   ⋮     $this.Age += 1
   ⋮   }
   ⋮ }
  ·∾ class AppleTree : Tree {
   ⋮   [String]$Species = "Apple"
   ⋮ }
  ·∾ $tree = [AppleTree]::New()
  ·∾ $tree

  Species Height Age Color
  ------- ------ --- -----
  Apple        1   0 Green



Interfaces
----------
* https://stackoverflow.com/questions/51794092/how-to-use-interfaces-in-powershell-defined-via-add-type

::

  ·∾ Add-Type -TypeDefinition 'public interface ICanTalk { string talk(); }' -Language CSharp

  ·∾ class Talker : ICanTalk {
  ⋮   [String]talk() { return "Well hello there" }
  ⋮ }
  ·∾

  ·∾ $talker = [Talker]::new()
  ·∾ $talker.talk()
  Well hello there


Enums
-----
It seems that PowerShell has something similar to sum types.

::

  ·∾ enum Context { Component; Role; Location }
  ·∾ $item = [Context]::Role
  ·∾ Switch ($item) {
  ⋮   Component { 'is a component' }
  ⋮   Role      { 'is a role' }
  ⋮   Location  { 'is a location' }
  ⋮ }
  is a role

I'm not sure, but the switch statement may be doing silent type
coercion to strings. You can write this more explicity if you like.

::

  switch ($item ) {
      ([Context]::Component) {'is a component'}
      ([Context]::Role) {'is a role'}
      ([Context]::Location) {'is a location'}
  }

Providers, modules, and snap-ins
--------------------------------
Providers take some resource and represent it as a virtual file system.

::

  PS /root> Get-Command -Noun *Provider*
  CommandType     Name                                               Version
  -----------     ----                                               -------
  Function        Get-CredsFromCredentialProvider                    2.2.5
  Cmdlet          Find-PackageProvider                               1.4.8.1
  Cmdlet          Get-PackageProvider                                1.4.8.1
  Cmdlet          Get-PSProvider                                     7.0.0.0
  Cmdlet          Import-PackageProvider                             1.4.8.1
  Cmdlet          Install-PackageProvider                            1.4.8.1

Capabilities are a list of things you can do with each provider:

* ``ShouldProcess`` - Supports ``-WhatIf`` and ``-Confirm``.
* ``Filter``
* ``Credentials`` - You can use the ``-Credentials`` parameter with these cmdlets.
* ``Transactions``

Modules
-------
::

  find-module
  install-module
  update-module
  save-module
  uninstall-module

  PS /root> Get-Content Env:PSModulePath
  /root/.local/share/powershell/Modules:/usr/local/share/powershell/Modules:/opt/
  microsoft/powershell/7/Modules

Objects
-------
::

  get-member # list methods an properties of an object
  PS /root> "one" | Get-Member

     TypeName: System.String

  Name                 MemberType            Definition
  ----                 ----------            ----------
  Clone                Method                System.Object Clone(), System.Obje…
  CompareTo            Method                int CompareTo(System.Object value)…
  Contains             Method                bool Contains(string value), bool …
  CopyTo               Method                void CopyTo(int sourceIndex, char[…


Testing and comparing things
----------------------------
::

  # this is similar to diff, but it operates on objects
  PS /> Compare-Object (gci | select -First 1) (gci | select -Last 1)

  InputObject SideIndicator
  ----------- -------------
  /var        =>
  /bin        <=

  # Check if a path exists
  PS /etc> Test-Path ./hosts
  True
  PS /etc> test-path /etc/non/existant/path
  False

  # use comparison operators
  # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comparison_operators?view=powershell-7.4
  # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_regular_expressions?view=powershell-7.4
  PS /etc> Get-Help about_Comparison_Operators
  PS /etc> gci | where { $_.Name -like "h*" }
  UnixMode         User Group         LastWriteTime         Size Name
  --------         ---- -----         -------------         ---- ----
  -rw-r--r--       root root       10/15/2021 10:06           92 host.conf
  -rw-r--r--       root root        8/18/2024 22:58           12 hostname
  ...


Filter, map, sort, take, uniq
-----------------------------
::

  PS /etc> Get-ChildItem | Sort-Object -Descending
  UnixMode         User Group         LastWriteTime         Size Name
  --------         ---- -----         -------------         ---- ----
  -rw-r--r--       root root        3/23/2022 09:41          681 xattr.conf
  drwxr-xr-x       root root        2/27/2024 16:02           92 update-motd.d
  drwxr-xr-x       root root        2/27/2024 16:02           12 terminfo


  PS /etc> gci /etc/ | Sort-Object -Property Last-WriteTime | Select-Object -Last 5
  UnixMode         User Group         LastWriteTime         Size Name
  --------         ---- -----         -------------         ---- ----
  drwxr-xr-x       root root        2/27/2024 15:59           18 rcS.d
  drwxr-xr-x       root root        2/15/2022 22:32            0 rc6.d
  drwxr-xr-x       root root        2/15/2022 22:32            0 rc5.d
  -rw-r--r--       root root        2/25/2022 11:32         2355 sysctl.conf
  -rw-r--r--       root root        3/23/2022 09:41          681 xattr.conf


  # aliased to ?
  PS /etc> Get-ChildItem | Where-Object { $_.Size -eq 681 }
  UnixMode         User Group         LastWriteTime         Size Name
  --------         ---- -----         -------------         ---- ----
  -rw-r--r--       root root        3/23/2022 09:41          681 xattr.conf

  PS /> Get-ChildItem -Recurse | Where-Object { $_.Extension -eq ".so" }
      Directory: /opt/microsoft/powershell/7
  UnixMode         User Group         LastWriteTime         Size Name
  --------         ---- -----         -------------         ---- ----
  -rw-r--r--       root root        3/19/2024 19:26       823592 libclrgc.so
  -rw-r--r--       root root        3/19/2024 19:29      3609952 libclrjit.so

  PS /etc> gci -Recurse | select -First 10
  UnixMode         User Group         LastWriteTime         Size Name
  --------         ---- -----         -------------         ---- ----
  drwxr-xr-x       root root        4/10/2024 17:40           34 alternatives
  drwxr-xr-x       root root        2/27/2024 15:59          162 apt
  drwxr-xr-x       root root        4/10/2024 17:40           16 ca-certificates
  drwxr-xr-x       root root        2/27/2024 16:03           20 cloud
  drwxr-xr-x       root root        2/27/2024 16:02           22 cron.d
  drwxr-xr-x       root root        2/27/2024 16:02           28 cron.daily
  drwxr-xr-x       root root        4/10/2024 17:40           12 default
  drwxr-xr-x       root root        2/27/2024 16:02           50 dpkg
  drwxr-xr-x       root root        2/21/2022 20:05           12 gss
  drwxr-xr-x       root root        2/27/2024 16:02           32 init.d

  PS /etc> 1,1,2,2,3,3,4,5,6,7 | select -Unique
  1
  2
  3
  4
  5
  6
  7

  PS /etc> 1,1,2,2,3,3,4,5,6,7 | ForEach-Object { $_.GetType() }
  IsPublic IsSerial Name                                     BaseType
  -------- -------- ----                                     --------
  True     True     Int32                                    System.ValueType
  True     True     Int32                                    System.ValueType
  ...

  PS /etc> gci /etc/ | Group-Object -Property CreationTime | Select-Object -First 20

  Count Name                      Group
  ----- ----                      -----
      1 9/15/2018 10:14:19 PM     {/etc/deluser.conf}
      1 8/12/2020 12:15:04 AM     {/etc/pam.conf}
      3 12/16/2020 11:04:55 AM    {/etc/bindresvport.blacklist, /etc/ld.so.conf, /e…
      1 8/22/2021 5:00:00 PM      {/etc/debian_version}
      4 10/15/2021 10:06:05 AM    {/etc/host.conf, /etc/legal, /etc/networks, /etc/…
      1 11/11/2021 3:42:38 PM     {/etc/login.defs}
      1 1/6/2022 4:23:33 PM       {/etc/bash.bashrc}
      2 1/8/2022 8:02:36 PM       {/etc/e2scrub.conf, /etc/mke2fs.conf}
      1 2/3/2022 5:27:54 AM       {/etc/gai.conf}
      8 2/15/2022 10:32:46 PM     {/etc/rc0.d, /etc/rc1.d, /etc/rc2.d, /etc/rc3.d…}
      1 2/20/2022 2:42:49 PM      {/etc/debconf.conf}
      1 2/21/2022 8:05:20 PM      {/etc/gss}
      1 2/25/2022 11:32:20 AM     {/etc/sysctl.conf}
      1 3/17/2022 5:50:40 PM      {/etc/libaudit.conf}
      1 3/23/2022 9:41:49 AM      {/etc/xattr.conf}
      1 3/24/2022 4:13:48 PM      {/etc/netconfig}
      1 12/5/2023 5:15:51 AM      {/etc/rmt}
      1 1/2/2024 1:22:42 PM       {/etc/locale.alias}
      4 2/14/2024 2:47:50 PM      {/etc/issue, /etc/issue.net, /etc/lsb-release, /e…
      2 2/27/2024 3:59:33 PM      {/etc/opt, /etc/fstab}

  # filter out event log messages which are most common
  Get-EventLog -LogName Application -Newest 2500 |
    Group-Object -Property eventid |
    Sort-Object Count -descending |
    Format-Table Count, Name -autosize
Architecture
------------
::

  +-------------------------+
  |  Core Language Runtime  |
  +-------------------------+
  |         .Net            |
  +-----------+-------------+
  |   Libs    |  PowerShell |
  +-----------+-------------+
  |  PowerShell Modules     |
  +-------------------------+


Arrays
------
::

  $ $singleItemArr = ,7
  $ $multiItemArr = 1, 2, 3
  $ $rangeArr = 5..8
  $ [int32[]]$stronglyTypedArr = 1500, 2230, 3350, 4000

The array sub-experession operator ``@()`` creates an array from the
statements inside it.

::

  $ $a = @("Hello World")
  $ $a.Count
  1
  $ $p = @(Get-Process Notepad)

List slicing is pretty much the same as other C-like languages.

::

  $a[0]
  $a[1..4]
  $a[-3..-1]
  $a[0,2+4..6]

Multi-demensional arrays suck in powershell.

::

  # this is *not* a multi-dimensional array!
  $a = @(
    @(0,1),
    @("b", "c"),
    @(Get-Process)
  )

  # this is (;_;).... ;;;

  $ [string[,]]$rank2 = [string[,]]::New(3,2)
  $ $rank2.rank
  $ $rank2.Length
  $ $rank2[0,0] = 'a'
  $ $rank2[0,1] = 'b'
  $ $rank2[1,0] = 'c'
  $ $rank2[1,1] = 'd'
  $ $rank2[2,0] = 'e'
  $ $rank2[2,1] = 'f'
  $ $rank2[1,1]

  2
  6
  d

  # notice the weird list slicing notation? Why not $rank2[0][0] = 'a'?
  # this is all very confusing

  >>> $matrix = New-Object 'object[,]' 2,2 # 2d array of length 4
  >>> $matrix[0,0] = 10
  >>> $matrix[0,1] = $false
  >>> $matrix[1,0] = "red"
  >>> $matrix[1,1] = "blue"
  >>> $matrix.Rank
  2

Arrays have a handy ForEach method.
::

  >>> @(1,2,3).ForEach({$_ + 3})
  4
  5
  6


Hashtables
----------
Hashtables are PowerShells hererogenous key-value data structures.
Keys are unique, and not ordered by insertion time.
Hashtables can be used as input for class constructor methods, and can
populate the values of arguments to it.
It seems like dynamically typed languages have a huge emphasis on hashtables in general.

::

  PS /etc> $StateCapitals = @{
  >> "North Carolina" = "Raliegh";
  >> "California" = "Sacremento";
  >> "New York" = "Albany"
  >> }

  PS /etc> $StateCapitals["North Carolina"]
  Raliegh
  PS /etc> $StateCapitals["North Carolina"] = "Durham"
  PS /etc> $StateCapitals["North Carolina"]
  Durham

  PS /etc> $StateCapitals[4] = "Are tables heterogeneous?"
  PS /etc> $StateCapitals[4]
  Are tables heterogeneous?

  PS /etc> $StateCapitals

  Name                           Value
  ----                           -----
  New York                       Albany
  4                              Are tables heterogeneous?
  California                     Sacremento
  North Carolina                 Durham

  PS /etc> $StateCapitals | Get-Member

     TypeName: System.Collections.Hashtable

  Name              MemberType            Definition
  ----              ----------            ----------
  Add               Method                void Add(System.Object key, System.Object…
  Clear             Method                void Clear(), void IDictionary.Clear()
  Clone             Method                System.Object Clone(), System.Object IClo…
  Contains          Method                bool Contains(System.Object key), bool ID…
  ContainsKey       Method                bool ContainsKey(System.Object key)
  ContainsValue     Method                bool ContainsValue(System.Object value)
  CopyTo            Method                void CopyTo(array array, int arrayIndex),…
  Equals            Method                bool Equals(System.Object obj)
  GetEnumerator     Method                System.Collections.IDictionaryEnumerator …
  GetHashCode       Method                int GetHashCode()
  GetObjectData     Method                void GetObjectData(System.Runtime.Seriali…
  GetType           Method                type GetType()
  OnDeserialization Method                void OnDeserialization(System.Object send…
  Remove            Method                void Remove(System.Object key), void IDic…
  ToString          Method                string ToString()
  Item              ParameterizedProperty System.Object Item(System.Object key) {ge…
  Count             Property              int Count {get;}
  IsFixedSize       Property              bool IsFixedSize {get;}
  IsReadOnly        Property              bool IsReadOnly {get;}
  IsSynchronized    Property              bool IsSynchronized {get;}
  Keys              Property              System.Collections.ICollection Keys {get;}
  SyncRoot          Property              System.Object SyncRoot {get;}
  Values            Property              System.Collections.ICollection Values {ge…

  PS /etc> Get-Process | Select-Object @{Name = "The Name of the Process"; Expression = {$_.ProcessName}}
  The Name of the Process
  -----------------------
  pwsh-preview


Remoting
--------
* https://adamtheautomator.com/enable-psremoting/

Remote access is based on two technologies: WSMan and WinRM. WSMan is how the
commands are transmitted, and WinRM provides the session between the controller
and endpoint.

To use remoting, you have to perform a few steps:

1. Start the WinRM service
2. Create a WinRM listener
3. Enable firewall exceptions
4. Register a PowerShell session configuration
5. Enable the PowerShell session configuration
6. Set the PowerShell remote sessions to allow remote access
7. Restart the WinRM server to apply all of the changes.

::

  # give the user permission to run the service
  Add-LocalGroupMember -Group 'Remote Management Users' -Member user
  # Set the network mode to private
  Set-NetConnectionProfile -InterfaceIndex number -NetworkCategory Private
  # start and enable the service
  Enable-Psremoting

  # interactive session to one endpoint
  enter-pssession -computername target_computer

  # noninteractive command to one endpoint
  Invoke-Command -ComputerName JON-OFFICE  -scriptblock { Get-Process }

  # noninteractive command to multiple endpoints
  Invoke-Command -ComputerName SALESPC,ACCOUNTINGPC,RECEPTIONPC `
    -scriptblock { Get-EventLog -LogName Application -Newest 5}

  # Allow the following machines to remote in
  Set-item wsman:localhost\client\trustedhosts `
    -value RemotingLocalMachine1,RemotingLocalMachine2

  # List all open sessions available on this computer
  Get-PSSession

::

  PS /etc> help *remote*
  Name                              Category  Module                    Synopsis
  ----                              --------  ------                    --------
  about_Remote                      HelpFile
  about_Remote_Disconnected_Sessio… HelpFile
  about_Remote_Jobs                 HelpFile
  about_Remote_Output               HelpFile
  about_Remote_Requirements         HelpFile
  about_Remote_Troubleshooting      HelpFile
  about_Remote_Variables            HelpFile


Weird syntax
------------
Have you noticed that there are two flavors of syntax going on here? For vanilla powershell
there is ``cmdletname args``, and then there is ``[TypeName]::Method(arg1, arg2)`` syntax.
That second syntax is ``.Net`` syntax. So how do you look up documentation for something with
that syntax?

You use the dotnet developer documentation. With duckduckgo.com, you can type a query
like ``!dotnet String.new`` and get a result like this https://learn.microsoft.com/en-us/search/?terms=String.new&products=%2Fdevrel%2F7696cda6-0510-47f6-8302-71bb5d2e28cf


Modules
-------
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_modules?view=powershell-7.4

::

  >>> $env:PSModulePath
  /root/.local/share/powershell/Modules:/usr/local/share/powershell/Modules:/opt/micr
  osoft/powershell/7/Modules


Variables
---------
There are several different types of variables in PowerShell

* User-created
* Automatic (created and managed by PowerShell) about_Automatic_Variables
* Preference (stores preferences for PowerShell) about_Preference_Variables

PowerShell variables are loosely typed.
You can assign new values of different types to the same identifier.
The data type of a variable is determined by the .NET types of the values of that variable.

Variable names are not case sensitive, and can include spaces and special characters.


::

  # create a variable without assigning a value
  >>> New-Variable zzz

  # simplest possible assignment
  >>> $simple = "here is a simple value"
  >>> Set-Variable -Name simple -Value "here is a simple value"

  # variable names can even have spaces or special characters, including some unicode
  >>> ${this variable name} = "yo i heard you like spaces"
  >>> echo ${this variable name}
  yo i heard you like spaces

  # if you want to use braces in the identifier you have to escape it
  >>> ${this`{value`}is} = "This variable name has braces in it."

  # they are also case insensitive
  >>> echo ${this VARIABLE name}
  yo i heard you like spaces

  # the variable name length is only limited by available memory.
  # best practices is to use alphanumeric with snake_case.

  # you can do multiple assignment
  >>> $a = $b = $c = 0
  >>> $i, $j, $k = 10, "red", $true

  # by default values can be of any type and change over time
  >>> $loosely_typed = 0
  >>> $loosely_typed = "this"
  >>> $loosely_typed = 33.7

  # variable with type signatures try to coerce new values to that type
  >>> [Int]$number = 8
  >>> $number = "some randome string I guess"
  MetadataError: Cannot convert value "some randome string I guess" to type "System.Int32". Error: "The input string 'some randome string I guess' was not in a correct format."
  >>> $number = "100"

  # variable quoting rules
  >>> echo $number
  100
  >>> echo "$number"
  100
  >>> echo '$number'
  $number

  # variables are local by default, and lexically scoped.
  # but you can use a scope modifier to change the default scoep of the variable
  >>> $Global:Computers = "Server01"
  >>> Get-Variable -Scope Global -Name Computers
  Name                           Value
  ----                           -----
  Computers                      Server01


  # Variables can be interacted with by traversing a virtual file system (PSDrive)
  >>> Get-ChildItem Variable: | select -First 1

  Name                           Value
  ----                           -----
  ?                              True


Functions
---------
* https://adamtheautomator.com/powershell-parameter
* https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions?view=powershell-7.4
* https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced?view=powershell-7.4

Cmdlets are written in another language by software developers. Functions are
written in PowerShell by end users.

Functions in PowerShell are complex. There are multiple ways to define
them, and they try to build in argument parsing using parameter specifications.

First, let me show you the most general forms of a function definition,
from the docs.

::

  function [<scope:>]<name> [([type]$parameter1[,[type]$parameter2])]
  {
    begin {<statement list>}
    process {<statement list>}
    end {<statement list>}
    clean {<statement list>}
  }

  function [<scope:>]<name>
  {
    param([type]$parameter1 [,[type]$parameter2])
    dynamicparam {<statement list>}
    begin {<statement list>}
    process {<statement list>}
    end {<statement list>}
    clean {<statement list>}
  }

You aren't required to use any of these blocks (``begin``,
``process``, ..) in your functions. If you don't use a named
block, then PowerShell puts the code in the end block of the
function.

Now for some examples from the repl.

::

  # Parameters in PowerShell can be specified in many ways.
  # They can be named, positional, switch, or dynamic.
  # Parameters can be read from cli arguments or from the pipeline.

  # You can access the argv as an array named $args.
  >>> function Add-Numbers {
  >>   $args[0] + $args[1]
  >> }

  # Or you can use positional parameters.
  ∾  function add-SimpleParamNumbers($firstNumber, $secondNumber) {
   ⋮   $firstNumber + $secondNumber
   ⋮ }
  ∾  add-SimpleParamNumbers 88 100
  188

  # You can set default values for parameters like this
  ∾  function add-SimpleParamNumbers($firstNumber = 88, $secondNumber = 100) {
   ⋮   $firstNumber + $secondNumber
   ⋮ }
  ∾  add-SimpleParamNumbers
  188

  # With the param block you can specify more complex parameter descriptions.
  >>> function Add-ParamNumbers {
  >>>   param (
  >>>     [int]$firstNumber,
  >>>     [int]$secondNumber
  >>>   )
  >>>   $firstNumber + $secondNumber
  >>> }

  # If you want to loop over an input parameter from the pipeline,
  # you can use ValueFromPipeline=$true and the process block.
  #Write a script to interact with a database server to automate the database administrator (DBA) tasks

  >>> function New-Website() {
  >>>   [CmdletBinding()]
  >>>   param (
  >>>     [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
  >>>     [Alias('name')]
  >>>     [string]$siteName
  >>>     [ValidateSet(3000,5000,8000)], # valid inputs for $siteName
  >>>     [int]$port = 3000
  >>>   )
  >>>   begin { Write-Output 'Creating new website(s)' }
  >>>   process { Write-Output "name: $siteName, port: $port" }
  >>>   end { Write-Output "Website(s) created" }
  >>> }

  # Instead of validating on a set, you can validate using a script
  # with something like this!
  # ...
  # param (
  #   [Parameter()]
  #   [ValidateScript({ Test-Path -Path $_ })]
  #   [String]$whatever
  # )
  # ...

  # If you want to get an attirbute of an input object from the pipeline,
  # define a parameter for it
  # param (
  #   [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
  #   [int]$Version
  # )

  >>> "superAwesomeWebsiteName" | New-Website -port 5000
  Creating new website(s)
  name: superAwesomeWebsiteName, port: 5000
  Website(s) created

  >>> "superAwesomeWebsiteName" | New-Website -port 1000
  New-Website: Cannot validate argument on parameter 'port'. The argument "1000" does not belong to th e set "3000,5000,8000" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again.

  ∾> function Switch-Item {
   ⋮   param ([Switch]$on)
   ⋮   if ($on) { "Switch on" } else { "Switch off" }
   ⋮ }
  ∾
  ∾> Switch-Item -on
  Switch on
  ∾  Switch-Item
  Switch off
  ∾> Switch-Item -on:$false
  Switch off
  ∾  Switch-Item -on:$true
  Switch on

  ∾  function Get-MyCommand { Get-Command @Args }
  ∾  Get-MyCommand -Name Get-ChildItem
  CommandType     Name                                               Version    Source
  -----------     ----                                               -------    ------
  Cmdlet          Get-ChildItem                                      7.0.0.0    Microsoft.PowerShell…

  >>> function Get-PipelineBeginEnd {
    begin   { "Begin: The input is $input" }
    end     { "End:   The input is $input" }
  }

  >>> 1,2,4 | Get-PipelineBeginEnd
  Begin: The input is
  End:   The input is 1 2 4

Ok, check this out, you can define line filtering functions using special syntax.
::

  # syntax
  filter [<scope:>]<name> {<statment_list>}


  ∾  filter Get-ErrorLog ([Switch]$Message) {
   ⋮   if ($Message) { Out-Host -InputObject $_.Message } else { $_ }
   ⋮ }

  ∾  Get-WinEvent -LogName System -MaxEvents 100 | Get-ErrorLog -Message

You can find and manage functions using the ``Function:`` drive.

::

  # list all functions
  ∾  Get-ChildItem Function:
  CommandType     Name                                               Version    Source
  -----------     ----                                               -------    ------
  Function        Add-Numbers
  ...

  # view the source code of a function
  ∾  (Get-ChildItem Function:help).Definition | select -First 10


Redirection
-----------
Redirection in PowerShell is similar to bash conceptually, but the
streams you can redirect are not file handles, but api objects instead.
The streams are named after syslog priority.

The ``>`` operator overwrites, and ``>>`` appaneds. You use the same syntax to
redirect streams as bash ``n>&n``. If you want to redirect all streams at the
same time, use ``*>``. Since windows doesn't have ``/dev/null`` you can
redirect to the ``$null`` variable to discard input.

::
Write a script to interact with a database server to automate the database administrator (DBA) tasks

  # Related commands: Out-File, Tee-Object

  Redirectable output streams

  PowerShell supports redirection of the following output streams.

    Stream #   Description          Introduced in    Write Cmdlet
    ---------- -------------------- ---------------- -------------------------------
    1          SUCCESS Stream       PowerShell 2.0   Write-Output
    2          ERROR Stream         PowerShell 2.0   Write-Error
    3          WARNING Stream       PowerShell 3.0   Write-Warning
    4          VERBOSE Stream       PowerShell 3.0   Write-Verbose
    5          DEBUG Stream         PowerShell 3.0   Write-Debug
    6          INFORMATION Stream   PowerShell 5.0   Write-Information, Write-Host
    *          All Streams          PowerShell 3.0

  [!IMPORTANT] The SUCCESS and ERROR streams are similar to the stdout and
  stderr streams of other shells. However, stdin isn't connected to the
  PowerShell pipeline for input.

  The PowerShell redirection operators are as follows, where n represents the
  stream number. The SUCCESS stream ( 1 ) is the default if no stream is
  specified.

    Operator   Description                                               Syntax
    ---------- --------------------------------------------------------- --------
    >          Send specified stream to a file.                          n>
    >>         APPEND specified stream to a file.                        n>>
    >&1        _Redirects_ the specified stream to the SUCCESS stream.   n>&1

    &{
       Write-Warning "hello"
       Write-Error "hello"
       Write-Output "hi"
    } 3>&1 2>&1 > C:\Temp\redirection.log

    -   3>&1 redirects the WARNING stream to the SUCCESS stream.
    -   2>&1 redirects the ERROR stream to the SUCCESS stream (which also now
        includes all WARNING stream data)
    -   > redirects the SUCCESS stream (which now contains both WARNING and
        ERROR streams) to a file called C:\temp\redirection.log.

When you redirect to a file with ``>``, ``>>`` or ``out-file`` it has a default
width. To change this setting, set the following variable:

::

  $PSDefaultParameterValues['out-file:width'] = 2000

**It's important to note that PowerShell does not support the redirection of binary
data.** If you redirect byte-stream data PowerShell will treat the data as strings,
which will result in corrupted data. So, what do you do?

First load the binary data with the appropriate command, then use a data serialization
formation like JSON/YAML/ASN.1. After it's serialized, you can pipe it from command to
command.

There must be a better way, right? Like converting it to a powershell object before
streaming instead of serializing/desearlizing at every command.


Debugging
---------
* https://learn.microsoft.com/en-us/powershell/scripting/windows-powershell/ise/how-to-debug-scripts-in-windows-powershell-ise?view=powershell-7.4
* https://devblogs.microsoft.com/scripting/debugging-powershell-script-in-visual-studio-code-part-1/


Modules
-------
* https://learn.microsoft.com/en-us/powershell/scripting/developer/module/how-to-write-a-powershell-script-module?view=powershell-7.4
* https://stephanevg.github.io/powershell/class/module/DATA-How-To-Write-powershell-Modules-with-classes/


How do I lay out a new project
------------------------------
* https://github.com/PoshCode/PowerShellPracticeAndStyle
* https://dev.to/this-is-learning/how-to-write-better-powershell-scripts-architecture-and-best-practices-emh
