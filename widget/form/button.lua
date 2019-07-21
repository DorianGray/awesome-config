local wibox = require 'wibox'
local gears = require 'gears'
local awful = require 'awful'
local beautiful = require 'beautiful'

local cursor_character = '█'

return function(form, text)
  text = text == nil and '' or text
  local t = wibox.widget.textbox(default)
  t._accepts_input = true
  local c = wibox.container.background(
    t,
    beautiful.bg_normal,
    function(cr, width, height)
      return gears.shape.rounded_rect(cr, width, height, 4)
    end
  )
  c.fg = beautiful.fg_normal
  c.shape_border_color = beautiful.fg_urgent
  c.shape_border_width = 1 * beautiful.scale
  c.shape_clip = 0
  c.forced_width = 250
  c.forced_height = 40
  c:buttons(awful.button({}, 1, function()
    form:set_active_input(t)
  end))

  local cursor_set = false
  local cursor_timer

  local function active_text()
    if cursor_set then
      return text 
    else
      return text .. cursor_character
    end
  end

  cursor_timer = gears.timer({
    timeout = 0.8,
    call_now = false,
    callback = function()
      cursor_set = not cursor_set
      t.text = active_text()
      cursor_timer:again()
    end,
  })


  local old_wibox, old_cursor
  c:connect_signal("mouse::enter", function()
    local w = mouse.current_wibox
    old_cursor, old_wibox = w.cursor, w
    w.cursor = "xterm"
  end)
  c:connect_signal("mouse::leave", function()
    if old_wibox then
      old_wibox.cursor = old_cursor
      old_wibox = nil
    end
  end)

  function t:keypressed_callback(mod, key, event)
    if key == 'BackSpace' then
      text = text:sub(1, -2)
    else
      text = text .. key
    end
    self.text = active_text()
  end

  function t:activate() 
    cursor_set = false
    self.text = active_text()
    if not cursor_timer.started then
      cursor_timer:start()
    end
  end

  function t:deactivate()
    cursor_set = true
    self.text = active_text()
    if cursor_timer.started then
      cursor_timer:stop()
    end
  end

  return c
end
