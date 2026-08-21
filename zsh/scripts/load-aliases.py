#!/usr/bin/env python3
# Reads aliases.json and adds them
import glob
import os
import shutil
import subprocess
import json
from pathlib import Path

def command_exists(name):
    return shutil.which(name) is not None

def main():
    alias_lines = []

    if command_exists("brew"):
        result = subprocess.run(
            ["brew", "--prefix"], capture_output=True, text=True, check=False
        )
        brew_prefix = result.stdout.strip()
        if brew_prefix:
            alias_lines.append(f'alias nano="{brew_prefix}/bin/nano"')

    alias_lines.append(
        f'alias zconf="{os.path.expanduser("~")}/.dotfiles/zsh/tools/zshconfig"'
    )
    alias_lines.append('alias zsrc="source ~/.zshrc"')

    app_dirs = ["/Applications", os.path.expanduser("~/Applications")]

    for dir_path in app_dirs:
        if os.path.isdir(dir_path):
            for app_path in glob.glob(os.path.join(dir_path, "*.app")):
                app_name = os.path.splitext(os.path.basename(app_path))[0]
                alias_name = app_name.lower().replace(" ", "-")
                if not command_exists(alias_name):
                    alias_lines.append(
                        f'alias {alias_name}="open -a \"{app_name}\""'
                    )
    # Load user aliases from ~/.dotfiles/resources/aliases.json if present
    aliases_path = Path(os.path.expanduser("~")) / ".dotfiles" / "resources" / "aliases.json"
    if aliases_path.exists():
        try:
            with aliases_path.open("r", encoding="utf-8") as f:
                data = json.load(f)
            if isinstance(data, dict):
                for name, cmd in data.items():
                    if name == "alias":
                        continue
                    # Escape double quotes in the command
                    safe_cmd = str(cmd).replace('"', '\\"')
                    alias_lines.append(f'alias {name}="{safe_cmd}"')
        except Exception:
            # ignore malformed JSON
            pass

    for line in alias_lines:
        print(line)


if __name__ == "__main__":
    main()
