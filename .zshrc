# ~/.zshrc

# Purpose: central interactive shell init. One compinit, clear guards, no recursion.
# Ensure ZLE is available before any widgets/bindkeys
zmodload zsh/zle 2>/dev/null || true

########################################
# Basic environment and editors
########################################
export TERMINAL="Ghostty"                               # Informational for scripts
export TERMINAL_APP="/Applications/Ghostty.app"         # Preferred terminal bundle path
export EDITOR="subl"
export HOMEBREW_BUNDLE_FILE="$HOME/.BANDIDO/homebrew/Brewfile"
export BROWSER="/Applications/Firefox Developer Edition.app/Contents/MacOS/firefox"  # Preferred browser for CLI tools
typeset -g TMUX="${TMUX-}"

########################################
# CLI completion — fpath first, then single compinit
########################################

typeset -U fpath
# Make Ghostty’s zsh functions discoverable BEFORE compinit

# App/packaged completions (Brew, Ghostty, etc.)
[[ -d /Applications/Ghostty.app/Contents/Resources/zsh/site-functions ]] && fpath+=("/Applications/Ghostty.app/Contents/Resources/zsh/site-functions")
[[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath+=("/opt/homebrew/share/zsh/site-functions")

# --- everything else can be after compinit ---

# Load completion system once
autoload -Uz compinit[[ -d "$HOME/.zsh" ]] && fpath+=("$HOME/.zsh")  # custom completions
compinit -u           # remove -u later if you prefer strict security checks


########################################
# Homebrew bootstrap (only if not already on PATH)
########################################
if ! command -v brew >/dev/null 2>&1; then
  [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
fi

########################################
# Clean $PATH
########################################
# Deduplicate PATH by using the zsh array 'path' as unique (-U)
typeset -U path

# Pull in PATH-only setup (no plugins, no compinit) — your cleaned version
[[ -f "$HOME/.zsh/paths.zsh" ]] && source "$HOME/.zsh/paths.zsh"  

########################################
# FZF init (classic location) — source once, guarded
########################################
if [[ -o interactive && -r "$HOME/.fzf.zsh" && -z ${FZF_INIT_LOADED-} ]]; then
  source "$HOME/.fzf.zsh"
  FZF_INIT_LOADED=1
fi
# Optional fallback: load Homebrew’s fzf scripts if ~/.fzf.zsh wasn’t sourced
if [[ -o interactive && -z ${FZF_INIT_LOADED-} ]]; then
  [[ -r /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  [[ -r /opt/homebrew/opt/fzf/shell/completion.zsh   ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh
  FZF_INIT_LOADED=1
fi

########################################
# Ghostty shell integration
########################################
if [[ -f "/Applications/Ghostty.app/Contents/Resources/ghostty/shell-integration/zsh/ghostty-integration" ]]; then
  source "/Applications/Ghostty.app/Contents/Resources/ghostty/shell-integration/zsh/ghostty-integration"
fi
# Optional external resources dir
if [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]]; then
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi
# Ghostty icons helper (if you use it)
[ -f "$HOME/.local/bin/ghostty_icons.sh" ] && source "$HOME/.local/bin/ghostty_icons.sh"

########################################
# Ghostty Config Toggle (fzf picker)
########################################
ghostty_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
ghostty_cfg="$ghostty_dir/config"
gc() {
  local choice base
  command -v fd  >/dev/null 2>&1 || { echo "fd not found"; return 1; }
  command -v fzf >/dev/null 2>&1 || { echo "fzf not found"; return 1; }
  [[ -r "$ghostty_cfg" ]] || { echo "Ghostty config not found: $ghostty_cfg"; return 1; }

  choice="$(
    fd --type f --exclude 'config' --base-directory "$ghostty_dir" \
    | fzf --prompt='Ghostty config > ' \
          --preview "cat \"$ghostty_dir/{}\"" \
          --delimiter='/'
  )" || return

  [[ -n "$choice" ]] || return
  base="${choice##*/}"

  # Replace the first matching 'config-file =' line with the selected basename
  sed -i '' -E "s#^(config-file = )[[:graph:]]+#\1${base}#" "$ghostty_cfg"

  # Nudge Ghostty’s preferences UI to reload
  osascript -so -e 'tell application "Ghostty" to activate' \
                -e 'tell application "System Events" to keystroke "," using {command down, shift down}'

  export GHOST_ENV="$base"
}

########################################
# z-Plugins — load with guards
########################################
# zsh-autosuggestions (Homebrew)
if [[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
fi

# zsh-history-substring-search
if [[ -r /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
  source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
  bindkey '^P' history-substring-search-up
  bindkey '^N' history-substring-search-down
  if [[ -n ${terminfo[kcuu1]} && -n ${terminfo[kcud1]} ]]; then
    bindkey -M emacs "${terminfo[kcuu1]}" history-substring-search-up
    bindkey -M emacs "${terminfo[kcud1]}" history-substring-search-down
    bindkey -M viins "${terminfo[kcuu1]}" history-substring-search-up
    bindkey -M viins "${terminfo[kcud1]}" history-substring-search-down
  fi
fi

# Starship prompt (optional)
if [[ -o interactive ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# The Fuck (optional)
if command -v thefuck >/dev/null 2>&1; then
  eval "$(thefuck --alias)"
fi

########################################
# Modular, non-init configs (styles/env/aliases)
########################################
# Completion zstyles
[[ -f "$HOME/.zsh/completion.zsh" ]] && source "$HOME/.zsh/completion.zsh"
# Extra env and variables 
[[ -f "$HOME/.zsh/env.zsh"  ]] && source "$HOME/.zsh/env.zsh"
# Aliases
[[ -f "$HOME/.zsh/aliases" ]] && source "$HOME/.zsh/aliases"


alias reload='exec zsh'

########################################
# zsh-syntax-highlighting (must be last)
########################################
if [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi



# End of PATH setup. Do not source other files or run compinit here.