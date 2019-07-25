local wibox = require 'wibox'
local beautiful = require 'beautiful'
local awful = require 'awful'
local separator = require 'widget.separator'
local screen = require 'screen'
local form = require 'widget.form'
local form_textbox = require 'widget.form.textbox'
local slideout_panel = require 'widget.slideout_panel'
local client = require 'client'


return function(widgets, boxes)
  -- Wibox
  -- Separators
  local spr = wibox.widget.textbox(' ')
  local arrl_dl = separator.arrow_left(beautiful.bg_focus, 'alpha')
  local arrl_ld = separator.arrow_left('alpha', beautiful.bg_focus)

  local tasklists = {}
  local instance = nil
  tasklists.buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following
      -- :isvisible() makes no sense
      c.minimized = false
      if not c:isvisible() then
        c:tags()[1]:view_only()
      end
      -- This will also un-minimize
      -- the client, if needed
      client.focus = c
      c:raise()
    end
  end),
  awful.button({ }, 3, function ()
    if instance then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({width=250 * beautiful.scale})
    end
  end),
  awful.button({}, 4, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end),
  awful.button({}, 5, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end))

  for s in screen do
    -- Create a promptbox for each screen
    boxes.prompt[s] = awful.widget.prompt()

    -- Create a tasklist widget
    tasklists[s] = awful.widget.tasklist({
      screen = s,
      filter = awful.widget.tasklist.filter.currenttags,
      buttons = tasklists.buttons,
    })

    -- Create the wibox
    boxes.wi[s] = awful.wibar({
      position = 'top',
      screen = s,
      height = 32 * beautiful.scale,
    })

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(widgets.layout(s))
    left_layout:add(widgets.tags:widget(s))
    left_layout:add(boxes.prompt[s])

    -- Widgets that are aligned to the upper right
    local right_layout = wibox.layout.fixed.horizontal()
    local right_layout_toggle = true
    local function right_layout_add(...)
      local arg = {...}
      if right_layout_toggle then
        right_layout:add(arrl_ld)
        for _, n in pairs(arg) do
          right_layout:add(wibox.container.background(
            n ,
            beautiful.bg_focus
          ))
        end
      else
        right_layout:add(arrl_dl)
        for _, n in pairs(arg) do
          right_layout:add(n)
        end
      end
      right_layout_toggle = not right_layout_toggle
    end

    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout_add(widgets.display)
    right_layout_add(widgets.volume)
    right_layout_add(widgets.network)
    right_layout_add(widgets.battery)
    right_layout_add(widgets.clock)
    right_layout_add(widgets.power)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(tasklists[s])
    layout:set_right(right_layout)
    boxes.wi[s]:set_widget(layout)
    s.right_panel = slideout_panel(s, 'right')
  end
end
