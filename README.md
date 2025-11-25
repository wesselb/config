# Terminal Setup

Install `zsh`, [Oh My Zsh](https://ohmyz.sh/),
and the [powerlevel10k](https://github.com/romkatv/powerlevel10k) theme.

Install [Miniforge](https://conda-forge.org/download/).

Install some helpful command-line tools:

```bash
brew install the_silver_searcher nload
brew install --cask docker 
```

Install the dotfiles:

```bash
python link.py
```

Consider setting `VIM_PYTHON3` in `~/.zshrc` to point Vim to the correct
`python3`:

```bash
export VIM_PYTHON3="$HOME/miniforge3/envs/3.12/bin/python"
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
* Import the keymap from `iterm2_keymap.itermkeymap`.
* Turn off all notifications.

## Alfred

Alfred is a better Spotlight with extended functionality.

```bash
brew install alfred
```

## Dash

Dash offers a plugin for Alfred to easily search documentation.

```bash
brew install dash
```

## Contexts

Contexts is a better window switcher.

```bash
brew install contexts
```

Suggested configuration:

* Turn off sidebar enhancement.
* Turn off `cmd+backtick` switcher to avoid interference with iTerm2.
* Rebind Spotlight to `ctrl+space`.
* Bind `cmd+space` to show the application switcher.

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

* Turn off everything except CPU and GPU, network, and the combined menu.

## Flux

Flux adjust the color temperature of your screen in the evening to reduce eye strain.

```bash
brew install flux-app
```

No suggested configuration.

## 1Password

1Password is a great password manager.

```bash
brew install 1password
```

No suggested configuration.

## QuickLook Extensions

Alternative?
