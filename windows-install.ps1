# Should not be run directly. Instead use the batch script to launch.

function Show-Help {
  Write-Output 'Possible flags:'
  Write-Output '--all (installs all programs and configs)'
  Write-Output '--wsl (installs WSL)'
  Write-Output '--programs (installs all programs)'
  Write-Output '--vs-code (installs vs-code related configs)'
}

function Install-Wsl {
  wsl --install
}

function Install-Windows-Packages {
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
    Write-Output "Installing ${program}"
    choco install $Program
  }
}
