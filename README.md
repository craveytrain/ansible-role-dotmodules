# ansible-role-dotmodules

**WARNING: This role is highly experimental and currently untested. Use at your own risk!**

Provides common capabilities for dotfile management and macOS configuration. This role leverages the [geerlingguy.mac.homebrew](https://galaxy.ansible.com/geerlingguy/mac/homebrew) role to install and manage Homebrew packages, and includes tasks for deploying dotfiles and applying OS X defaults.

## Requirements

- **Operating System:** macOS
- **Ansible:** Version 2.9 or higher is recommended.
- **Homebrew:** Must be installed on the target machine.
- **Dependencies:** This role depends on the [geerlingguy.mac.homebrew](https://galaxy.ansible.com/geerlingguy/mac/homebrew) role, which will be invoked to manage Homebrew packages.

## Role Variables

The following variables can be set to customize the behavior of this role:

- **`homebrew_packages`**
  A list of Homebrew packages to install.
  *Default:* `[]`

*Note:* Additional variables may be added as the role evolves. Review the `defaults/main.yml` file for the complete list of configurable variables.

---

## Dependencies

This role depends on:

- **geerlingguy.mac.homebrew**
  Ensure that this role is installed or available via Ansible Galaxy. It is automatically invoked within the dotmodules tasks to manage Homebrew packages.

---

## Example Playbook

Below is an example playbook that demonstrates how to use this role:

```yaml
- hosts: localhost
  gather_facts: false
  roles:
    - role: getfatday.ansible-role-dotmodules
      homebrew_packages:
        - git
        - node
```
