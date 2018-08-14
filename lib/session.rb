class Session
  attr_accessor :terminal_options,
                :vte_options
  def initialize(terminal_options, vte_options)
    @terminal_options = terminal_options
    @vte_options = vte_options
  end
end

TerminalOptions = Struct.new(:colorscheme,
                             :default_scheme,
                             :font,
                             :width,
                             :height,
                             :custom_css,
                             :css_file)

VteOptions = Struct.new(:allow_bold,
                        :audible_bell,
                        :scroll_on_output,
                        :scroll_on_keystroke,
                        :rewrap_on_resize,
                        :mouse_autohide,
                        :cursor_shape,
                        :cursor_blink_mode,
                        :backspace_binding,
                        :delete_binding)
