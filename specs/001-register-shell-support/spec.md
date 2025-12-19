# Feature Specification: Module-Level Shell Registration

**Feature Branch**: `001-register-shell-support`  
**Created**: 2025-12-18  
**Status**: Draft  
**Input**: User description: "Add module-level shell registration support to allow modules to declare shells that should be registered in /etc/shells"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Module Declares Shell Registration (Priority: P1)

A module maintainer wants their Homebrew-installed shell to be automatically registered in `/etc/shells` when the module is deployed. They add a `register_shell` field to their module's `config.yml`, and the ansible-role-dotmodules automatically handles the registration without requiring any changes to the consuming playbook.

**Why this priority**: This is the core feature - enabling modules to be self-contained and declare their own shell registration needs. Without this, playbooks must hard-code module-specific logic, violating modularity principles.

**Independent Test**: Can be fully tested by adding `register_shell: /opt/homebrew/bin/zsh` to a module's config.yml, running the role, and verifying `/etc/shells` contains the shell path. Delivers immediate value by eliminating playbook-level shell registration code.

**Acceptance Scenarios**:

1. **Given** a module config.yml with `register_shell: /opt/homebrew/bin/zsh`, **When** the role processes the module, **Then** `/etc/shells` contains `/opt/homebrew/bin/zsh`
2. **Given** a module config.yml with `register_shell: /opt/homebrew/bin/fish`, **When** the role processes the module, **Then** `/etc/shells` contains `/opt/homebrew/bin/fish`
3. **Given** two modules both declare shell registration, **When** the role runs, **Then** both shells are registered in `/etc/shells`

---

### User Story 2 - Idempotent Shell Registration (Priority: P1)

A user runs their dotfiles playbook multiple times (updating configurations, testing changes). The shell registration tasks detect existing entries and do not create duplicates in `/etc/shells`, maintaining idempotency across role executions.

**Why this priority**: Idempotency is critical for Ansible roles - users must be able to safely re-run playbooks without corrupting system files or creating duplicates.

**Independent Test**: Can be tested by running the role 10 consecutive times with a module that declares shell registration, then verifying `/etc/shells` contains exactly one entry for the shell. Ansible should report "ok" status (not "changed") on runs 2-10.

**Acceptance Scenarios**:

1. **Given** `/etc/shells` already contains `/opt/homebrew/bin/zsh`, **When** the role runs with zsh module, **Then** no duplicate entry is added
2. **Given** the role has been run successfully once, **When** run 10 times consecutively, **Then** `/etc/shells` remains unchanged after the first run
3. **Given** shells are already registered, **When** the role runs, **Then** Ansible reports "ok" status (no changes)

---

### User Story 3 - Module Without Shell Registration (Priority: P1)

A module does not require shell registration (e.g., git module, fonts module). The module's config.yml omits the `register_shell` field, and the role skips shell registration tasks entirely for that module, avoiding unnecessary operations.

**Why this priority**: Not all modules need shell registration - the feature must be optional to avoid forcing unnecessary configuration on modules that don't need it.

**Independent Test**: Can be tested by processing a module without `register_shell` in its config.yml and verifying no shell registration tasks are attempted. Delivers value by keeping the feature opt-in and lightweight.

**Acceptance Scenarios**:

1. **Given** a module config.yml without `register_shell` field, **When** the role processes the module, **Then** no shell registration task is executed
2. **Given** multiple modules where only one declares `register_shell`, **When** the role runs, **Then** only that one shell is registered
3. **Given** no modules declare `register_shell`, **When** the role runs, **Then** no shell registration tasks are executed

---

### User Story 4 - Cross-Platform Shell Path Detection (Priority: P2)

A user runs the role on both Apple Silicon and Intel Macs. The role automatically detects the correct Homebrew path (`/opt/homebrew` vs `/usr/local`) and uses the appropriate path when registering shells, ensuring compatibility across Mac architectures.

**Why this priority**: Homebrew uses different paths on Apple Silicon vs Intel. Supporting both architectures without manual configuration improves user experience.

**Independent Test**: Can be tested by running on Apple Silicon (verifies `/opt/homebrew/bin/*` paths) and Intel (verifies `/usr/local/bin/*` paths). Delivers value by eliminating manual path configuration.

**Acceptance Scenarios**:

1. **Given** Apple Silicon Mac with `register_shell: zsh`, **When** the role runs, **Then** `/opt/homebrew/bin/zsh` is registered
2. **Given** Intel Mac with `register_shell: zsh`, **When** the role runs, **Then** `/usr/local/bin/zsh` is registered
3. **Given** module specifies absolute path `register_shell: /custom/path/shell`, **When** the role runs, **Then** the exact path `/custom/path/shell` is registered (no modification)

---

### Edge Cases

- What happens when `/etc/shells` does not exist? (Role creates it with appropriate permissions)
- What happens when user lacks sudo privileges? (Task fails with clear error message requesting elevated permissions)
- What happens when `register_shell` value is empty or whitespace? (Task skips registration - no error)
- What happens when `register_shell` is a relative path? (Role should error or warn - only absolute paths valid)
- What happens when multiple modules declare the same shell? (First module registers it, subsequent modules see it exists - idempotent)
- What happens when shell binary doesn't exist at specified path? (Registration proceeds anyway - `/etc/shells` doesn't validate existence)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Role MUST read `register_shell` field from module config.yml files during module processing
- **FR-002**: Role MUST support `register_shell` as an optional field (modules without it are processed normally)
- **FR-003**: Role MUST register shells in `/etc/shells` only for modules that declare `register_shell`
- **FR-004**: Role MUST ensure idempotent shell registration (running multiple times does not create duplicates)
- **FR-005**: Role MUST require elevated privileges (become: yes) for `/etc/shells` modification
- **FR-006**: Role MUST preserve existing `/etc/shells` content when adding new entries
- **FR-007**: Role MUST add shell paths as complete lines in `/etc/shells` (one path per line)
- **FR-008**: Role MUST support both simple shell names (e.g., `zsh`) and absolute paths (e.g., `/custom/path/shell`)
- **FR-009**: Role MUST auto-detect Homebrew prefix (`/opt/homebrew` or `/usr/local`) for simple shell names
- **FR-010**: Role MUST skip shell registration tasks when no modules declare `register_shell`
- **FR-011**: Role MUST report Ansible status correctly ("changed" when adding, "ok" when already present)
- **FR-012**: Role MUST handle multiple modules declaring shell registration in a single playbook run

### Key Entities

- **Module Config (config.yml)**: YAML file defining module dependencies, stow dirs, mergeable files, and optionally shell registration
- **register_shell Field**: Optional string field in module config specifying shell to register (shell name or absolute path)
- **/etc/shells**: System file containing list of valid login shells (one absolute path per line)
- **Shell Path**: Absolute path to shell binary (either user-specified or auto-detected from Homebrew prefix + shell name)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Modules can declare shell registration via `register_shell` field with 100% success rate
- **SC-002**: Shell registration is 100% idempotent (multiple runs produce identical `/etc/shells` content)
- **SC-003**: Role correctly auto-detects Homebrew prefix on both Apple Silicon and Intel Macs (100% accuracy)
- **SC-004**: Modules without `register_shell` field process without errors (100% backward compatibility)
- **SC-005**: Running role with 5 modules (2 declaring shells) registers exactly 2 shells (0 false positives)
- **SC-006**: Consuming playbooks require 0 lines of shell registration code (100% module encapsulation)

## Assumptions *(mandatory)*

- Homebrew is installed in standard location (`/opt/homebrew` for Apple Silicon, `/usr/local` for Intel)
- User running playbook has sudo privileges or can authenticate for privilege escalation
- macOS system has `/etc/shells` file or allows its creation
- Shell binaries are installed via Homebrew/module before shell registration tasks run
- Standard Ansible lineinfile module behavior is sufficient for idempotent line management
- Module config.yml files are valid YAML and follow existing schema conventions

## Out of Scope

- Automatic removal of shell paths when modules are removed from install list
- Validation that shell binaries actually exist before registration
- Support for non-macOS platforms (Linux handles shells differently)
- Migration of users' active shell to registered shells (requires explicit `chsh` command)
- Custom Homebrew installation paths beyond standard locations
- Shell registration for non-Homebrew shells (system shells, custom builds)

