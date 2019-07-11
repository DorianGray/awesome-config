local awful = require 'awful'
local theme = require 'theme'

-- Autostart applications
local function run_once(cmd, match)
  if not match then
    match = cmd
    local firstspace = cmd:find(' ')
    if firstspace then
      match = cmd:sub(0, firstspace-1)
    end
  end
  awful.spawn.with_shell(
    '! pgrep -u $USER -x ' .. match .. ' > /dev/null && ' .. cmd
  )
end

local autorunApps = { 
  ['google-chrome-stable'] = {cmd=table.concat({
    '--process-per-site',
    '--high-dpi-support=1',
    '--force-device-scale-factor=2',
    '--touch-events=enabled',
    '--enable-native-gpu-memory-buffers',
    '--enable-zero-copy',
  }, ' '), match='chrome'},
  ['alacritty'] = {cmd=table.concat({
    '-t Terminal',
    '-e '..os.getenv('HOME')..'/.config/awesome/tmux-session.sh awesome',
  }, ' ')},
  ['udiskie'] = {},
  ['discord'] = {match='Discord'},
  ['pulseaudio'] = {cmd='-D'},
  ['unclutter'] = {cmd='-root'},
  ['xautolock'] = {cmd=table.concat({
    '-time 5',
    '-detectsleep',
    '-locker /usr/local/bin/xautolocker',
  }, ' ')},
}
for app, config in pairs(autorunApps) do
  run_once(app..(config.cmd and ' '..config.cmd or ''), config.match)
end
