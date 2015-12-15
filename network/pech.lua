local wibox = require 'wibox'
local m
local awful = require 'awful'
local naughty = require 'naughty'
local beautiful = require 'beautiful'
local string = require 'string'
local table = require 'table'
local asyncshell = require 'lain.asyncshell'
local DIR = require 'pl.path'.dirname(debug.getinfo(1,'S').source:sub(2))

local COMMAND_LIST_IFACE_STATES = 'nmcli device'
local COMMAND_LIST_WIFIS = 'nmcli --fields SECURITY,SSID,SIGNAL,IN-USE device wifi'
local COMMAND_WIFI_CONNECT = DIR..'/connect-wrapper'
local COMMAND_IFACE = DIR..'/iface-wrapper'
local DIR = require 'pl.path'.dirname(debug.getinfo(1,'S').source:sub(2))

local COMMAND_CHECK_WIFILIST_EXISTS = ''
local COMMAND_CAT_GPG_CIPHERTEXT = ''
local COMMAND_DECIPHER_GPG_NETPASSWDS = ''


local o = {connected=false, signal=0, ssid=''}

local function run(cmd)
  local p = io.popen(cmd)
  local data = p:read('*a')
  p:close()
  return data
end

local function run_async(command, callback)
  return asyncshell.request(command, callback)
end

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function parse_command(input)
  local sep = '\n'
  local t = {};
  local first = true
  local keys = {}
  for str in string.gmatch(input, '([^'..sep..']+)') do
    if first then
      first = false
      local start, finish = str:find('[%S]+', finish)
      local _, finish = str:find('%s+', finish)
      while start do
        keys[#keys+1] = {start, finish}
        start, finish = str:find('[%S]+', finish)
        _, finish = str:find('%s+', finish)
      end
    end

    local result = {}
    for _, key in pairs(keys) do
      result[#result+1] = trim(str:sub(unpack(key)))
    end
    t[#t+1] = result
  end
  return t
end

--Make a table of the local interfaces
function o.get_local_interfaces()
  return parse_command(run(COMMAND_LIST_IFACE_STATES))
end

--make a table of the scanned wifis
function o.get_area_wifi()
  return parse_command(run(COMMAND_LIST_WIFIS))
end

local function generate_line(lengths, fields, lt, skip_replace)
  local line = {}
  for i, len in ipairs(lengths) do
    local v = lt[i]
    if not skip_replace and type(fields[i]) == 'function' then
      v = fields[i](v)
    end
    if len then
      if len < 0 then
        line[#line+1] = v
      elseif #v > len then
        line[#line+1] = v:sub(1, len-3)..'...'..(' '):rep(3)
      else
        line[#line+1] = v..(" "):rep(len+3-#v)
      end
    end
  end
  return table.concat(line)
end

local function generate_wifi_line(lt, skip_replace)
  local line = {}
  local lengths = {
    -1,
    -1,
    false,
    false,
  }
  local fields = {
    function(v)
      return v:match('[^-]') and '✓ ' or 'x ' 
    end,
    true,
    false,
  }

  return generate_line(lengths, fields, lt, skip_replace)
end

local function generate_iface_line(lt, skip_replace)
  local lengths = {
    15,
    false,
    -1,
    -1,
  }
  local fields = {
    function(v, list)
      return " ├╴"..v
    end,
    nil,
    function(v)
      return v:match('connected') and '✓' or v:match('unmanaged') and 'o' or 'x' 
    end,
    function(v)
      if v:match('%-%-') then
        return ''
      end
      return ' '..v
    end,
  }

  return generate_line(lengths, fields, lt, skip_replace)
end

function o.icon_from_signal(signal)
  if not signal then
    return nil
  end
  if signal <= 20 then
    return beautiful.widget_net_0
  elseif signal <= 40 then
    return beautiful.widget_net_1
  elseif signal <= 60 then
    return beautiful.widget_net_2
  elseif signal <= 80 then
    return beautiful.widget_net_3
  else
    return beautiful.widget_net
  end
end

function o.generate_network_menu(cb, mypromptbox)
  o.connected = false
  o.signal = 0
  o.ssid = ''
  --generate the network menu
  local networks = {}
  local wifi_list = {}
  local local_interfaces = o.get_local_interfaces()
  table.sort(local_interfaces, function(a, b) return a[2] < b[2] end)
  local last_iface = nil
  for key, iface in ipairs(local_interfaces) do
    if key ~= 1 and last_iface ~= iface[2] then
      last_iface = iface[2]
      table.insert(networks, {last_iface:upper()})
    end
    if iface[2] == 'wifi' then
      local area_wifi = o.get_area_wifi()
      table.sort(area_wifi, function(a,b) return (tonumber(a[3]) or 100) > (tonumber(b[3]) or 100) end)
      for i, lt in ipairs(area_wifi) do
        local textbox = wibox.widget.textbox()
        local work = {
          generate_wifi_line(lt),
          function()
            awful.prompt.run({ prompt = "Password for "..lt[2]..": " },
            mypromptbox[mouse.screen].widget, function(password)
              run_async(COMMAND_WIFI_CONNECT..' '..lt[2]..' '..password, cb)
            end)
          end,
          o.icon_from_signal(tonumber(lt[3]))
        }

        if i > 1 then
          if lt[4] == '*' then
            local ssid, signal, security = lt[2], lt[3], lt[1]
            o.ssid = trim(ssid)
            o.connected = true
            o.signal = tonumber(signal)
            o.security = trim(security)
          else
            table.insert(wifi_list, work)
          end
        else
          table.insert(wifi_list, {generate_wifi_line({'🔒 ', 'SSID', nil, nil}, true)})
        end
      end
      local ud = {'Toggle Interface', function()
        run_async(COMMAND_IFACE..' '..iface[1], cb)
      end}
      table.insert(wifi_list, ud)
      local face = {generate_iface_line(iface), wifi_list}
      table.insert(networks, face)
    elseif key ~= 1 then
      local face = {generate_iface_line(iface), function()
        run_async(COMMAND_IFACE..' '..iface[1], cb)
      end}
      table.insert(networks, face)
    end
  end
  return networks
end

return o
