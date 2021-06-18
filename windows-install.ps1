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
    'discord',
    'docker-desktop',
    'dropbox',
    'firefox /l:en-US',
    'git /NoGuiHereIntegration',
    'googlechrome',
    'nodejs-lts',
    'pgadmin4',
    'spotify',
    'steam-client',
    'vscode'
  )

  foreach ($Program in $ProgramsToInstall) {
    $ProgramName = $Program.split()[0]
    $InstallParams = $Program.split()[1]

    Write-Output "Installing ${ProgramName}"
    choco install $ProgramName --params="${InstallParams}" -y
  }
}

function Add-Vscode-Config {
  $DestinationDir = "$env:APPDATA\Code\User"
  Copy-Item -Path "${PSScriptRoot}\vs-code\.config\Code\User\keybindings.json" -Destination "${DestinationDir}\keybindings.json"
  Copy-Item -Path "${PSScriptRoot}\vs-code\.config\Code\User\settings.json" -Destination "${DestinationDir}\settings.json"
}

# Get the flag passed in to the script.
$Flag = $args[0]

switch ($Flag) {
  "--all" {
    Install-Wsl
    Install-Packages
    Add-Vscode-Config
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
    Add-Vscode-Config
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
