#!/bin/bash

# Set strict error handling
set -euo pipefail

# Script variables
TIMESTAMP=$(date +%Y%m%d%H%M%S)
LOG_FILE="python_cleanup_${TIMESTAMP}.log"
BACKUP_DIR="$HOME/.config/python_cleanup_backups_${TIMESTAMP}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Function to check command existence
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to backup a file
backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "${BACKUP_DIR}/$(basename "$file").backup_${TIMESTAMP}"
        log "Backed up $file to ${BACKUP_DIR}/$(basename "$file").backup_${TIMESTAMP}"
    fi
}

# Function to get current Python version from Homebrew
get_current_python_version() {
    brew list python@3.12 --versions | cut -d' ' -f2
}

# Function to check if a string exists in a file
string_exists_in_file() {
    local string=$1
    local file=$2
    grep -q "$string" "$file" 2>/dev/null
}

# Initialize logging
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

log "Starting Python environment cleanup script..."
log "Creating backup directory at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Verification before proceeding
echo -e "\n${YELLOW}This script will:${NC}"
echo "1. Remove Python versions except 3.12"
echo "2. Remove pipx"
echo "3. Update Python configuration files"
echo "4. Clear Python cache files"
echo "5. Update shell configuration"
echo -e "\n${YELLOW}Backups will be created in:${NC} $BACKUP_DIR"
echo -e "${RED}Are you sure you want to proceed? (yes/no)${NC}"
read -r response
if [[ ! "$response" =~ ^yes$ ]]; then
    log "Script cancelled by user"
    exit 0
fi

# Check for Homebrew
if ! command_exists brew; then
    log_error "Homebrew is not installed. Please install it first."
    exit 1
fi

# 1. Handle Python versions
log "Checking installed Python versions..."
for version in "3.10" "3.11" "3.13"; do
    if brew list --versions "python@$version" >/dev/null 2>&1; then
        log "Uninstalling python@$version..."
        brew uninstall --ignore-dependencies "python@$version" || log_warning "Failed to uninstall python@$version"
    fi
done

# 2. Handle pipx
if brew list --versions pipx >/dev/null 2>&1; then
    log "Uninstalling pipx..."
    brew uninstall pipx || log_warning "Failed to uninstall pipx"
fi

# 3. Setup Python 3.12
log "Setting up Python 3.12..."
if ! brew list --versions python@3.12 >/dev/null 2>&1; then
    log "Installing Python 3.12..."
    brew install python@3.12
fi

log "Unlinking and relinking Python 3.12..."
brew unlink python@3.12 2>/dev/null || true
brew link --overwrite python@3.12

# 4. Setup pip configuration
log "Setting up pip configuration..."
mkdir -p ~/.config/pip
backup_file ~/.config/pip/pip.conf

cat > ~/.config/pip/pip.conf << EOF
[global]
user = true
require-virtualenv = true
EOF
log_success "Created pip configuration"

# 5. Update .zshrc
log "Updating .zshrc..."
backup_file ~/.zshrc

# Get the dynamic Python paths
PYTHON_PATH=$(which python3.12 || which python3)
PIP_PATH=$(which pip3.12 || which pip3)

# Prepare Python configuration block
read -r -d '' PYTHON_CONFIG << EOF

# >>> Python configuration $(date) >>>
# Homebrew and Python paths
export PATH="/opt/homebrew/bin:\$PATH"
export PATH="/opt/homebrew/opt/python@3.12/bin:\$PATH"

# Python aliases
alias python3="$PYTHON_PATH"
alias python="$PYTHON_PATH"
alias pip3="$PIP_PATH"
alias pip="$PIP_PATH"

# Python virtual environment shortcuts
alias venv='python3 -m venv venv'
alias activate='source venv/bin/activate'
alias create-venv='python3 -m venv venv && source venv/bin/activate'

# Safety aliases
alias pip-install='pip install --user'

# Function to create and activate a new Python project
pynew() {
    mkdir -p "\$1" && cd "\$1"
    python3 -m venv venv
    source venv/bin/activate
    PIP_REQUIRE_VIRTUALENV=false pip install --upgrade pip
    echo "Python project \$1 created and virtual environment activated"
}
# <<< End Python configuration <<<
EOF

# Remove old Python configuration if exists
sed -i.bak '/# >>> Python configuration/,/# <<< End Python configuration <<</d' ~/.zshrc

# Add new Python configuration
echo "$PYTHON_CONFIG" >> ~/.zshrc
log_success "Updated .zshrc with new Python configuration"

# 6. Setup global gitignore for Python
log "Setting up global gitignore..."
backup_file ~/.gitignore_global

cat > ~/.gitignore_global << EOF
# Python
__pycache__/
*.py[cod]
*$py.class
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
.pytest_cache/
.coverage
coverage.xml
*.cover
.env
venv/
ENV/
.DS_Store
EOF

git config --global core.excludesfile ~/.gitignore_global
log_success "Created global gitignore"

# 7. Clear Python cache files
log "Preparing to clear Python cache files..."
echo -e "${YELLOW}Do you want to clear Python cache files? This will remove all __pycache__ directories and .pyc files. (yes/no)${NC}"
read -r response
if [[ "$response" =~ ^yes$ ]]; then
    log "Clearing Python cache files..."
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    log_success "Cleared Python cache files"
else
    log "Skipping cache cleanup"
fi

# 8. Verify installation
log "Verifying installation..."
echo -e "\n${BLUE}Python Environment Information:${NC}"
echo "Python version: $(python3 --version 2>&1)"
echo "Python location: $(which python3 2>&1)"
echo "Pip version: $(pip3 --version 2>&1)"
echo "Pip location: $(which pip3 2>&1)"

# Final message
echo -e "\n${GREEN}Python environment cleanup complete!${NC}"
echo "Backup of configurations can be found in: $BACKUP_DIR"
echo "Log file: $LOG_FILE"
echo -e "${YELLOW}Please open a new terminal window for all changes to take effect.${NC}"