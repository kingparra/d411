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
    It "Should execute appendLogFileNames when 1 is pressed" {
        Run-Menu -HideMenu -RunOnce -Answer 1 | Should -Be "appendLogFileNames"
    }

    It "Should execute displayAscendingFiles when 2 is pressed" {
        Run-Menu -HideMenu -RunOnce -Answer 2 | Should -Be "displayAscendingFiles"
    }

    It "Should execute displayCpuMemUsage when 3 is pressed" {
        Run-Menu -HideMenu -RunOnce -Answer 3 | Should -Be "displayCpuMemUsage"
    }

    It "Should execute displayProcessesByVss when 4 is pressed" {
        Run-Menu -HideMenu -RunOnce -Answer 4 | Should -Be "displayProcessesByVss"
    }

    It "Should exit when 5 is pressed" {
        # Mock the exit command to prevent the script from terminating
        Mock -CommandName exit -MockWith {}

        # Run the menu and pass "5" as the answer
        Run-Menu -HideMenu -RunOnce -Answer 5

        # Verify that the exit function was called
        Assert-MockCalled -CommandName exit -Exactly 1 -Scope It
    }
}

}
