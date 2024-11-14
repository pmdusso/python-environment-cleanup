# Python Environment Cleanup Script for macOS

A comprehensive script to clean up and standardize Python development environment on macOS using Homebrew.

## Overview

This script helps you maintain a clean Python development environment by:
- Standardizing on Python 3.12
- Removing older/unnecessary Python versions
- Setting up proper pip configuration
- Configuring virtual environment defaults
- Setting up Python-specific git ignores
- Creating useful Python-related aliases and functions

## Prerequisites

- macOS
- [Homebrew](https://brew.sh/) installed
- Zsh shell (default on modern macOS)
- Git (for global gitignore configuration)

## Features

- ✨ Single Python version management
- 🔒 Safe environment configuration
- 🧹 Cleanup of old Python versions
- 📝 Comprehensive logging
- 💾 Automatic backups of modified files
- ⚡ Useful shortcuts and functions for Python development
- 🛡️ Virtual environment enforcement
- 🎯 Git configuration for Python projects

## Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/python-environment-cleanup.git
cd python-environment-cleanup
```

2. Make the script executable:
```bash
chmod +x cleanup_python.sh
```

3. Run the script:
```bash
./cleanup_python.sh
```

## What the Script Does

### 1. Python Version Management
- Uninstalls Python versions 3.10, 3.11, and 3.13 (if present)
- Ensures Python 3.12 is properly installed and linked

### 2. Configuration
- Sets up pip configuration to require virtual environments
- Configures Python-specific global gitignore
- Updates shell configuration with useful aliases and functions

### 3. Environment Cleanup
- Removes Python cache files (optional)
- Cleans up old pip installations
- Removes pipx if installed

### 4. Shell Configuration
Adds the following to your `.zshrc`:
- Python aliases for consistency
- Virtual environment shortcuts
- Project creation helpers
- Path configurations

### 5. Added Functions and Aliases

#### Virtual Environment Shortcuts
```bash
alias venv='python3 -m venv venv'
alias activate='source venv/bin/activate'
alias create-venv='python3 -m venv venv && source venv/bin/activate'
```

#### Project Creation
```bash
pynew projectname  # Creates a new Python project with virtual environment
```

#### Safety Aliases
```bash
alias pip-install='pip install --user'
```

## Safety Features

- Creates backups of all modified files
- Logs all operations
- Requests confirmation before destructive operations
- Verifies installation success

## Backup and Logging

The script creates:
- Backups of all modified configuration files in `~/.config/python_cleanup_backups_[timestamp]`
- A detailed log file of all operations in `python_cleanup_[timestamp].log`

## Usage

### Basic Usage
```bash
./cleanup_python.sh
```

### After Running
1. Open a new terminal window
2. Verify Python installation:
```bash
python3 --version  # Should show Python 3.12.x
```

### Creating a New Python Project
```bash
pynew myproject
```
This will:
- Create a new directory `myproject`
- Set up a virtual environment
- Activate the environment
- Upgrade pip to the latest version

## File Modifications

The script modifies the following files (after backing them up):
- `~/.zshrc`
- `~/.config/pip/pip.conf`
- `~/.gitignore_global`

## Troubleshooting

### Common Issues

1. **Homebrew not installed**
```bash
brew not found
```
Solution: Install Homebrew first:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. **Permission denied**
```bash
Permission denied: ./cleanup_python.sh
```
Solution: Make the script executable:
```bash
chmod +x cleanup_python.sh
```

3. **Python 3.12 installation fails**
Solution: Try updating Homebrew:
```bash
brew update
brew doctor
```

### Reverting Changes

The script creates backups of all modified files. To revert:
1. Go to `~/.config/python_cleanup_backups_[timestamp]`
2. Restore the desired backup files

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by Python development best practices
- Built for macOS and Homebrew users
- Community feedback and contributions

## Additional Resources

- [Python Virtual Environments](https://docs.python.org/3/tutorial/venv.html)
- [pip Documentation](https://pip.pypa.io/en/stable/)
- [Homebrew Documentation](https://docs.brew.sh)