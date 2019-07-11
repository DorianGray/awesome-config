local awful = require 'awful'

local IGNORE_KEYS = {
  Shift_R = true,
  Shift_L = true,
  Super_L = true,
  Super_R = true,
  Alt_R = true,
  Alt_L = true,
  Up = true,
  Down = true,
  Left = true,
  Right = true,
}

local NEXT_INPUT_KEYS = {
  Tab = true,
}

local DEFAULT_KEYS = {
  Return = true,
}

local EXIT_KEYS = {
  Escape = true,
}

local ACTIONS = {
  next_input = function(self, o)
    local found = false
    for _, child in pairs(o:get_all_children()) do
      if found and child._accepts_input then
        o:set_active_input(child)
      end
      if child == o._active_input then
        found = true
      end
    end
    if not found then
      return self:submit(o)
    end
  end,
  exit = function(self, o)
    o:set_active_input(nil)
  end,
  ignore = function(self, o) end,
  submit = function(self, o)
    return o:submit()
  end,
}

local DEFAULT_ACTION = 'submit'


return function(o)
  local grabber = awful.keygrabber({
    autostart = false,
  })

  function grabber:keypressed_callback(mod, key, event)
    if event == 'release' then return end
    if o._active_input == nil or EXIT_KEYS[key] then
      return ACTIONS:exit(o)
    elseif IGNORE_KEYS[key] then
      return ACTIONS:ignore(o)
    elseif DEFAULT_KEYS[key] then
      return ACTIONS[DEFAULT_ACTION](ACTIONS, o)
    elseif NEXT_INPUT_KEYS[key] then
      return ACTIONS:next_input(o)
    else
      return o._active_input:keypressed_callback(mod, key, event)
    end
  end

  return grabber
end
