# Topinambour

[![Gem Version](https://badge.fury.io/rb/topinambour.svg)](https://badge.fury.io/rb/topinambour)
[![Code Climate](https://codeclimate.com/github/cedlemo/topinambour/badges/gpa.svg)](https://codeclimate.com/github/cedlemo/topinambour)

## Introduction
Topinambour is a simple Terminal written with the **Gtk3** and **Vte3** ruby bindings from the project [Ruby-GNOME2](https://github.com/ruby-gnome2/ruby-gnome2).
**It just provides one window with one Vte terminal.**
If you need tab management, windows splitting, session management, uses [tmux](https://github.com/tmux/tmux/wiki) with it.

<a href="https://raw.github.com/cedlemo/topinambour/master/topinambour_tmux.png"><img src="https://raw.github.com/cedlemo/topinambour/master/topinambour_tmux.png" alt="Topinambour Preview"></a>

### Install

    gem install topinambour

### Launch

    topinambour
    topinambour -e "/usr/bin/glances"

## Features

*    the Gtk theme can be modified via a Css file (~/.config/topinambour/topinambour.css).
*    the current Css file can be reloaded via the app menu (Useful if you have edited it, no need to
restart topinambour.
*    terminal colors can be changed on the fly and saved.
*    terminal font can be changed on the fly and saved.
*    in the terminal, some patterns can be clicked (urls, emails, color names ...)
in order to launch the appropriate application or a related dialog window.

## Shortcuts

*    `Shift + Ctrl + q` quit Topinambour

*    `Shift + Ctrl + c` display color selectors for the vte in overlay mod (Esc to leave)

*    `Shift + Ctrl + f` display font selector for the vte in overlay mod (Esc to leave)

*    `Shift + Ctrl + Up` diminue topinambour window size to its minimum or resize to its previous height.

*    `Shift + Ctrl + PageUp` increase the opacity.

*    `Shift + Ctrl + PageDown` decrease the opacity.

## Css theming

By default, topinambour will look for the file `~/.config/topinambour/topinambour.css`. You can select another file in the preferences dialog. This dialog can be shown via the application menu.
Various widget can be themed via the Css like the headerbar for example. Here is the Css used in the first screenshot (the Gtk theme is the Arc theme).

topinambour-window
topinambour-headerbar
topinambour-term-box
topinambour-scrollbar
topinambour-terminal
topinambour-color-selector
topinambour-font-selector

```css
*{
}

#topinambour-window {
  background-color: rgba(0,0,0,0);
  border: solid 4px #282828;
  border-radius: 0px 0px 8px 8px;
}

#topinambour-headerbar {
  background-color: #282828;
  border: none;
  box-shadow: none;
}

#topinambour-headerbar:backdrop {
  background-color: rgba(50,50,50,0.7);
  border: none;
  box-shadow: none;
}

#topinambour-scrollbar {
  background-color: rgba(0,0,0,0);
  border: none;
}

#topinambour-scrollbar trough{
  background-color: rgba(0,0,0,0);
  border: none;
}

#topinambour-scrollbar slider{
  margin: 0px;
  background-color: rgba(255,255,255,0.1);
}

#topinambour-term-box {
  border: solid 4px #282828;
  border-radius: 0px 0px 8px 8px;
}
```

### Copying:

Copyright 2015-2018 Cedric Le Moigne

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

Author : cedlemo@gmx.com
