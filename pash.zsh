# ~/.zsh/paths.zsh
# Purpose: define PATH-related helpers and prepend common tool locations.
# Keep non-PATH concerns (plugins, completion, compinit, sourcing other files) out of here.

########################################
# User-local bins
########################################
path_add "$HOME/bin"
path_add "$HOME/.local/bin"
path_add "$HOME/.cargo/bin"
path_add "$HOME/.nodenv/bin"
path_add "$HOME/.npm-global/bin"
path_add "$HOME/go/bin"
path_add "$HOME/zig-out/bin"                # Zig project installs
path_add "$HOME/.venvs/bin"
path_add "$HOME/.nodenv/shims"
# path_add "$HOME/.dotfiles/bin"

########################################
# Homebrew (Apple Silicon) and core CLI dirs
########################################
path_add "/opt/homebrew/bin"
path_add "/opt/homebrew/sbin"                # Homebrew sbin (arm64)

########################################
# Rosetta/x86 Homebrew (optional)
########################################
path_add "/usr/local/bin"
path_add "/usr/local/sbin"

########################################
# Toolchain mirrors
########################################
# LLVM 20 (add if the toolchain dir exists)
[[ -d /opt/homebrew/opt/llvm@20/bin ]] && path_add "/opt/homebrew/opt/llvm@20/bin"
# Go (system-wide install; optional)
path_add "/usr/opt/homebrew/opt/llvm@20/bin"

########################################
# App bundle CLIs
########################################
path_add "/Applications/Ghostty.app/Contents/MacOS"
path_add "/Applications/Firefox Developer Edition.app/Contents/MacOS"
path_add "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"

 # ~/.zsh/paths.zsh (or wherever you manage PATH)
# if [[ -o interactive ]]; then
#  zmodload zsh/zle 2>/dev/null || true
#  if (( $+widgets && $+widgets[zle-keymap-select] )); then
#    # your logic here
#  fi
#fi

########################################
# Misc environment (non-PATH exports belong here if needed)
########################################

# End of PATH setup. Do not source other files or run compinit here.
