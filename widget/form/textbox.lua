local wibox = require 'wibox'
local gears = require 'gears'
local awful = require 'awful'
local beautiful = require 'beautiful'

local CURSOR_CHARACTER = '█'
local PASSWORD_CHARACTER = '•'

return function(form, name, default)
  default = default == nil and '' or default
  form._data[name] = default
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
  c.shape_border_color = beautiful.fg_focus
  c.shape_border_width = 1 * beautiful.scale
  c.shape_clip = 0
  c.forced_width = 250
  c.forced_height = 40
  c.type = 'default'
  c:buttons(awful.button({}, 1, function()
    form:set_active_input(t)
  end))

  local cursor_set = false
  local cursor_timer

  local function active_text()
    local text = form._data[name]
    if c.type == 'password' then
      text = string.rep(PASSWORD_CHARACTER, #text)
    end
    if cursor_set then
      return text 
    else
      return text .. CURSOR_CHARACTER
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
    local text = form._data[name]
    if key == 'BackSpace' then
      text = text:sub(1, -2)
    else
      text = text .. key
    end
    form._data[name] = text
    self.text = active_text()
  end

  function t:activate() 
    c.shape_border_color = beautiful.fg_urgent
    cursor_set = false
    self.text = active_text()
    if not cursor_timer.started then
      cursor_timer:start()
    end
  end

  function t:deactivate()
    c.shape_border_color = beautiful.fg_focus
    cursor_set = true
    self.text = active_text()
    if cursor_timer.started then
      cursor_timer:stop()
    end
  end

  return c
end
