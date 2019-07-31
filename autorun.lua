local awful = require 'awful'
local gears = require 'gears'
local process = require 'awful.io.process'


-- Autostart applications
local function run_once(cmd, match)
  if not match then
    match = cmd
    local firstspace = cmd:find(' ')
    if firstspace then
      match = cmd:sub(0, firstspace-1)
    end
  end
  local p = process.run('pgrep -u $USER -x ' .. match)
  p:wait()
  if p.exit.code == 1 then
    process.run('exec '..cmd)
  end
end

return function(autorun) 
  local rules = {}
  for app, config in pairs(autorun) do
    run_once(app..(config.cmd and ' '..config.cmd or ''), config.match)
    if config.rules then
      table.insert(rules, config.rules)
    end
  end
  awful.rules.rules = gears.table.join(awful.rules.rules, unpack(rules))
end
