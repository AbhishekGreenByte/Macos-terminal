# Macos-terminal
## METHOD 1: ZSH Shell OH-MY-ZSH

### Install OH-MY-ZSH
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Install Fonts
https://github.com/powerline/fonts


### Themes 
https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
```bash
vi ~/.zshrc
ZSH_THEME="agnoster"
```

### Install PLUGIN
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source ~/.zshrc
```

### Customize Agnoster Theme
```
cd ~/.oh-my-zsh/themes/
```

Dark Theme 
Blue -> Magenta



## METHOD 2 : FISH Shell
Design Mac Os Terminal with Fish Shell

### Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
### Install Fish
```bash
brew install fish
curl -L https://get.oh-my.fish | fish
brew tap homebrew/cask-fonts
brew  install --cask font-fira-code-nerd-font
set -U theme_nerd_fonts yes
```

Change Font to fira-code-nerd in terminal

### Update Shell

Add the following in ~/.zshrc to retain all path variables

```bash
#Make Sure these should be last line
fish
```

### Setup

## Theme
```bash
omf install bobthefish
```

### Autocomplete
To collect command completions for all command

```bash
fish_update_completions
```

### Configure Web
You can configure your shell by launching the web interface, run:
```bash
fish_config
```

