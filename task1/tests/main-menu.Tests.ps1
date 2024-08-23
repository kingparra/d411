Describe "User defined functions" {
  BeforeAll {
    . "$env:PROJ_ROOT/task1/src/prompts.ps1"
  }
  Context "Show-Menu" {
    It "Should display the correct menu" {
      Show-Menu | Should -Match "Administrative tasks.*"
    }
  }
  Context "main" {
    It "Should execute displayAscendingFiles when 2 is pressed" {
      Run-Menu -HideMenu -RunOnce -Answer 2 | Should -Be "displayAscendingFiles"
  }
  }
}
