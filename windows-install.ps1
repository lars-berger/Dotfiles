# Should not be run directly. Instead use the batch script to launch.

function Show-Help {
  Write-Output 'Possible flags:'
  Write-Output '--all (installs all packages and configs)'
  Write-Output '--wsl (installs WSL and configs)'
  Write-Output '--wsl-configs (installs WSL configs)'
  Write-Output '--packages (installs all packages)'
  Write-Output '--vs-code (installs vs-code related configs)'
}

function Install-Wsl {
  $IsWslInstalled = wsl -l -v

  if (-not($IsWslInstalled)) {
    wsl --install
  }
}

function Install-Packages {
  $IsChocoInstalled = powershell choco -v

  if (-not($IsChocoInstalled)) {
    Write-Output "Chocolatey is not installed, installing now."
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  }

  $ProgramsToInstall = @(
    'autohotkey',
    'awscli',
    'discord',
    'docker-desktop',
    'dropbox',
    'figma',
    'firefox /l:en-US',
    'f.lux',
    'git /NoGuiHereIntegration',
    'googlechrome',
    # neovim --pre should probably be used instead until 0.5 goes out of beta.
    'neovim',
    'nodejs-lts',
    'obsidian',
    'paint.net',
    'pgadmin4',
    'postman',
    'slack',
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

function Install-Wsl-Ubuntu-Packages {
  # Add repository so that NeoVim 0.5 can be installed.
  wsl sudo add-apt-repository -y ppa:neovim-ppa/unstable

  wsl sudo apt -y update

  # Install languages, runtimes, etc.
  wsl sudo apt -y install nodejs npm python3-pip

  # Install some programs that are nice to have.
  wsl sudo apt -y install ripgrep fzf ranger neovim

  # Install misc dependencies.
  wsl sudo apt -y install libjpeg8-dev zlib1g-dev python-dev python3-dev libxtst-dev

  wsl pip3 install pynvim --user
  wsl pip3 install ueberzug neovim-remote

  wsl git clone https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

  wsl sudo npm install -g tree-sitter-cli --unsafe-perm=true --allow-root
  wsl sudo npm i -g neovim

  # Symlink win32yank so that it can be found by Neovim on WSL.
  # Described further here: https://github.com/neovim/neovim/wiki/FAQ#how-to-use-the-windows-clipboard-from-wsl
  wsl sudo ln -s "/mnt/c/tools/neovim/Neovim/win32yank.exe" "/usr/local/bin/win32yank.exe"
}

function Add-Wsl-Configs {
  Write-Output "Adding config files to WSL."

  $DestinationDir = "${PSScriptRoot}\nvim\.config\nvim".Replace("\", "/")
  $FormattedDir = wsl wslpath -u $DestinationDir
  Write-Output "Copying nvim config from ${FormattedDir}."

  # Copy nvim config to appropriate directory in WSL.
  wsl rm -rf ~/.config/nvim
  wsl cp -r $FormattedDir ~/.config/nvim

  wsl nvim -u ~/.config/nvim/init.lua +PackerInstall
}

# Get the flag passed in to the script.
$Flag = $args[0]

switch ($Flag) {
  "--all" {
    Install-Wsl
    Install-Packages
    Add-Vscode-Config
    Add-Wsl-Configs
    Break
  }
  "--wsl" {
    Install-Wsl
    Install-Wsl-Ubuntu-Packages
    Add-Wsl-Configs
    Break
  }
  "--wsl-configs" {
    Add-Wsl-Configs
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
