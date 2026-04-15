from datetime import datetime
from pathlib import Path

dotfiles = Path(__file__).parent / "dotfiles"
home = Path("~").expanduser()
now = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

# Link all dotfiles.
for config_name in (".config/nvim/init.lua", ".tmux.conf", ".zshrc", ".ssh/config"):
    source = dotfiles / config_name
    target = home / config_name

    # Ensure that the target directory exists.
    if not target.parent.exists():
        target.parent.mkdir(parents=True, exist_ok=True)
        print(f"Created directory `{target.parent}`.")

    # If the target exists, either it is already linked or we need to back up.
    if target.exists():
        if target.is_symlink():
            print(f"Already linked: `{config_name}`.")
            continue
        else:
            backup = target.parent / f"{config_name}.backup_{now}"
            target.rename(backup)
            print(f"Existing `{source}` backed up.")

    # Do the linking.
    print(f"Linking `{config_name}`.")
    target.symlink_to(source)
