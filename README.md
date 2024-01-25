# Macos-terminal
Design Mac Os Terminal with Fish Shell

# Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
# Install Fish
```bash
brew install fish
curl -L https://get.oh-my.fish | fish
brew tap homebrew/cask-fonts
brew  install --cask font-fira-code-nerd-font
set -U theme_nerd_fonts yes
```

Change Font to fira-code-nerd in terminal

# Update Shell

Add the following in ~/.zshrc to retain all path variables

```bash
#Make Sure these should be last line
fish
```

# Setup

## Theme
```bash
omf install bobthefish
```

## Autocomplete
To collect command completions for all command

```bash
fish_update_completions
```
tyuy

## Configure Web
You can configure your shell by launching the web interface, run:
```bash
fish_config
```

