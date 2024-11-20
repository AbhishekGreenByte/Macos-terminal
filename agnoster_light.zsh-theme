# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts).
# Make sure you have a recent version: the code points that Powerline
# uses changed in 2012, and older versions will display incorrectly,
# in confusing ways.
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on macOS, [iTerm 2](https://iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# If using with "light" variant of the Solarized color scheme, set
# SOLARIZED_THEME variable to "light". If you don't specify, we'll assume
# you're using the "dark" variant.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
CURRENT_BG='NONE'

# Define your preferred colors here
local COLOR_BLACK="0"
local COLOR_RED="1"
local COLOR_GREEN="2"
local COLOR_YELLOW="3"
local COLOR_BLUE="4"
local COLOR_MAGENTA="5"
local COLOR_CYAN="6"
local COLOR_WHITE="7"
local COLOR_LIGHT_GRAY="250"
local COLOR_DARK_GRAY="238"

local BOLD_COLOR="bold"
local RESET_COLOR="%f%b%k"

# Set the foreground and background colors
case ${SOLARIZED_THEME:-light} in
    light) CURRENT_FG=$COLOR_BLACK;;
    *)     CURRENT_FG=$COLOR_WHITE;;
esac

# Special Powerline characters
() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  SEGMENT_SEPARATOR=$'\ue0b0'
}

# Begin a segment
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment $COLOR_LIGHT_GRAY $COLOR_BLACK "%(!.%{%F{red}%}.)%n@%m"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path

   if [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    repo_path=$(command git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref="◈ $(command git describe --exact-match --tags HEAD 2> /dev/null)" || \
    ref="➦ $(command git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment $COLOR_YELLOW $COLOR_BLACK
    else
      prompt_segment $COLOR_GREEN $CURRENT_FG
    fi

    local ahead behind
    ahead=$(command git log --oneline @{upstream}.. 2>/dev/null)
    behind=$(command git log --oneline ..@{upstream} 2>/dev/null)
    if [[ -n "$ahead" ]] && [[ -n "$behind" ]]; then
      PL_BRANCH_CHAR=$'\u21c5'
    elif [[ -n "$ahead" ]]; then
      PL_BRANCH_CHAR=$'\u21b1'
    elif [[ -n "$behind" ]]; then
      PL_BRANCH_CHAR=$'\u21b0'
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '±'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n "${${ref:gs/%/%%}/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
  fi
}

prompt_bzr() {
  (( $+commands[bzr] )) || return

  # Test if bzr repository in directory hierarchy
  local dir="$PWD"
  while [[ ! -d "$dir/.bzr" ]]; do
    [[ "$dir" = "/" ]] && return
    dir="${dir:h}"
  done

  local bzr_status status_mod status_all revision
  if bzr_status=$(command bzr status 2>&1); then
    status_mod=$(echo -n "$bzr_status" | head -n1 | grep "modified" | wc -m)
    status_all=$(echo -n "$bzr_status" | head -n1 | wc -m)
    revision=${$(command bzr log -r-1 --log-format line | cut -d: -f1):gs/%/%%}
    if [[ $status_mod -gt 0 ]] ; then
      prompt_segment $COLOR_YELLOW $COLOR_BLACK "bzr@$revision ✚"
    else
      if [[ $status_all -gt 0 ]] ; then
        prompt_segment $COLOR_YELLOW $COLOR_BLACK "bzr@$revision"
      else
        prompt_segment $COLOR_GREEN $COLOR_BLACK "bzr@$revision"
      fi
    fi
  fi
}

prompt_hg() {
  (( $+commands[hg] )) || return
  local rev st branch
  if $(command hg id >/dev/null 2>&1); then
    if $(command hg prompt >/dev/null 2>&1); then
      if [[ $(command hg prompt "{status|unknown}") = "?" ]]; then
        # if files are not added
        prompt_segment $COLOR_RED $COLOR_WHITE
        st='±'
      elif [[ -n $(command hg prompt "{status|modified}") ]]; then
        # if any modification
        prompt_segment $COLOR_YELLOW $COLOR_BLACK
        st='±'
      else
        # if working copy is clean
        prompt_segment $COLOR_GREEN $CURRENT_FG
      fi
      echo -n ${$(command hg prompt "☿ {rev}@{branch}"):gs/%/%%} $st
    else
      st=""
      rev=$(command hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(command hg id -b 2>/dev/null)
      if command hg st | command grep -q "^\?"; then
        prompt_segment $COLOR_RED $COLOR_WHITE
        st='±'
      elif command hg st | command grep -q "^[MA]"; then
        prompt_segment $COLOR_YELLOW $COLOR_BLACK
        st='±'
      else
        prompt_segment $COLOR_GREEN $CURRENT_FG
      fi
      echo -n "☿ ${rev}@${branch} $st"
    fi
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment $COLOR_BLUE $COLOR_WHITE '%~'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘%{$reset_color%}$RETVAL"
  [[ $UID -eq 0 ]] && symbols+="%{$fg[yellow]%}⚡"
  [[ -n "$(jobs)" ]] && symbols+="%{$fg_bold[cyan]%}⚙"
  [[ -n "$symbols" ]] && prompt_segment $COLOR_WHITE $COLOR_LIGHT_GRAY "$symbols"
}

# Virtualenv: current python virtualenv
prompt_virtualenv() {
  [[ -n "$VIRTUAL_ENV" ]] || return
  prompt_segment $COLOR_BLUE $COLOR_WHITE "(`basename $VIRTUAL_ENV`)"
}

# Python Environment: display current pyenv settings
prompt_pyenv() {
  [[ -n "$PYENV_VERSION" ]] || return
  prompt_segment $COLOR_BLUE $COLOR_WHITE "$PYENV_VERSION"
}

# Time: current time
prompt_time() {
  prompt_segment $COLOR_MAGENTA $COLOR_WHITE "%*"
}

build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_context
  prompt_virtualenv
  prompt_pyenv
  prompt_dir
  prompt_git
  prompt_hg
  prompt_bzr
  prompt_end
}

# Actual prompt
PROMPT='%{%f%b%k%}$(build_prompt) '
ZSH_THEME_GIT_PROMPT_DIRTY="*"
ZSH_THEME_GIT_PROMPT_CLEAN=""