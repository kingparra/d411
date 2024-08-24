Describe "User defined functions" {
  BeforeAll {
    . "$env:PROJ_ROOT/task1/src/prompts.ps1"
  }
  Context "Show-Menu" {
    It "Should display the correct menu" {
      Show-Menu | Should -Match "Administrative tasks.*"
    }
    It "Should execute displayAscendingFiles when 2 is pressed" {
        Run-Menu -HideMenu -RunOnce -Answer 2 | Should -Be "displayAscendingFiles"
    }

    It "Should execute displayCpuMemUsage when 3 is pressed" {
        Run-Menu -HideMenu -RunOnce -Answer 3 | Should -Be "displayCpuMemUsage"
    }
  }
}
