local lgi = require 'lgi'
local stream = require 'awful.io.stream'

local setmetatable = setmetatable


local static = {}
local file = {}
file.__index = file

function file:new(path)
  local self = setmetatable({}, file)
  self.path = path
  self.file = lgi.Gio.File.new_for_path(path)
  if not self.file:query_exists() then
    return nil
  end
  self.reader = stream({stream = self.file:read()})
  return self
end

function file:read_lines()
  return self.reader:read_lines()
end

function file:read_all()
  return self.reader:read_all()
end

return setmetatable(static, {__call=file.new})
