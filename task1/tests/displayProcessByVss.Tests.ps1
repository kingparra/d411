Describe "User defined functions" {
  BeforeAll {
    . "$env:PROJ_ROOT/task1/src/prompts.ps1"
  }
  Context "displayProcessesByVss" {
    it "Should be sorted by Vss"{
      $func = displayProcessesByVss -AsObjects |
               Select-Object Id, VirtualMemorySize
      $expected = Get-Process |
                  Sort-Object VirtualMemorySize |
                  Select-Object Id, VirtualMemorySize
      $func.Id | Should -Be $expected.Id
      $func.VirtualMemorySize | Should -Be $expected.VirtualMemorySize
    }
  }
}
