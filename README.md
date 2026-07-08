# GroupFiles module for Powershell


<div align=center>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PowerShell 5.1+](https://img.shields.io/badge/PowerShell-6.0%2B-blue)](https://github.com/PowerShell/PowerShell)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/GroupFiles.svg)](https://www.powershellgallery.com/packages/GroupFiles)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/GroupFiles.svg)](https://www.powershellgallery.com/packages/GroupFiles)
[![CI](https://github.com/Mister128/GroupFileModulePowershell/actions/workflows/PesterTests.yml/badge.svg)](https://github.com/Mister128/GroupFileModulePowershell/actions)

**PowerShell module for automatic file organization based on extension rules.**

[Installation](#installation) • [Quick Start](#quick-start) • [Documentation](#available-commands) • [Configuration](#configuration)

</div>

---

## About

**GroupFile** is a PowerShell module that automatically organizes your files into directories based on customizable extension rules. Define once how you want your files sorted, and let the module handle the rest.

Perfect for developers, designers, photographers, and anyone dealing with large amounts of files that need systematic organization.

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Available Commands](#available-commands)
- [Configuration](#configuration)
- [Testing](#testing)
- [Requirements](#requirements)
- [License](#license)

## Installation

### From PowerShell Gallery (recommended)

```powershell
Install-Module GroupFiles -Scope CurrentUser
```

### Manual installation
```powershell
# Clone the repository
git clone https://github.com/yourusername/GroupFiles.git

# Copy to your modules folder
Copy-Item -Path .\GroupFiles\GroupFiles -Destination "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\GroupFiles" -Recurse

# Import the module
Import-Module GroupFiles
```

## Quick Start
```powershell
# Organize files in current directory
Group-File
# NOTE: On first run, the module creates a default config and opens it for editing.
# Run the command again to actually organize your files.

# Organize files in specific directory
Group-File -Path C:\Downloads

# Create missing directories and overwrite existing files
Group-File -Path C:\Downloads -Force

# Process only specific file types
Group-File -Only ".jpg", ".png"

# Open configuration file for editing
Group-File -OpenConfig
```

## Available Commands

### `Group File`

Groups files into directories based on extension rules defined in configuration.

#### Parameters
| Parameter     | Description                                                       |
| ------------- | ----------------------------------------------------------------- |
| `-Path`       | Target directory to process. Defaults to current directory.       |
| `-Only`       | Processes only rules containing specified extensions (array).     |
| `-Force`      | Creates missing target directories and overwrites existing files. |
| `-OpenConfig` | Opens the configuration directory for editing.                    |

## Configuration

Configuration is stored in:
- Windows: `%APPDATA%\GroupFile\GroupFile.config.json`
- Linux\MacOS: `~/.config/GroupFile/GroupFile.config.json`

### Configuration Structure

```json
{
  "Rules": [
    {
        "Extensions": [".png", ".jpeg", ".jpg"],
        "AllowedDirectories": ["picture", "pictures", "images"],
        "DefaultDirectory": "images"
    },
    {
        "Extensions": [".css"],
        "AllowedDirectories": ["css", "styles"],
        "DefaultDirectory": "styles"
    },
    {
        "Extensions": [".js"],
        "AllowedDirectories": ["js", "scripts"],
        "DefaultDirectory": "scripts"
    },
    {
        "Extensions": [".html"],
        "AllowedDirectories": ["html", "pages"],
        "DefaultDirectory": "pages"
    },
  ]
}
```

### Configuration Fields

| Field                | Description                                                                  |
| -------------------- | ---------------------------------------------------------------------------- |
| `Extensions`         | Array of file extensions to match (case-insensitive)                         |
| `AllowedDirectories` | Array of directory names to search for (first existing is used)              |
| `DefaultDirectory`   | Directory to create if none of allowed directories exist (requires `-Force`) |

## Testing

The module is covered by Pester 5 tests (16 tests).

```powershell
# Install Pester 5 (if needed)
Install-Module Pester -Force -SkipPublisherCheck -Scope CurrentUser

# Run all tests
Invoke-Pester -Path .\Tests\

# Run tests with detailed output
Invoke-Pester -Path .\Tests\ -Output Detailed
```

## Requirements
- PowerShell 6.0+ (Windows PowerShell or PowerShell Core 7+)
- Windows 10/11, Windows Server 2016+, Linux, or macOS
- Pester 5+ (for running tests)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
