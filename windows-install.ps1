# Should not be run directly. Instead use the batch script to launch.

function Show-Help {
  Write-Output 'Possible flags:'
  Write-Output '--all (installs all packages and configs)'
  Write-Output '--wsl (installs WSL)'
  Write-Output '--packages (installs all packages)'
  Write-Output '--vs-code (installs vs-code related configs)'
}

function Install-Wsl {
  wsl --install
}

function Install-Packages {
  $IsChocoInstalled = powershell choco -v

  if (-not($IsChocoInstalled)) {
    Write-Output "Chocolatey is not installed, installing now."
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  }

  $ProgramsToInstall = @(
    'git /NoGuiHereIntegration',
    'googlechrome',
    'firefox /l:en-US',
    'vscode',
    'spotify',
    'nodejs-lts',
    'steam-client',
    'pgadmin4'
  )

  foreach ($Program in $ProgramsToInstall) {
    $ProgramName = $Program.split()[0]
    $InstallParams = $Program.split()[1]

    Write-Output "Installing ${ProgramName}"
    choco install $ProgramName -- params="${InstallParams}" -y
  }
}


# Get the flag passed in to the script.
$Flag = $args[0]

switch ($Flag) {
  "--all" {
    Install-Wsl
    Install-Packages
    Break
  }
  "--wsl" {
    Install-Wsl
    Break
  }
  "--packages" {
    Install-Packages
    Break
  }
  "--vs-code" {
    Break
  }
  "--help" {
    Show-Help
    Break
  }
  default {
    Show-Help
  }
}
