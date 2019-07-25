local lgi = require 'lgi'
local gears = require 'gears'

local stream = {}
stream.__index = stream

local MODE = {
  read='read',
  wite='write',
}

local MODE_FACTORY = {
  read=function(stream)
    return lgi.Gio.DataInputStream.new(stream)
  end,
  write=function(stream)
    return lgi.Gio.DataOutputStream.new(stream)
  end,
}

stream.MODE = MODE

function stream:__call(args)
  local self = setmetatable({}, stream)
  args = args or {}
  self.mode = args.mode or MODE.read 
  self.data = MODE_FACTORY[self.mode](args.stream)
  self.closed = false
  self.mode = args.mode
  return self
end

function stream:close()
  return lgi.Gio.Async.start(gears.protected_call)(self.async_close, self)
end

function stream:async_close()
  self.data:async_close()
  self.closed = true
end

function stream:async_read(bytes)
  local buf = self.data:read_bytes(bytes or 1024)
  if buf:get_size() > 0 then
    return buf.data
  else
    self:async_close()
  end
end

function stream:async_read_line()
  local line = self.data:read_line()
  if line == nil then
    self:async_close()
  end
  return line
end

function stream:read(bytes)
  return lgi.Gio.Async.start(gears.protected_call)(self.async_read, self)
end

function stream:read_line()
  return lgi.Gio.Async.start(gears.protected_call)(self.async_read_line, self)
end

function stream:read_all()
  return lgi.Gio.Async.call(gears.protected_call)(function()
    local output = {}
    while not self.data:is_closed() do
      local data = self:async_read(1024)
      if data then table.insert(output, data) end
    end 
    return table.concat(output)
  end)
end

function stream:read_chunks(chunk_size)
  return coroutine.wrap(function()
    while not self.closed do
      coroutine.yield(self:read(chunk_size))
    end
  end)
end

function stream:read_lines()
  return coroutine.wrap(function()
    while not self.closed do
      coroutine.yield(self:read_line())
    end
  end)
end

return setmetatable({}, stream)
