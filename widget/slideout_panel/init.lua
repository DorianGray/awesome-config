local awful = require 'awful'
local wibox = require 'wibox'
local theme = require 'theme'


return function(screen, side)
  if side == nil then side = 'right' end

  local width = screen.geometry.width * (0.1333333 * theme.scale)
  local height = screen.geometry.height - (32 * theme.scale)

  local o = {
    side = side,
    panel = wibox({
      border_width=0,
      ontop=true,
      type="dock",
      width=width,
      height=height,
      screen=screen,
      bg=theme.bg_focus,
      fg=theme.fg_normal,
      visible=false,
    })
  }

  function o:reset()
    local panel_close_layout = wibox.widget({
      layout=wibox.layout.grid,
      homogeneous=false,
      spacing=0,
      min_cols_size=2,
      min_rows_size=1,
      forced_height=self.panel.height,
    })
    local close_button = wibox.widget.textbox(
    '<span font="'..(32 * theme.scale)..'" weight="bold"> '..(o.side == 'left' and '❮' or '❯')..'</span>'
    )
    close_button:buttons(awful.button({}, 1, function()
      self:toggle_visible()
    end))
    local old_wibox, old_cursor
    close_button:connect_signal("mouse::enter", function()
      local w = mouse.current_wibox
      old_cursor, old_wibox = w.cursor, w
      w.cursor = self.side.."_side"
    end)
    close_button:connect_signal("mouse::leave", function()
      if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
      end
    end)
    close_button:set_align("center")
    close_button:set_valign("center")
    close_button.forced_height = self.panel.height
    close_button.forced_width = 32 * theme.scale
    self.panel.widget = panel_close_layout
    self.panel.widget:add_widget_at(
      wibox.container.background(close_button, theme.bg_normal),
      1,
      self.side == 'left' and 2 or 1
    )
    awful.placement['bottom_'..self.side](self.panel)
  end

  function o:toggle_visible(value)
    if value == nil then value = not self.panel.visible end
    self.panel.visible = value
  end

  function o:set_content(widget)
    self:reset()
    self.panel.widget:add_widget_at(widget, 1, self.side == 'left' and 1 or 2)
  end

  o:reset()
  return o
end
