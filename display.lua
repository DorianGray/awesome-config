local awesome = require 'awesome'
local awful = require 'awful'
local naughty = require 'naughty'
local xrandr = require 'xrandr'
local gears = require 'gears'
local beautiful = require 'beautiful'


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
local function menu(cb)
  xrandr.outputs(function(out)
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
        label = 'Only <span weight="bold">' .. choice[1] .. '</span>'
      else
        for i, o in pairs(choice) do
          if i > 1 then label = label .. ' + ' end
          label = label .. '<span weight="bold">' .. o .. '</span>'
        end
      end
      table.insert(menu, {
        label,
        table.concat(cmd, ' '),
      })
    end
    return cb(menu)
  end)
end

-- Display xrandr notifications from choices
local state = { iterator = nil, timer = nil, cid = nil }

return function()
  -- Stop any previous timer
  if state.timer then
    state.timer:stop()
    state.timer = nil
  end

  menu(function(m)
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
      screen = mouse.screen.index, -- Important, not all screens may be visible
      font = beautiful.font,
      replaces_id = state.cid,
    }).id

    -- Setup the timer
    state.timer = gears.timer({timeout = 4})
    state.timer:connect_signal('timeout', function()
      state.timer:stop()
      state.timer = nil
      state.iterator = nil
      if action then
        awful.spawn.easy_async(action, function()
          awesome.restart()
        end)
      end
    end)
    state.timer:start()
  end)
end
