# Contributing to ansible-role-dotmodules

Thank you for your interest in contributing! This document outlines our git workflow and contribution guidelines.

## Git Workflow

### Branch Naming Convention

We use a type-based branch naming convention:

- `feat/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring
- `test/description` - Test additions or updates
- `chore/description` - Maintenance tasks (dependencies, tooling, etc.)

**Examples:**
```bash
feat/add-shell-registration
fix/stow-conflict-handling
docs/update-readme
refactor/simplify-config
```

### Development Process

1. **Create a feature branch** from `main`:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feat/your-feature-name
   ```

2. **Make your changes** and commit regularly:
   ```bash
   git add <files>
   git commit -m "descriptive message"
   ```

3. **Push your branch**:
   ```bash
   git push -u origin feat/your-feature-name
   ```

4. **Open a Pull Request** (for features) or **merge directly** (for fixes):
   - **Features require PRs**: Use GitHub to create a PR for review
   - **Fixes can merge directly**: Small bug fixes and documentation updates can merge without PR
   ```bash
   # For direct merge (fixes only):
   git checkout main
   git merge feat/your-feature-name
   git push origin main
   ```

### When to Use Pull Requests

**Require PR (review recommended):**
- New features
- Breaking changes
- Major refactoring
- Changes affecting multiple files
- Architectural decisions

**Direct merge allowed:**
- Bug fixes
- Documentation updates
- Typo corrections
- Dependency updates
- Minor refactoring

### Commit Message Format

Follow conventional commit format:

```
<type>: <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Maintenance tasks

**Example:**
```
feat: Add module-level shell registration support

Modules can now declare shells to be automatically registered in
/etc/shells via the register_shell field in module config.yml.

- Supports both shell names and absolute paths
- Automatic Homebrew path detection
- Fully idempotent
```

### Pull Request Guidelines

When creating a PR:

1. **Title**: Use conventional commit format
2. **Description**: Explain what and why
3. **Testing**: Describe how you tested the changes
4. **Link issues**: Reference related issues with `Fixes #123`

### Testing

Before submitting:

```bash
# Run relevant tests
ansible-playbook tests/test-shell-registration.yml --skip-tags register_shell
ansible-playbook tests/test-merge.yml --skip-tags register_shell
ansible-playbook tests/test-conflict.yml --skip-tags register_shell
```

### Code Review Process

1. Maintainer reviews PR
2. Address feedback if needed
3. Maintainer merges when approved
4. Delete feature branch after merge

## Questions?

Open an issue for questions or clarifications about the contribution process.
