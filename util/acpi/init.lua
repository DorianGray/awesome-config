local socket = require "socket"
local unix = require "socket.unix"

return function(file)
  local o = {}

  local s = assert(socket.unix())
  assert(s:connect(file or "/run/acpid.socket"))
  s:settimeout(0)

  local handlers = {}

  local function processEvents(events)
    for _, event in ipairs(events) do
      local class, device, paramstr = event:match('(%S*) (%S*) (.*)')
      local params = {}
      for w in paramstr:gmatch("%S+") do params[#params+1] = w end
      if class then
        local subclass
        local method = handlers[class]
        if class:find('/') then
          class, subclass = class:match('(.*)/(.*)')
          if method and handlers[class] then
            local oldfn = method
            method = function(class, subclass, device, ...)
              oldfn(class, subclass, device, ...)
              handlers[class](class, subclass, device, ...)
            end
          else
            method = method or handlers[class]
          end
        end

        if handlers['*'] then
          if method then
            local oldfn = method
            method = function(class, subclass, device, ...)
              oldfn(class, subclass, device, ...)
              handlers['*'](class, subclass, device, ...)
            end
          else
            method = handlers['*']
          end
        end
        if method then method(class, subclass, device, unpack(params)) end
      end
    end
  end

  function o.register(class, fn)
    if handlers[class] then
      local oldfn = handlers[class]
      handlers[class] = function(class, subclass, device, id, message)
        fn(class, subclass, device, id, message)
        oldfn(class, subclass, device, id, message)
      end
    else
      handlers[class] = fn
    end
  end

  function o.events()
    local l, err = "", nil
    local events = {}
    while l do
      l, err = s:receive("*l")
      if not l then
        if err ~= "timeout" then
          return nil, err
        end
      else
        events[#events+1] = l
      end
    end
    return processEvents(events)
  end

  return o
end
