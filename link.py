from pathlib import Path
from datetime import datetime


dotfiles = Path(__file__).parent / "dotfiles"
home = Path("~").expanduser()
now = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

# Link all dotfiles.
for config_name in (".vimrc", ".tmux.conf"):
    print(f"Linking `{config_name}`.")
    source = dotfiles / config_name
    target = home / config_name

    # If the target exists, back it up.
    if target.exists():
        backup = target.parent / f"{config_name}.backup_{now}"
        target.rename(backup)
        print(f"Existing `{source}` backed up.")

    # Do the linking.
    target.symlink_to(source)
