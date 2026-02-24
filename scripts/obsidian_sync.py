#!/usr/bin/env python3
import os
import sys
import datetime
import re

# Optimized path detection for Android devices
# Auto-detect SD card UUID instead of hardcoding
INTERNAL_PATH = '/storage/emulated/0/Documents/Obsidian'

def _detect_sd_obsidian():
    """Find Obsidian vault on any SD card."""
    storage = '/storage'
    if os.path.isdir(storage):
        for entry in os.listdir(storage):
            if entry in ('emulated', 'self'):
                continue
            candidate = os.path.join(storage, entry, 'Obsidian')
            if os.path.isdir(candidate):
                return candidate
            # Also check if SD card root exists (vault can be created later)
            sd_root = os.path.join(storage, entry)
            if os.path.isdir(sd_root):
                return os.path.join(sd_root, 'Obsidian')
    return None

SD_CARD_PATH = _detect_sd_obsidian()

DEFAULT_VAULT_PATH = os.environ.get('OBSIDIAN_VAULT')
if not DEFAULT_VAULT_PATH:
    if SD_CARD_PATH and os.path.exists(os.path.dirname(SD_CARD_PATH)):
        DEFAULT_VAULT_PATH = SD_CARD_PATH
    else:
        DEFAULT_VAULT_PATH = INTERNAL_PATH

def sanitize_filename(name):
    return re.sub(r'[\\/*?:"<>|]', "", name)

def save_note(title, content, folder=""):
    vault_path = DEFAULT_VAULT_PATH
    
    # Ensure vault exists
    try:
        if not os.path.exists(vault_path):
            os.makedirs(vault_path, exist_ok=True)
    except OSError:
        # Fallback to internal if SD card is not writable
        vault_path = INTERNAL_PATH
        os.makedirs(vault_path, exist_ok=True)

    target_dir = os.path.join(vault_path, folder)
    if not os.path.exists(target_dir):
        os.makedirs(target_dir, exist_ok=True)

    filename = sanitize_filename(title)
    if not filename.endswith(".md"):
        filename += ".md"
    
    file_path = os.path.join(target_dir, filename)
    
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    frontmatter = f"---\ndate: {timestamp}\ntags: [aplibot, auto-generated]\n---\n\n"
    
    try:
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(frontmatter + content)
        print(f"Success: Note saved to {file_path}")
        return True
    except Exception as e:
        print(f"Error saving note: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: obsidian_sync.py <title> <content> [folder]")
        sys.exit(1)
    
    title = sys.argv[1]
    content = sys.argv[2]
    folder = sys.argv[3] if len(sys.argv) > 3 else ""
    
    if save_note(title, content, folder):
        sys.exit(0)
    else:
        sys.exit(1)
