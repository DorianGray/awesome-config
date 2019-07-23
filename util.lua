local lgi = require 'lgi'
local awesome = require 'awesome'
local awful = require 'awful'
awful.util = require 'awful.util'
local gears = require 'gears'


local function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

local function read_lines(st)
  local stream = lgi.Gio.DataInputStream.new(st)
  local output = {}
  while not stream:is_closed() do
    local line, len = stream:async_read_line()
    if line then
      table.insert(output, line)
    else
      stream:async_close()
    end
  end
  return table.concat(output, '\n')
end

local function read_bytes(st, buffer_size)
  if not buffer_size then
    buffer_size = 1024
  end
  local output = {}
  while not st:is_closed() do
    local buf = st:async_read_bytes(1024)
    if buf:get_size() > 0 then
      table.insert(output, buf.data)
    else
      st:async_close()
    end
  end
  return table.concat(output)
end

local function read_file_stream(f)
  return read_bytes(f:async_read())
end

local function read_unix_stream(f, use_bytes)
  return read_bytes(lgi.Gio.UnixInputStream.new(f, true))
end

local function read_file(file)
  local f = lgi.Gio.File.new_for_path(file)
  if not f:query_exists() then
    return nil
  end
  return lgi.Gio.Async.call(gears.protected_call)(read_file_stream, f)
end

local function run(command, shell)
  if not shell then
    shell = false
  elseif shell == true then
    shell = awful.util.shell
  end
  local pid, _, stdin, stdout, stderr = awesome.spawn(
    shell and {shell, '-c', command} or command,
    false,
    false,
    true
  )

  if type(pid) == "string" then
    return pid
  end

  return lgi.Gio.Async.call(gears.protected_call)(read_unix_stream, stdout)
end

local function table_values(t)
  local values = {}
  for _, v in pairs(t) do
    table.insert(values, v)
  end
  return values
end

return {
  script_path = script_path,
  run = run,
  read_file = read_file,
  table = {
    values = table_values,
  },
}
