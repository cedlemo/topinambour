# Topinambour

[![Gem Version](https://badge.fury.io/rb/topinambour.svg)](https://badge.fury.io/rb/topinambour)
[![Code Climate](https://codeclimate.com/github/cedlemo/topinambour/badges/gpa.svg)](https://codeclimate.com/github/cedlemo/topinambour)

<a href="https://raw.github.com/cedlemo/topinambour/master/screenshot_color_scheme.png"><img src="https://raw.github.com/cedlemo/topinambour/master/screenshot_color_scheme.png" alt="Topinambour Preview"></a>

## Introduction
Topinambour is a Terminal written with the **Gtk3** and **Vte3** ruby bindings from the project [Ruby-GNOME2](https://github.com/ruby-gnome2/ruby-gnome2).


    gem build topinambour.gemspec
    gem install topinambour-x.x.x.gem
    ~> topinambour

*Tips:*
> Don't forget, if you install it localy, you need that your system know the path of
the ruby gem binaries (for example).

    export PATH="${PATH}:/home/${USER}/bin:${HOME}/gem/ruby/2.3.0/bin"


## Features


*    supports tabs
*    tabs can be reordered or selected through the preview mode ( `Shift + Ctrl + o` ).
*    each tab can be named.
*    the theme can be done via a Css file, there is a load button that allow to reload the Css file when needed.
*    terminal colors can be changed on the fly and saved.
*    terminal font can be changed on the fly and saved.
*    in the terminals, some patterns can be clicked (urls, emails, color names ...) in order to launch the appropriate application or a related dialog window.
*    Topinambour allows users to modify existing modules. For example if a user copy the css_editor.rb in the directory *~/.config/topinambour/lib/css_editor.rb*, he should be able to modify it in order to fit its needs.

## Shortcuts

<a href="https://raw.github.com/cedlemo/topinambour/master/screenshot_shortcuts.png"><img src="https://raw.github.com/cedlemo/topinambour/master/screenshot_shortcuts.png" alt="Topinambour Shortcuts"></a>

*    `Shift + Ctrl + t`  new tab

*    `Shift + Ctrl + q` quit Topinambour

*    `Shift + Ctrl + w` close current tab

*    `Shift + Ctrl + left` previous tab

*    `Shift + Ctrl + right` next tab

*    `Shift + Ctrl + c` display color selectors for the vte in overlay mod (Esc to leave)

*    `Shift + Ctrl + f` display font selector for the vte in overlay mod (Esc to leave)

*    `Shift + Ctrl + o` display previews of all tabs (Esc to leave)

*    `Shift + Ctrl + e` open the Css configuration editor in a new notebook tab.

*    `Shift + Ctrl + /` open for the current terminal a search entry.

*    `Shift + Ctrl + Up` diminue topinambour window size to its minimum or resize to its previous height.

*    `Shift + Ctrl + PageUp` increase the opacity.

*    `Shift + Ctrl + PageDown` decrease the opacity.

## Css theming

By default, topinambour will look for the file `~/.config/topinambour/topinambour.css`. You can select another file in the preferences dialog.
Various widget can be themed via the Css like the headerbar for example. Here is the Css used in the first screenshot (the Gtk theme is the Arc theme).

```css
*{
}

#topinambour-window, #topinambour-notebook {
  background-color: rgba(0,0,0,0);
}

#topinambour-overview-box {
  background-color: rgba(43,45,54,0.95);
  border-radius: 6px 0px 0px 6px;
  color: #B0B0B0;
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
  margin-left: 8px;
  background-color: #076678;
}

#topinambour-tab-term {
  background-color: rgb(40,40,40);
}

grid button {
  margin: 0px;
  padding: 0px;
}

grid button image {
  border: solid 3px rgba(0, 0, 0, 0.0);
  margin: 0px;
  padding: 0px;
}
```

## Old version (before 1.0.11)

<a href="https://raw.github.com/cedlemo/topinambour/master/terminal_selector_screen.gif"><img src="https://raw.github.com/cedlemo/topinambour/master/terminal_selector_screen.gif" style="width:576px;height:324px;" alt="Color selection gif"></a>

<a href="https://raw.github.com/cedlemo/topinambour/master/color_selection_screen.gif"><img src="https://raw.github.com/cedlemo/topinambour/master/color_selection_screen.gif" style="width:576px;height:324px;" alt="Color selection gif"></a>

<a href="https://raw.github.com/cedlemo/topinambour/master/terminal_regex_color.gif"><img src="https://raw.github.com/cedlemo/topinambour/master/terminal_regex_color.gif" style="width:576px;height:324px;" alt="Regex color gif"></a>



###  TODO:
*   Name all the important widgets so that they can be easily themed in Css.
    *    `#topinambour-overview-box`
    *    `#topinambour-headerbar`
    *    `#topinambour-window`
    *    `#topinambour-scrollbar`
    *    `#topinambour-notebook`

*   Write a description of the widgets that have a Css name/Id.
*   Improve the Css editor with a part for the Css parsing error when the user writes. Add a color chooser widget in the related tab.
*   Make Topinambour allows users to easily create their own modules. For example create a tab that will act as a MPD client. There will be widgets that control a MPD server and a GtkTree widget that displays the playlist of the MPD server for example.


### User configuration

It can be found in the file `$HOME/.config/topinambour/topinambour.css` (Be carefull by default Topinambour use fish as a default shell, if you want to use another one specify it in the topinambour.css file)

```css
*{
/* Default css properties
  -TopinambourTerminal-foreground: #aeafad;
  -TopinambourTerminal-background: #323232;
  -TopinambourTerminal-black: #000000;
  -TopinambourTerminal-red: #b9214f;
  -TopinambourTerminal-green: #A6E22E;
  -TopinambourTerminal-yellow: #ff9800;
  -TopinambourTerminal-blue: #3399ff;
  -TopinambourTerminal-magenta: #8e33ff;
  -TopinambourTerminal-cyan: #06a2dc;
  -TopinambourTerminal-white: #B0B0B0;
  -TopinambourTerminal-brightblack: #5D5D5D;
  -TopinambourTerminal-brightred: #ff5c8d;
  -TopinambourTerminal-brightgreen: #CDEE69;
  -TopinambourTerminal-brightyellow: #ffff00;
  -TopinambourTerminal-brightblue: #9CD9F0;
  -TopinambourTerminal-brightmagenta: #FBB1F9;
  -TopinambourTerminal-brightcyan: #77DFD8;
  -TopinambourTerminal-brightwhite: #F7F7F7;
  -TopinambourTerminal-font: Monospace 11;
  -TopinambourWindow-shell: "/usr/bin/fish";
  -TopinambourWindow-css-editor-style: "monokai-extended";
  -TopinambourWindow-height: 500;
  -TopinambourWindow-width: 1000;*/
}

TopinambourWindow headerbar entry{
  /*border-radius: 4px;*/
}

#topinambour-overview-box {
  background-color: rgba(0,0,0,0.2);
  border: solid 1px rgba(49, 150, 188, 1);
  border-radius: 6px 0px 0px 6px;
}

#topinambour-headerbar {
  background-color: #323232;
  border: none;
  box-shadow: none;
}
#topinambour_headerbar:backdrop {
  background-color: rgba(50,50,50,0.7);
  border: none;
  box-shadow: none;
}
grid button {
  margin: 0px;
  padding: 0px;

}

grid button image {
  border: solid 3px rgba(0, 0, 0, 0.0);
  margin: 0px;
  padding: 0px;
}
```

Each time you modify this configuration via the interface of Topinambour (terminal colors selector, terminal font selector, css editor) and that you save your modifications, Topinambour create a copy of your previous Css file under a new name with :

    FileUtils.mv(USR_CSS, "#{USR_CSS}_#{Time.new.strftime('%Y-%m-%d-%H-%M-%S')}.backup")

Which means that the old file can be something like that : *topinambour.css_2016-12-5-13-20.backup*.

## Installation

### Dependencies

*   gtk3 vte3 sass

### Create the gem if needed:

    gem build topinambour.gemspec

### Install the gem :

    gem install topinambour-x.x.x.gem

### Launch the terminal

    ~> topinambour

#### Tips:

Don't forget, if you install it localy, you need that your system know the path of
the ruby gem binaries (for example).

    export PATH="${PATH}:/home/${USER}/bin:${HOME}/gem/ruby/2.3.0/bin"

#### Modifying or testing Topinambour is easy:

##### Get the sources

    git clone https://github.com/cedlemo/topinambour.git
    cd topinambour/bin

##### Edit the files Topinambour and test
  The filenames correspond to their functionnalities.
  Simply run `./topinambour` when you have done your modifications.

You will need fish shell if you want to test it.

### Copying:

Copyright 2015-2016 Cedric Le Moigne

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

Author : cedlemo@gmx.com
