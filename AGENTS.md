# ansible-role-dotmodules Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-12-16

## Active Technologies
- File-based (module config.yml files, /etc/shells system file) (001-register-shell-support)
- YAML-based Ansible playbooks (Ansible 2.9+) + Ansible core modules (copy, template, lineinfile, blockinfile), GNU Stow, Jinja2 (built into Ansible) (002-local-config-overrides)
- Filesystem (user's home directory, dotfiles repository) (002-local-config-overrides)

- Ansible 2.9+ (YAML-based playbooks and tasks) + GNU Stow, Jinja2 (built into Ansible), Ansible community.general collection (001-nested-mergeable-files)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Ansible 2.9+ (YAML-based playbooks and tasks)

## Code Style

Ansible 2.9+ (YAML-based playbooks and tasks): Follow standard conventions

## Recent Changes
- 002-local-config-overrides: Added YAML-based Ansible playbooks (Ansible 2.9+) + Ansible core modules (copy, template, lineinfile, blockinfile), GNU Stow, Jinja2 (built into Ansible)
- 001-register-shell-support: Added Ansible 2.9+ (YAML-based playbooks and tasks) + GNU Stow, Jinja2 (built into Ansible), Ansible community.general collection

- 001-nested-mergeable-files: Added Ansible 2.9+ (YAML-based playbooks and tasks) + GNU Stow, Jinja2 (built into Ansible), Ansible community.general collection

<!-- MANUAL ADDITIONS START -->

## Git Workflow (For Claude Code)

**IMPORTANT: Always follow this git workflow when making changes:**

### Branch Strategy

1. **Never commit directly to `main`** - Always create a feature branch first
2. **Branch naming convention:**
   - `feat/description` - New features
   - `fix/description` - Bug fixes
   - `docs/description` - Documentation updates
   - `refactor/description` - Code refactoring
   - `test/description` - Test additions/updates
   - `chore/description` - Maintenance tasks

### Workflow Steps

**Before starting work:**
```bash
git checkout main
git pull origin main
git checkout -b <type>/<description>
```

**After completing work:**

For **features** (new functionality, refactoring, breaking changes):
1. Push the branch: `git push -u origin <branch-name>`
2. Create a Pull Request for review
3. Wait for user approval before merging

For **fixes** (bug fixes, documentation, typos):
1. Commit the changes on the feature branch
2. Offer to either:
   - Create a PR, or
   - Merge directly to main if the user prefers

### Commit Messages

Use conventional commit format:
```
<type>: <description>

[optional body explaining what and why]
```

Examples:
- `feat: Add shell registration support`
- `fix: Resolve stow conflict with nested files`
- `docs: Update contributing guidelines`
- `refactor: Simplify shell registration logic`

### Current Situation

If you find uncommitted changes on `main` when starting new work:
1. Check `git status`
2. If there are changes, create a branch first
3. Move the changes to the branch before continuing

<!-- MANUAL ADDITIONS END -->
