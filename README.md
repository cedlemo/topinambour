# Topinambour

[![Gem Version](https://badge.fury.io/rb/topinambour.svg)](https://badge.fury.io/rb/topinambour)
[![Code Climate](https://codeclimate.com/github/cedlemo/topinambour/badges/gpa.svg)](https://codeclimate.com/github/cedlemo/topinambour)


<a href="https://raw.github.com/cedlemo/topinambour/master/terminal_selector_screen.gif"><img src="https://raw.github.com/cedlemo/topinambour/master/terminal_selector_screen.gif" style="width:576px;height:324px;" alt="Color selection gif"></a>

<a href="https://raw.github.com/cedlemo/topinambour/master/color_selection_screen.gif"><img src="https://raw.github.com/cedlemo/topinambour/master/color_selection_screen.gif" style="width:576px;height:324px;" alt="Color selection gif"></a>

<a href="https://raw.github.com/cedlemo/topinambour/master/terminal_regex_color.gif"><img src="https://raw.github.com/cedlemo/topinambour/master/terminal_regex_color.gif" style="width:576px;height:324px;" alt="Regex color gif"></a>


Topinambour is Terminal written with the Gtk3 and Vte3 ruby bindings from the project [Ruby-GNOME2](https://github.com/ruby-gnome2/ruby-gnome2). I have written it for testing purpose, but Topinambour works well and I use it as my primary terminal emulator.

## Features

*    Tabs supports
*    Tabs can be reordered or selected through the preview mode ( `Shift + Ctrl + o` ).
*    Each tab can be named.
*    The configuration can be done via a Css file.
*    Terminal colors can be changed on the fly and saved in the CSS configuration file.
*    Terminal font can be changed on the fly and saved in the CSS configuration file.
*    The Css file can be edited in a tab of Topinambour and saved. Each modifications are applied while you are writting them. (Use `Shift + Ctrl + w` to close the editor)
*    In the terminals, some patterns can be clicked (urls, emails, color names ...) in order to launch the appropriate application or a related dialog window.
*    Topinambour allows users to modify existing modules. For example if a user copy the css_editor.rb in the directory *~/.config/topinambour/lib/css_editor.rb*, he should be able to modify it in order to fit its needs. 

##  TODO:
*   Create more Css properties in order to configure the terminals (cursor shape or blink mode, audible bell or not ...)
*   Finish preferences window.
*   Name all the important widget so that they can be easily themed in Css.
*   Write a description of the widgets that have a Css name/Id.
*   Improve the Css editor with a part for the Css parsing error when the user writes. Add a color chooser widget in the related tab.
*   Make Topinambour allows users to easily create their own modules. For example create a tab that will act as a MPD client. There will be widgets that control a MPD server and a GtkTree widget that displays the playlist of the MPD server for example.

## Shortcuts

*    `Shift + Ctrl + t`  new tab
    
*    `Shift + Ctrl + q` quit Topinambour
    
*    `Shift + Ctrl + w` close current tab
    
*    `Shift + Ctrl + left` previous tab
    
*    `Shift + Ctrl + right` next tab
    
*    `Shift + Ctrl + c` display color selectors for the vte in overlay mod (Esc to leave)
     
*    `Shift + Ctrl + f` display font selector for the vte in overlay mod (Esc to leave)
    
*    `Shift + Ctrl + o` display previews of all tabs (Esc to leave)

*    `Shift + Ctrl + e` open the Css configuration editor in a new notebook tab.


## User configuration

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
  border-radius: 4px;
}

#OverviewBox {
  background-color: rgba(0,0,0,0.2);
  border: solid 1px rgba(49, 150, 188, 1);
  border-radius: 6px 0px 0px 6px;
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

### Dependancies

*   gtk3 vte3 sass

### Create the gem if needed:

    gem build topinambour.gemspec

### Install the gem :

    gem install topinambour-x.x.x.gem

### Launch the terminal

    ~> topinambour 

### Tips:

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
