local lgi = require 'lgi'
local stream = require 'awful.aio.stream'
local gears = require 'gears'
local awful = require 'awful'

local unpack = unpack or table.unpack


local process = {}
process.__index = process

function process:__call(args)
  local self = setmetatable({}, process)
  if type(args) == 'string' then
    args = {command=args}
  end
  self.args = args.args or {}
  self.command = args.command
  self.shell = args.shell
  self.started = false
  return self
end

function process.run(command)
  local p = process.__call(process, {
    shell=awful.util.shell,
    command=command,
  })
  p:start()
  return p
end

function process:start()
  if self.started then
    return
  end
  local command = {self.command, unpack(self.args)}
  if self.shell then
    command = {self.shell, '-c', unpack(command)}
  end
  local pid, snid, stdin, stdout, stderr = awesome.spawn(
    command,
    true,
    true,
    true,
    true,
    function(exit_type, code) self:exit_callback(exit_type, code) end,
    self.env
  )
  if type(pid) == 'string' then
    error(pid)
  end
  self.started = true
  self.exit = nil
  self.pid = pid
  self.snid = snid
  self.stdin = stream({mode='write', stream=lgi.Gio.UnixOutputStream.new(stdin, true)})
  self.stdout = stream({stream=lgi.Gio.UnixInputStream.new(stdout, true)})
  self.stderr = stream({stream=lgi.Gio.UnixInputStream.new(stderr, true)})
end

function process:stop()

end

function process:signal()

end

function process:wait()
  while self.started do
    lgi.Gio.Async.call(gears.protected_call)(function() end)
  end
  return self.exit
end

function process:exit_callback(exit_type, code)
  self.started = false
  self.exit = {
    type = exit_type,
    code = code,
  }
end

return setmetatable({}, process)
