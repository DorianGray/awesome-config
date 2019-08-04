local awesome = require 'awesome'
local awful = require 'awful'
local process = require 'awful.io.process'
local beautiful = require 'beautiful'
local icon = require 'widget.display.icon.display'(
  32 * beautiful.scale,
  32 * beautiful.scale
)
local naughty = require 'naughty'
local xrandr = require 'widget.display.xrandr'
local gears = require 'gears'


local function arrange(out)
  -- We need to enumerate all the way to combinate output. We assume
  -- we want only an horizontal layout.
  local choices  = {}
  local previous = { {} }
  for _, _ in pairs(out) do
    -- Find all permutation of length `i`: we take the permutation
    -- of length `i-1` and for each of them, we create new
    -- permutations by adding each output at the end of it if it is
    -- not already present.
    local new = {}
    for _, p in pairs(previous) do
      for o in pairs(out) do
        if not awful.util.table.hasitem(p, o) then
          table.insert(new, awful.util.table.join(p, {o}))
        end
      end
    end
    choices = awful.util.table.join(choices, new)
    previous = new
  end

  return choices
end

-- Build available choices
local function menu()
  local out = xrandr.outputs()
  local menu = {}
  local choices = arrange(out)

  for _, choice in pairs(choices) do
    local cmd = {'xrandr'}
    local last_o = 1
    local primary = nil
    -- Enabled outputs
    for i, o in pairs(choice) do
      local out_cmd = {'--output ' .. o .. ' --crtc ' .. (i - 1)}
      local insert_position = nil
      if i == 1 then
        primary = o
        table.insert(out_cmd, '--primary')
      elseif i == 2 then
        table.insert(out_cmd, '--above '..primary)
        last_o = o
      end
      --table.insert(out_cmd, '--auto')
      if insert_position then
        table.insert(cmd, insert_position, table.concat(out_cmd, ' '))
      else
        table.insert(cmd, table.concat(out_cmd, ' '))
      end
      table.insert(cmd, '--auto')
    end
    -- Disabled outputs
    for i, o in pairs(out) do
      if not awful.util.table.hasitem(choice, i) then
        table.insert(cmd, '--output ' .. i .. ' --off')
      end
    end

    local label = ''
    if #choice == 1 then
      label = 'Only ' .. choice[1]
    else
      for i, o in pairs(choice) do
        if i > 1 then label = label .. ' + ' end
        label = label .. o
      end
    end
    table.insert(menu, {
      label,
      function()
        process.run(table.concat(cmd, ' '))
        awesome.restart()
      end,
    })
  end
  return menu
end

local args = {
  image = icon(),
  menu = awful.menu({
    items = menu(),
    theme = {
      width = beautiful.menu_width,
      height = beautiful.menu_height,
    },
  }),
}
local widget = awful.widget.launcher(args)
local state = { iterator = nil, timer = nil, cid = nil }

function widget:show_tooltip()
  -- Display xrandr notifications from choices
  -- Stop any previous timer
  if state.timer then
    state.timer:stop()
    state.timer = nil
  end

  local m = menu()
  -- Build the list of choices
  if not state.iterator then
    state.iterator = awful.util.table.iterate(m, function() return true end)
  end

  -- Select one and display the appropriate notification
  local n  = state.iterator()
  local label, action, icon
  if not n then
    label, icon = 'Keep the current configuration'
    state.iterator = nil
  else
    label, action, icon = unpack(n)
  end
  state.cid = naughty.notify({
    text = label,
    icon = icon,
    timeout = 4,
    screen = mouse.screen,
    font = beautiful.font,
    replaces_id = state.cid,
  }).id

  -- Setup the timer
  state.timer = gears.timer({timeout = 4, autostart = false})
  state.timer:connect_signal('timeout', function()
    state.timer:stop()
    state.timer = nil
    state.iterator = nil
    if action then
      action()
    end
  end)
  state.timer:start()
end

widget.menu = args.menu
widget.keys = {
  awful.key({}, "F8", function() widget:show_tooltip() end),
}
return widget
