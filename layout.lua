local wibox = require 'wibox'
local beautiful = require 'beautiful'
local awful = require 'awful'
local lain = require 'lain'

return function(widgets, icons, boxes, taglist)
  -- Wibox
  local separators = lain.util.separators
  -- Separators
  local spr = wibox.widget.textbox(' ')
  local arrl = wibox.widget.imagebox()
  arrl:set_image(beautiful.arrl)
  local arrl_dl = separators.arrow_left(beautiful.bg_focus, 'alpha')
  local arrl_ld = separators.arrow_left('alpha', beautiful.bg_focus)

  -- Create a wibox for each screen and add it
  taglist.buttons = awful.util.table.join(
  awful.button({ }, 1, awful.tag.viewonly),
  awful.button({ 'Mod4' }, 1, awful.client.movetotag),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ 'Mod4' }, 3, awful.client.toggletag),
  awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
  awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
  )

  local tasklists = {}
  tasklists.buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following
      -- :isvisible() makes no sense
      c.minimized = false
      if not c:isvisible() then
        awful.tag.viewonly(c:tags()[1])
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
      instance = awful.menu.clients({ width=250 })
    end
  end),
  awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end),
  awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end))

  for s = 1, screen.count() do

    -- Create a promptbox for each screen
    boxes.prompt[s] = awful.widget.prompt()

    -- We need one layoutbox per screen.
    boxes.layout[s] = awful.widget.layoutbox(s)
    boxes.layout[s]:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)

    -- Create a tasklist widget
    tasklists[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklists.buttons)

    -- Create the wibox
    boxes.wi[s] = awful.wibox({ position = 'top', screen = s, height = 18 })

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(boxes.layout[s])
    left_layout:add(spr)
    left_layout:add(taglist[s])
    left_layout:add(boxes.prompt[s])
    left_layout:add(spr)


    -- Widgets that are aligned to the upper right
    local right_layout = wibox.layout.fixed.horizontal()
    local right_layout_toggle = true
    local function right_layout_add (...)
      local arg = {...}
      if right_layout_toggle then
        right_layout:add(arrl_ld)
        for i, n in pairs(arg) do
          right_layout:add(wibox.widget.background(n ,beautiful.bg_focus))
        end
      else
        right_layout:add(arrl_dl)
        for i, n in pairs(arg) do
          right_layout:add(n)
        end
      end
      right_layout_toggle = not right_layout_toggle
    end

    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(spr)
    right_layout:add(arrl)
    right_layout_add(icons.volume, widgets.volume)
    right_layout_add(icons.memory, widgets.memory, icons.cpu, widgets.cpu)
    right_layout_add(icons.battery, widgets.battery)
    right_layout_add(widgets.network)
    right_layout_add(widgets.clock, spr)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(tasklists[s])
    layout:set_right(right_layout)
    boxes.wi[s]:set_widget(layout)
  end
end
