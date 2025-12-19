# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Module-Level Shell Registration**: Modules can now declare shells to be automatically registered in `/etc/shells` via the `register_shell` field in module `config.yml`
  - Supports both shell names (e.g., `zsh`, `fish`) and absolute paths (e.g., `/opt/homebrew/bin/zsh`)
  - Automatic Homebrew path detection based on architecture (Apple Silicon vs Intel)
  - Fully idempotent - multiple runs won't create duplicate entries
  - Optional field - modules without shell registration continue to work unchanged
  - Comprehensive edge case handling (empty values, missing fields, multiple modules with same shell)
  - Integration tests covering all user scenarios
- **Nested Directory Support for Mergeable Files**: The `mergeable_files` configuration now supports nested directory paths (e.g., `.zsh/aliases.sh`, `.config/fish/conf.d/custom.fish`), enabling better organization of configuration files.
  - Parent directories are automatically created for nested mergeable files
  - Both single-level (`.zsh/file.sh`) and multi-level (`.config/a/b/c/file.sh`) nesting are supported
  - Nested files are correctly merged and symlinked using GNU Stow's `--no-folding` option
  - Fully backward compatible with existing root-level mergeable files (`.zshrc`, `.bashrc`, etc.)
  - Comprehensive test coverage for all nesting scenarios

### Changed
- Added `--no-folding` flag to merged files stow commands to ensure proper file-level symlinking for nested directories
- Enhanced module processing to invoke shell registration tasks when `register_shell` is declared

### Fixed
- N/A

## [Previous Releases]

### [1.0.0] - Previous release
- Initial implementation of mergeable files
- GNU Stow integration with `--no-folding` for module files
- Conflict detection between merge and stow strategies
- Homebrew and Mac App Store integration

[Unreleased]: https://github.com/craveytrain/ansible-role-dotmodules/compare/main...HEAD
