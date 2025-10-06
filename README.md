# ansible-role-dotmodules

A modular Ansible role for managing dotfiles and macOS configuration. This role provides a flexible system for organizing dotfiles into modules, with support for both traditional GNU Stow deployment and intelligent file merging for shared configuration files.

## Features

- **Modular Dotfile Management**: Organize dotfiles into logical modules (shell, git, dev-tools, etc.)
- **GNU Stow Integration**: Leverages GNU Stow for clean symlink-based dotfile deployment
- **File Merging Support**: Intelligent merging of shared configuration files (e.g., `.zshrc`, `.bashrc`)
- **Conflict Resolution**: Automatic detection and resolution of file strategy conflicts
- **Homebrew Integration**: Seamless package management via `geerlingguy.mac.homebrew`
- **Mac App Store Integration**: App installation via `geerlingguy.mac.mas`
- **Ansible Best Practices**: Follows Ansible conventions and uses recommended modules

## File Merging Strategy

When multiple modules need to contribute to the same file (e.g., `.zshrc`), the role uses an intelligent merging strategy:

```yaml
# Module A (shell-zsh/config.yml)
mergeable_files:
  - ".zshrc"

# Module B (dev-tools-zsh/config.yml)  
mergeable_files:
  - ".zshrc"
```

**Result**: A merged `.zshrc` file with clear attribution:
```bash
# =============================================================================
# SHELL-ZSH MODULE CONTRIBUTION
# =============================================================================
eval "$(starship init zsh)"
setopt AUTO_CD

# =============================================================================
# DEV-TOOLS-ZSH MODULE CONTRIBUTION
# =============================================================================
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
alias grep='grep --color=auto'
```

**Conflict Resolution**: The role automatically detects conflicts between merge and stow strategies, providing clear error messages with resolution options.

## Requirements

- **Operating System:** macOS
- **Ansible:** Version 2.9 or higher is recommended.
- **Homebrew:** Must be installed on the target machine.
- **Dependencies:** This role depends on the [geerlingguy.mac.homebrew](https://galaxy.ansible.com/geerlingguy/mac/homebrew) role, which will be invoked to manage Homebrew packages.

## Role Variables

The following variables can be set to customize the behavior of this role:

### Core Configuration

- **`dotmodules.repo`**
  URL or path to the dotmodules repository.
  *Default:* `"https://github.com/getfatday/dotmodules.git"`

- **`dotmodules.dest`**
  Destination directory for the cloned repository.
  *Default:* `"{{ ansible_env.HOME }}/.dotmodules"`

- **`dotmodules.install`**
  List of modules to install and configure.
  *Default:* `[]`

### Module Configuration

Each module can specify the following variables in its `config.yml`:

- **`homebrew_packages`**: List of Homebrew packages to install
- **`homebrew_taps`**: List of Homebrew taps to add
- **`mas_installed_apps`**: List of Mac App Store apps to install
- **`stow_dirs`**: List of directories to deploy via GNU Stow
- **`mergeable_files`**: List of files to merge with other modules

### Example Module Configuration

```yaml
# modules/shell-zsh/config.yml
homebrew_packages:
  - zsh
  - starship
  - fzf

mergeable_files:
  - ".zshrc"
  - ".bashrc"

stow_dirs:
  - shell-zsh
```

---

## Dependencies

This role depends on:

- **geerlingguy.mac.homebrew**
  Ensure that this role is installed or available via Ansible Galaxy. It is automatically invoked within the dotmodules tasks to manage Homebrew packages.

---

## Example Playbook

Below is an example playbook that demonstrates how to use this role:

```yaml
---
- name: Deploy dotfiles with ansible-role-dotmodules
  hosts: localhost
  vars:
    dotmodules:
      repo: "https://github.com/your-org/dotfiles.git"
      dest: "{{ ansible_env.HOME }}/.dotmodules"
      install:
        - shell-zsh      # Shell configuration with merging
        - dev-tools-zsh  # Development tools with merging
        - git           # Git configuration (stow only)
        - editor        # Editor configuration (stow only)
  roles:
    - ansible-role-dotmodules
```

## Module Structure

Create modules in your dotfiles repository with the following structure:

```
dotfiles/
├── modules/
│   ├── shell-zsh/
│   │   ├── config.yml
│   │   └── files/
│   │       └── .zshrc
│   ├── dev-tools-zsh/
│   │   ├── config.yml
│   │   └── files/
│   │       └── .zshrc
│   └── git/
│       ├── config.yml
│       └── files/
│           └── .gitconfig
```

## Testing

The role includes comprehensive tests:

```bash
# Test file merging functionality
ansible-playbook tests/test-merge.yml

# Test conflict detection
ansible-playbook tests/test-conflict.yml

# Test with dependencies
ansible-playbook tests/test-with-deps.yml
```
