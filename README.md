# Terminal Setup on macOS

Use `uv` to manage Python:

```bash
brew install uv
uv python install 3.12 --default
uv python update-shell
```

`uv` can also install tools system-wide:

```bash
uv tool install ruff
uv tool install pipx
```

`zsh` with `starship` gives a very decent defaults:

```bash
brew install starship
brew install zsh-autosuggestions zsh-syntax-highlighting
brew install --cask font-jetbrains-mono-nerd-font
```

The following are useful command-line tools:

```bash
brew install the_silver_searcher nload
brew install --cask docker 
```

Install the dotfiles:

```bash
python link.py
```

# Helpful macOS Applications

The following applications are helpful.
These applications work great out-of-the-box. 
Minimal additional configuration is required.

## iTerm2

iTerm2 is a better terminal application with a dedicated hotkey window.

```bash
brew install iterm2
```

Suggested configuration:

* Use Solarized Light as the theme.
* Set `cmd+backtick` to show and hide iTerm2 globally.
* Set `opt+backtick` to show and hide the dedicated hotkey window.
* For every profile, use `Keys > Key Bindings > Presets > Natural Text Editing`.
* For every profile, select a Nerd Front.
* You might want to tweak your shortcuts for opening panes and moving between tabs and panes.

## Alfred

Alfred is a better Spotlight with extended functionality.

```bash
brew install alfred
```

Suggested configuration:

* Bind `cmd+space` to show Alfred.
* You might want to install the currency conversion workflow.

## Dash

Dash offers a plugin for Alfred to easily search documentation.

```bash
brew install dash
```

## Contexts

Contexts is a better `cmd+tab`.

```bash
brew install contexts
```

Suggested configuration:

* Turn off sidebar enhancement.
* Turn off `cmd+backtick` switcher to avoid interference with iTerm2.

## Moom

Moom resizes and positions window for you.

```bash
brew install moom
```

Suggested configuration:

* Enable snapping with little or no delay.
* Bind `opt+space` to enable the keyboard control.

## BetterTouchTool

BetterTouchTool (BTT) can be used to create new application-specific shortcuts.

```bash
brew install bettertouchtool
```

Suggested configuration:

* Turn off window snapping.


## Karabiner Elements

Karabiner Elements can be used to remap keys.

```bash
brew install karabiner-elements
```

## iStatMenus

iStatMenus provides handy icons in the top bar that help you monitor your Mac.

```bash
brew install istat-menus
```

Suggested configuration:

* Turn off everything except the combined menu.

## 1Password

1Password is a great password manager.

```bash
brew install 1password
```
