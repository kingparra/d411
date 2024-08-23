#!/usr/bin/env pwsh
Import-Module Pester

# Run the pester test on the root of this project directory, task1
# $env:PROJ_ROOT is set by ./task1/.envrc
# Install and set up direnv to use it https://direnv.net/
Invoke-Pester $env:PROJ_ROOT/task1/tests/
