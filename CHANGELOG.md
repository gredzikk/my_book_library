# Changelog

All notable changes to My Book Library will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Version management system with automated build scripts
- Auto-increment version based on git commits
- PowerShell, Batch, and Bash build scripts

## [1.0.0] - 2025-10-16

### Added
- Initial release
- Book library management
- Supabase authentication
- Google Books API integration
- Genre filtering and categorization
- Reading session tracking
- Book details view
- Add/Edit book functionality

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

---

## Version Format

Versions follow the format: `MAJOR.MINOR.PATCH+BUILD_NUMBER`

- **MAJOR**: Breaking changes, incompatible API changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible
- **BUILD_NUMBER**: Internal build counter for releases

## How to Update This File

Before each release:

1. Move items from "Unreleased" to a new version section
2. Update the version number and date
3. Categorize changes under appropriate headers:
   - **Added**: New features
   - **Changed**: Changes to existing functionality
   - **Deprecated**: Soon-to-be removed features
   - **Removed**: Removed features
   - **Fixed**: Bug fixes
   - **Security**: Security updates

## Example Entry

```markdown
## [1.2.3] - 2025-10-20

### Added
- Dark mode support
- Export books to CSV

### Fixed
- Fixed crash when viewing book details
- Improved search performance
```

