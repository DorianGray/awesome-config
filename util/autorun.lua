local awful = require 'awful'
local gears = require 'gears'
gears.matcher = require 'gears.matcher'
local process = require 'awful.io.process'

local unpack = table.unpack or unpack


local static = {}
static.__index = static
local autorun = {}
autorun.__index = autorun

function static.run_once(cmd, args, match)
  if not match then
    match = cmd
  end
  local p = process.run('pgrep -u $USER -x ' .. match)
  p:wait()
  if p.exit.code == 1 then
    process.run(table.concat({'exec', cmd, unpack(args)}, ' '))
    return true
  end
  return false
end

function autorun:new(apps)
  local self = setmetatable({}, autorun)
  self.rules = {}
  self.matcher = gears.matcher()
  awful.rules.add_rule_source('util.autorun:'..tostring(self), function(...)
    return self:apply_rules(...)
  end)
  for exe, config in pairs(apps) do
    self:run(exe, config)
  end
  return self
end

function autorun:add_rule(rule)
  table.insert(self.rules, rule)
end

function autorun:run(exe, config)
  if config.rules then
    for _, rule in pairs(config.rules) do
      self:add_rule(rule)
    end
  end
  static.run_once(exe, config.args or {}, config.match)
end

function autorun:apply_rules(c, props, callbacks)
  for _, entry in pairs(self.matcher:matching_rules(c, self.rules)) do
    if entry.properties then
      gears.table.crush(props, entry.properties)
    end
    if entry.callback then
      table.insert(callbacks, entry.callback)
    end
  end
end

return setmetatable(static, {__call=autorun.new})
