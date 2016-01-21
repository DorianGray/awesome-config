local awful = require 'awful'

-- Autostart applications
local function run_once(cmd, match)
  if not match then
    match = cmd
    local firstspace = cmd:find(' ')
    if firstspace then
      match = cmd:sub(0, firstspace-1)
    end
  end
  awful.spawn.with_shell('pgrep -u $USER -x ' .. match .. ' > /dev/null || (' .. cmd .. ')')
end

local autorunApps = { 
  ['google-chrome'] = {cmd='--process-per-site', match='chrome'},
  ['urxvtcd'] = {cmd=table.concat({
    '-loginShell',
    '-bc',
    '-title Terminal',
    '-depth 32',
    '-sl 32767',
    '-fn "xft:Inconsolata\\ for\\ Powerline:pixelsize=16:Bold"',
    '-e '..os.getenv('HOME')..'/.config/awesome/tmux-session.sh awesome',
  }, ' '), match='tmux'},
  ['pulseaudio'] = {cmd='-D'},
  ['unclutter'] = {cmd='-root'},
  ['udiskie'] = {},
}
for app, config in pairs(autorunApps) do
  run_once(app..(config.cmd and ' '..config.cmd or ''), config.match)
end
