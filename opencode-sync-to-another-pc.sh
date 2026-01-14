#!/bin/bash
# OpenCode Sync Script
# Usage: ./opencode-sync-to-another-pc.sh [setup|sync|update]
# Description: Clone repository, sync configuration, and push updates back

set -e

# Configuration
REPO_URL="https://github.com/oywjun/opencode-skills-mcp.git"
REPO_DIR="$HOME/opencode-skills-mcp"
OPENC_DIR="$HOME/.config/opencode"
SKILLS_DIR="$HOME/.claude"
CONFIG_FILE="$HOME/.config/opencode/opencode.json"
BACKUP_FILE="opencode-backup-$(date +%Y%m%d).tar.gz"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check dependencies
check_dependencies() {
    if ! command -v git &> /dev/null; then
        log_error "git is not installed. Please install git first."
        exit 1
    fi
    
    if ! command -v rsync &> /dev/null; then
        log_error "rsync is not installed. Please install rsync first."
        exit 1
    fi
    
    if ! command -v gh &> /dev/null; then
        log_warn "GitHub CLI not installed. Install from https://cli.github.com/"
    fi
    
    if ! command -v python3 &> /dev/null; then
        log_warn "python3 not found. JSON config restoration may fail."
    fi
}

# Clone or update based on command
case "$1" in
    setup)
        log "=== 🚀 Setup OpenCode Sync ==="
        echo "Cloning repository from $REPO_URL"
        
        if [ -d "$REPO_DIR" ]; then
            log_warn "Directory already exists: $REPO_DIR"
            read -p "Directory exists. Overwrite? [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -rf "$REPO_DIR"
            else
                log "Keeping existing directory"
                exit 0
            fi
        fi
        
        git clone "$REPO_URL" "$REPO_DIR" || {
            log_error "Failed to clone repository"
            exit 1
        }
        
        log_success "✅ Repository cloned to $REPO_DIR"
        echo ""
        echo "Next steps:"
        echo "1. Update and push changes from current computer"
        echo "2. On other computer:"
        echo "   cd $REPO_DIR"
        echo "   ./opencode-sync-to-another-pc.sh update"
        ;;
    
    update)
        log "=== 🔄 Update OpenCode Configuration ==="
        
        # Check if git repository
        cd "$REPO_DIR" || exit 1
        
        if ! git rev-parse --is-inside-work-tree &> /dev/null; then
            log_warn "Not a git repository or not in git repo"
            exit 1
        fi
        
        # Pull latest changes
        log "Pulling latest changes..."
        git pull origin main || log_warn "Failed to pull from origin"
        
        # Copy updated files from local config
        log "Copying files from local config..."
        
        if [ -d "$OPENC_DIR/mcp" ]; then
            rsync -av --exclude='node_modules/' --exclude='__pycache__/' --exclude='*.pyc' \
                --exclude='lib/' --exclude='dist/' --exclude='build/' --exclude='obj/' --exclude='.git/' \
                "$OPENC_DIR/mcp/" "$REPO_DIR/" || log_warn "Failed to copy MCP files"
            echo "✅ MCP servers updated"
        else
            log_warn "MCP directory not found: $OPENC_DIR/mcp"
        fi
        
        if [ -d "$SKILLS_DIR" ]; then
            rsync -av --exclude='__pycache__/' --exclude='*.pyc' --exclude='.git/' \
                "$SKILLS_DIR/" "$REPO_DIR/skills/" || log_warn "Failed to copy skills"
            echo "✅ Skills updated"
        else
            log_warn "Skills directory not found: $SKILLS_DIR"
        fi
        
        # Update opencode-config.json
        if [ -f "$CONFIG_FILE" ]; then
            python3 << 'PYTHON3'
import json

try:
    config_path = "/home/eli/.config/opencode/opencode.json"
    output_path = "/home/eli/opencode-skills-mcp/opencode-config.json"
    
    with open(config_path, "r") as f:
        config = json.load(f)
    
    backup = {}
    if "mcp" in config:
        backup["mcp"] = config["mcp"]
    if "permission" in config:
        backup["permission"] = config["permission"]
    
    with open(output_path, "w") as f:
        json.dump(backup, f, indent=2)
    
    print("✅ Configuration updated")
except Exception as e:
    print(f"⚠️ Warning: {e}")
PYTHON3
        else
            log_warn "Config file not found: $CONFIG_FILE"
        fi
        
        echo ""
        log_success "✅ Configuration updated"
        echo ""
        echo "📤 Pushing changes to GitHub..."
        git add -A || log_warn "No changes to commit"
        
        # Create commit message
        COMMIT_MSG="chore: Update OpenCode skills and MCP configuration - $(date +%Y-%m-%d)"
        
        if git commit -m "$COMMIT_MSG"; then
            git push origin main && log_success "✅ Configuration pushed to GitHub"
        else
            log_warn "Nothing to push"
        fi
        ;;
    
    restore)
        log "=== 🔄 Restore OpenCode Configuration ==="
        
        # Check git repository
        cd "$REPO_DIR" || exit 1
        
        # Pull latest first
        log "Updating repository..."
        git pull origin main || log_warn "Failed to pull. Continuing with local version..."
        
        # Restore MCP servers
        log "Restoring MCP servers to $OPENC_DIR/mcp/"
        mkdir -p "$OPENC_DIR/mcp" || log_warn "MCP directory not found"
        rsync -av "$REPO_DIR/" "$OPENC_DIR/mcp/" || log_warn "Failed to restore MCP files"
        
        # Restore skills
        log "Restoring skills to $SKILLS_DIR/"
        mkdir -p "$SKILLS_DIR" || log_warn "Skills directory not found"
        rsync -av "$REPO_DIR/skills/" "$SKILLS_DIR/" || log_warn "Failed to restore skills"
        
        # Restore OpenCode config
        if [ -f "$REPO_DIR/opencode-config.json" ]; then
            python3 << 'PYTHON3'
import json

try:
    config_path = "/home/eli/.config/opencode/opencode.json"
    restore_path = "/home/eli/opencode-skills-mcp/opencode-config.json"
    
    with open(config_path, "r") as f:
        config = json.load(f)
    
    with open(restore_path, "r") as f:
        restore_data = json.load(f)
    
    config.update(restore_data)
    
    with open(config_path, "w") as f:
        json.dump(config, f, indent=2)
    
    print("✅ Configuration restored")
except Exception as e:
    print(f"⚠️ Warning: {e}")
PYTHON3
        else
            log_warn "No opencode-config.json found in repository"
        fi
        
        echo ""
        log_success "✅ Configuration restored"
        echo ""
        echo "🎉 Restore complete!"
        echo ""
        echo "📝 Please restart OpenCode to load skills and MCP servers"
        ;;
    
    *)
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  setup   - Clone repository and prepare for sync"
        echo "  update  - Pull latest changes and push local changes to GitHub"
        echo "  restore - Restore configuration from repository"
        echo ""
        echo "Examples:"
        echo "  ./opencode-sync-to-another-pc.sh setup"
        echo "  ./opencode-sync-to-another-pc.sh update"
        echo "  ./opencode-sync-to-another-pc.sh restore"
        exit 0
        ;;
esac

exit 0
