# ansible-role-dotmodules

A modular Ansible role for managing dotfiles and macOS configuration. This role provides a flexible system for organizing dotfiles into modules, with support for both traditional GNU Stow deployment and intelligent file merging for shared configuration files.

## Features

- **Modular Dotfile Management**: Organize dotfiles into logical modules (shell, git, dev-tools, etc.)
- **GNU Stow Integration**: Leverages GNU Stow for clean symlink-based dotfile deployment
- **File Merging Support**: Intelligent merging of shared configuration files (e.g., `.zshrc`, `.bashrc`)
- **Optional Shell Registration**: Automatic registration of shells in `/etc/shells` with runtime skip support via Ansible tags
- **Conflict Resolution**: Automatic detection and resolution of file strategy conflicts
- **Homebrew Integration**: Seamless package management via `community.general` modules
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

### Nested Directory Support

The role now supports mergeable files in nested directories, enabling better organization of configuration files:

```yaml
# Module configuration with nested paths
mergeable_files:
  - ".zshrc"                              # Root-level (as before)
  - ".zsh/aliases.sh"                     # Single-level nesting (NEW)
  - ".config/fish/conf.d/custom.fish"     # Multi-level nesting (NEW)
```

**Directory Structure**: Parent directories are automatically created, and files are symlinked individually using GNU Stow's `--no-folding` option, allowing merged and stowed files to coexist in the same directory.

**Example**:
```
~/
├── .zshrc                              # Merged root-level file
├── .zsh/
│   └── aliases.sh                      # Merged nested file
└── .config/
    └── fish/
        └── conf.d/
            └── custom.fish             # Merged deeply nested file
```

## Optional Shell Registration

Modules can declare a shell to be automatically registered in `/etc/shells` using the `register_shell` configuration option.

### Default Behavior

By default, when a module declares `register_shell`, the shell is automatically registered in `/etc/shells`:

```yaml
# modules/fish/config.yml
homebrew_packages:
  - fish

register_shell: fish  # Automatically registers /opt/homebrew/bin/fish or /usr/local/bin/fish
```

### Skipping Shell Registration

If you don't want shell registration, simply omit the `register_shell` field from your module's config:

```yaml
# modules/fish/config.yml
homebrew_packages:
  - fish
# No register_shell field - no registration will occur
```

For runtime control (e.g., CI/CD, testing), use Ansible tags:

```bash
ansible-playbook deploy.yml --skip-tags register_shell
```

### Error Handling

If shell registration fails (e.g., insufficient privileges), the deployment will fail with a helpful error message:

```
Failed to register /opt/homebrew/bin/fish in /etc/shells.

This is usually caused by:
- Insufficient sudo privileges
- System policies preventing /etc/shells modification

To skip shell registration:
- Remove 'register_shell' from your module's config.yml, or
- Run with --skip-tags register_shell
```

### Architecture Support

Shell path resolution automatically detects the system architecture:
- **Apple Silicon (M1/M2/M3)**: `/opt/homebrew/bin/{shell}`
- **Intel Mac**: `/usr/local/bin/{shell}`

Absolute paths (e.g., `/bin/bash`) are used as-is without modification.

### Use Cases

**Enable shell registration** (default):
```yaml
homebrew_packages:
  - fish
register_shell: fish  # Enables registration
```

**Skip shell registration permanently**:
```yaml
homebrew_packages:
  - fish
# Omit register_shell field - no registration tasks will run
```

**Skip shell registration at runtime** (CI/CD, testing):
```bash
ansible-playbook deploy.yml --skip-tags register_shell
```

### Runtime Control

Skip shell registration for a single deployment run without modifying configuration files using Ansible tags:

```bash
ansible-playbook deploy.yml --skip-tags register_shell
```

This is useful for:
- **CI/CD pipelines**: No sudo access available
- **Testing deployments**: Don't want to modify system files
- **Ad-hoc deployments**: Quick deployments where shell registration isn't needed

**Example: CI/CD Deployment**

```yaml
# .github/workflows/test.yml
- name: Deploy dotfiles (skip shell registration)
  run: ansible-playbook deploy.yml --skip-tags register_shell
  # No sudo required when using --skip-tags register_shell
```

**Checking available tags**:

```bash
# See which tags are available
ansible-playbook deploy.yml --list-tags

# Dry run to see what would be skipped
ansible-playbook deploy.yml --skip-tags register_shell --check
```

### Troubleshooting Shell Registration

**Problem: Shell not registered when expected**

Possible causes:
- You used `--skip-tags register_shell` (check your command)
- Module doesn't have `register_shell` field (check config.yml)

Solution:
```bash
# Verify command doesn't have --skip-tags
ansible-playbook deploy.yml

# Check module config
cat ~/.dotmodules/<module-name>/config.yml | grep register_shell
```

**Problem: Sudo prompt still appears with --skip-tags**

Possible causes:
- Typo in tag name (must be exactly `register_shell`, case-sensitive)
- Other tasks require sudo (not shell registration)

Solution:
```bash
# Verify exact tag name
ansible-playbook deploy.yml --skip-tags register_shell

# Check which tasks require sudo
ansible-playbook deploy.yml --list-tasks -vv | grep become
```

## Requirements

- **Operating System:** macOS
- **Ansible:** Version 2.9 or higher is recommended.
- **Homebrew:** Must be installed on the target machine (typically installed by the [ansible-control-bootstrap](https://github.com/getfatday/ansible-control-bootstrap) script before this role runs).
- **Dependencies:** This role requires the `community.general` Ansible collection, which provides the Homebrew modules (`homebrew`, `homebrew_cask`, `homebrew_tap`) used to manage Homebrew packages.

## Role Variables

The following variables can be set to customize the behavior of this role:

### Core Configuration

- **`dotmodules.repo`**
  URL or path to the dotmodules repository.
  *Default:* `"https://github.com/craveytrain/dotmodules.git"`

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
- **`register_shell`**: Optional shell to register in `/etc/shells` (shell name or absolute path)

### Example Module Configuration

```yaml
# modules/shell-zsh/config.yml
homebrew_packages:
  - zsh
  - starship
  - fzf

register_shell: zsh             # Registers /opt/homebrew/bin/zsh or /usr/local/bin/zsh

mergeable_files:
  - ".zshrc"                    # Root-level file
  - ".zsh/aliases.sh"           # Nested file
  - ".bashrc"

stow_dirs:
  - shell-zsh
```

---

## Dependencies

This role depends on:

- **community.general** collection
  Provides the Homebrew modules (`homebrew`, `homebrew_cask`, `homebrew_tap`) used to manage Homebrew packages, taps, and casks. Install via `ansible-galaxy collection install community.general`.

- **geerlingguy.mac** collection (optional)
  Only required if using Mac App Store (MAS) functionality. Provides the `geerlingguy.mac.mas` role for installing Mac App Store applications.

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

## Shell Registration

Modules can declare shells that should be automatically registered in `/etc/shells`:

```yaml
# modules/shell-fish/config.yml
homebrew_packages:
  - fish

register_shell: fish  # Auto-detects Homebrew path based on architecture
```

**Architecture Detection:**
- **Apple Silicon (M1/M2/M3)**: `/opt/homebrew/bin/fish`
- **Intel Mac**: `/usr/local/bin/fish`

**Absolute Paths:** You can also specify an absolute path:
```yaml
register_shell: /custom/path/to/shell
```

**Edge Cases:**
- Missing `register_shell` field: Shell registration skipped (no error)
- Empty `register_shell` value: Shell registration skipped (no error)
- Multiple modules with same shell: Idempotent (no duplicates)
- Shell binary doesn't exist: Registration proceeds anyway (mirrors macOS behavior)
- Missing sudo privileges: Task fails with clear error message

**Idempotency:** Running the role multiple times will not create duplicate entries in `/etc/shells`.

## Testing

The role includes comprehensive tests:

```bash
# Test file merging functionality
ansible-playbook tests/test-merge.yml

# Test conflict detection
ansible-playbook tests/test-conflict.yml

# Test with dependencies
ansible-playbook tests/test-with-deps.yml

# Test shell registration
ansible-playbook tests/test-shell-registration.yml
```
