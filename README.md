# ansible-role-dotmodules

A modular Ansible role for managing dotfiles and macOS configuration. This role provides a flexible system for organizing dotfiles into modules, deploying them via GNU Stow with `--no-folding` for clean symlink management.

## Features

- **Modular Dotfile Management**: Organize dotfiles into logical modules (shell, git, dev-tools, etc.)
- **GNU Stow Integration**: Leverages GNU Stow with `--no-folding` for individual file symlinks
- **Optional Shell Registration**: Automatic registration of shells in `/etc/shells` with runtime skip support via Ansible tags
- **Homebrew Integration**: Seamless package management via `community.general` modules
- **Mac App Store Integration**: App installation via `geerlingguy.mac.mas`
- **Ansible Best Practices**: Follows Ansible conventions and uses recommended modules

## How It Works

Each module contains a `config.yml` declaring its packages and a `files/` directory with dotfiles to deploy. The role processes all modules, aggregates their package lists, and deploys files via GNU Stow with `--no-folding` so each file gets its own symlink.

When multiple modules need to contribute to the same config file (e.g., `.zshrc`), use the **conf.d pattern**: each module drops a numbered fragment into a directory like `.zsh/conf.d/`, and a loader sources them in order.

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

### Architecture Support

Shell path resolution automatically detects the system architecture:
- **Apple Silicon (M1/M2/M3)**: `/opt/homebrew/bin/{shell}`
- **Intel Mac**: `/usr/local/bin/{shell}`

Absolute paths (e.g., `/bin/bash`) are used as-is without modification.

### Runtime Control

Skip shell registration for a single deployment run without modifying configuration files using Ansible tags:

```bash
ansible-playbook deploy.yml --skip-tags register_shell
```

This is useful for:
- **CI/CD pipelines**: No sudo access available
- **Testing deployments**: Don't want to modify system files
- **Ad-hoc deployments**: Quick deployments where shell registration isn't needed

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
- **`register_shell`**: Optional shell to register in `/etc/shells` (shell name or absolute path)

### Example Module Configuration

```yaml
# modules/shell/config.yml
homebrew_packages:
  - zsh
  - starship
  - fzf

register_shell: zsh

stow_dirs:
  - shell
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
        - shell
        - git
        - dev-tools
        - editor
  roles:
    - ansible-role-dotmodules
```

## Module Structure

Create modules in your dotfiles repository with the following structure:

```
dotfiles/
├── modules/
│   ├── shell/
│   │   ├── config.yml
│   │   └── files/
│   │       ├── .zsh/
│   │       │   └── conf.d/
│   │       │       ├── 00-shell-options.zsh
│   │       │       └── 50-prompt.zsh
│   │       └── .zshrc          # Sources conf.d fragments
│   ├── dev-tools/
│   │   ├── config.yml
│   │   └── files/
│   │       └── .zsh/
│   │           └── conf.d/
│   │               └── 50-dev-aliases.zsh
│   └── git/
│       ├── config.yml
│       └── files/
│           └── .gitconfig
```

## Testing

The role includes tests for core functionality:

```bash
# Test basic module deployment
ansible-playbook tests/test.yml

# Test with dependencies
ansible-playbook tests/test-with-deps.yml

# Test shell registration
ansible-playbook tests/test-shell-registration.yml
```
