local awesome = require 'awesome'
local awful = require 'awful'
local naughty = require 'naughty'
local xrandr = require 'xrandr'
local theme = require 'theme'


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
          new[#new + 1] = awful.util.table.join(p, {o})
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
  local menu = {}
  local out = xrandr.outputs()
  local choices = arrange(out)

  for _, choice in pairs(choices) do
    local cmd_t = {'xrandr'}
    local last_o = 1
    local primary = nil
    -- Enabled outputs
    for i, o in pairs(choice) do
      local cmd = "--output " .. o .. " --crtc " .. (i - 1)
      local insert_position = nil
      if i == 1 then
        primary = o
        cmd = cmd .. " --primary --pos 2880x0"
      elseif i == 2 then
        cmd = cmd .. " --pos 0x0 --scale 1.5x1.5"
        insert_position = 2
      elseif i > 2 then
        cmd = cmd .. " --pos 6720x0 --scale 1.5x1.5"
        last_o = o
      end
      cmd = cmd .. ' --auto'
      if insert_position then
        table.insert(cmd_t, insert_position, cmd)
      else
        table.insert(cmd_t, cmd)
      end
    end
    -- Disabled outputs
    for o in pairs(out) do
      if not awful.util.table.hasitem(choice, o) then
        table.insert(cmd_t, " --output " .. o .. " --off")
      end
    end

    local label = ""
    if #choice == 1 then
      label = 'Only <span weight="bold">' .. choice[1] .. '</span>'
    else
      for i, o in pairs(choice) do
        if i > 1 then label = label .. " + " end
        label = label .. '<span weight="bold">' .. o .. '</span>'
      end
    end
    --[[naughty.notify({ preset = naughty.config.presets.critical,
                     title = "lol",
                     text = table.concat(cmd_t, ' ') })]]
    menu[#menu + 1] = { label,
    table.concat(cmd_t, ' '),
    "/usr/share/icons/Tango/32x32/devices/display.png"}
  end
  return menu
end

-- Display xrandr notifications from choices
local state = { iterator = nil,
timer = nil,
cid = nil }
local function xrandr()
  -- Stop any previous timer
  if state.timer then
    state.timer:stop()
    state.timer = nil
  end

  -- Build the list of choices
  if not state.iterator then
    state.iterator = awful.util.table.iterate(menu(),
    function() return true end)
  end

  -- Select one and display the appropriate notification
  local n  = state.iterator()
  local label, action, icon
  if not n then
    label, icon = "Keep the current configuration", "/usr/share/icons/Tango/32x32/devices/display.png"
    state.iterator = nil
  else
    label, action, icon = unpack(n)
  end
  state.cid = naughty.notify({ text = label,
  icon = icon,
  timeout = 4,
  screen = mouse.screen.index, -- Important, not all screens may be visible
  font = theme.font,
  replaces_id = state.cid }).id

  -- Setup the timer
  state.timer = timer { timeout = 4 }
  state.timer:connect_signal("timeout",
  function()
    state.timer:stop()
    state.timer = nil
    state.iterator = nil
    if action then
      awful.spawn(action)
      awesome.restart()
    end
  end)
  state.timer:start()
end

return xrandr
