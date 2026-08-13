# Dotfiles

A modular, multi-OS, multi-device dotfiles repository for macOS and Ubuntu (Work & Private).

## Architecture

This repository uses a **Modular Layered Architecture** with single-branch Git tracking. Different device configurations are managed via committed profiles and feature modules rather than Git branches.

```
dotfiles/
├── zshrc                      # Core bootstrap script
├── os/                        # OS-specific PATHs and environment variables
│   ├── macos.zsh
│   └── ubuntu.zsh
├── modules/                   # Tool & feature capability modules
│   ├── k8s.zsh
│   ├── python.zsh
│   ├── tmux.zsh
│   └── work.zsh
├── profiles/                  # Git-tracked device profile configurations
│   ├── work-mac-laptop.zsh
│   ├── work-ubuntu-desktop.zsh
│   └── private-mac-laptop.zsh
└── oh-my-zsh-custom/          # Custom themes, plugins, and universal aliases
```

---

## Setting Up a New Device

1. **Clone the repository** (if not already cloned):
   ```bash
   git clone git@github.com:chpeer/dotfiles.git ~/dev/dotfiles
   ```

2. **Link `zshrc`**:
   ```bash
   ln -sf ~/dev/dotfiles/zshrc ~/.zshrc
   ```

3. **Activate a Profile**:
   Bind your device to one of the committed profiles in `profiles/`:

   * **Work Mac Laptop**:
     ```bash
     echo 'source "$DOTFILES/profiles/work-mac-laptop.zsh"' > ~/.dotfiles.profile
     ```

   * **Work Ubuntu Desktop**:
     ```bash
     echo 'source "$DOTFILES/profiles/work-ubuntu-desktop.zsh"' > ~/.dotfiles.profile
     ```

   * **Private Mac Laptop**:
     ```bash
     echo 'source "$DOTFILES/profiles/private-mac-laptop.zsh"' > ~/.dotfiles.profile
     ```

4. **Reload Shell**:
   ```bash
   exec zsh
   ```

---

## How Profiles Work

Profiles define the operating system (`DOTFILES_OS`) and list the modules (`DOTFILES_MODULES`) to load for a specific device:

```zsh
# profiles/work-mac-laptop.zsh
DOTFILES_OS="macos"
DOTFILES_MODULES=(
  work
  k8s
  python
)
```

The bootstrap script `zshrc` resolves profiles in this order:
1. `~/.dotfiles.profile` (local file or symlink)
2. `profiles/$(hostname -s).zsh` (hostname-based auto match)
3. Automatic OS fallback

---

## Adding New Modules or Profiles

* **To add a new feature/tool module**: Create `modules/<module_name>.zsh` and append `<module_name>` to the `DOTFILES_MODULES` array in any target profiles.
* **To add a new profile**: Create `profiles/<profile_name>.zsh` and point `~/.dotfiles.profile` to it.

---

## Local Overrides (Git Ignored)

For non-committed, machine-specific secrets or temporary tweaks, create `~/.zshrc.local`. It is automatically sourced at the end of `zshrc`.