# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Nested Directory Support for Mergeable Files**: The `mergeable_files` configuration now supports nested directory paths (e.g., `.zsh/aliases.sh`, `.config/fish/conf.d/custom.fish`), enabling better organization of configuration files.
  - Parent directories are automatically created for nested mergeable files
  - Both single-level (`.zsh/file.sh`) and multi-level (`.config/a/b/c/file.sh`) nesting are supported
  - Nested files are correctly merged and symlinked using GNU Stow's `--no-folding` option
  - Fully backward compatible with existing root-level mergeable files (`.zshrc`, `.bashrc`, etc.)
  - Comprehensive test coverage for all nesting scenarios

### Changed
- Added `--no-folding` flag to merged files stow commands to ensure proper file-level symlinking for nested directories

### Fixed
- N/A

## [Previous Releases]

### [1.0.0] - Previous release
- Initial implementation of mergeable files
- GNU Stow integration with `--no-folding` for module files
- Conflict detection between merge and stow strategies
- Homebrew and Mac App Store integration

[Unreleased]: https://github.com/craveytrain/ansible-role-dotmodules/compare/main...HEAD
