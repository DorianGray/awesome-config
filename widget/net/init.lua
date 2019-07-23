local wibox = require 'wibox'
local awful = require 'awful'
local beautiful = require 'beautiful'
local string = require 'string'
local table = require 'table'
local util = require 'util'
local icon = require 'widget.net.icon.signal'(
  32 * beautiful.scale,
  32 * beautiful.scale
)
local mouse = require 'mouse'
local gears = require 'gears'
local form = require 'widget.form'
local form_textbox = require 'widget.form.textbox'

local net = {}
net.__index = net

local function get_net_status()
  local times = 0

  local function ping()
    local output = util.run('ping -c 1 -W 1 8.8.8.8 | grep \'100% packet loss\'', true)
    if output and times <= 4 then
      times = times + 1
      return ping()
    else
      return output == ""
    end
  end

  return ping()
end

local NET_STATUS = {
  UP='connected',
  DOWN='disconnected',
}

local function parse_proc_net_wireless(output)
  local interfaces = {}
  for line in output:gmatch('([^\n]+)') do
    if not line:match('|') then
      local _, _, iface, status, link, level, noise  = line:find('^([^:]+):%s+(%d+)%s+(%d+)%.%s+-(%d+)%.%s+-(%d+)')
      interfaces[iface] = {status=status, link=link, level=level, noise=noise}
    end
  end
  return interfaces
end

local function parse_ip_link(output, cat_output)
  local sep = '\n'
  local groups = {{name='INTERFACE', type='TYPE', status='STATUS'}}
  local wireless = parse_proc_net_wireless(cat_output)

  local function add_group(group)
    local str = table.concat(group, sep)
    local _, _, ifname, iftype, ifstatus = str:find('%d:%s+(%S*):%s+<(%S*)>.*state%s+(%S*)')
    ifstatus = NET_STATUS[ifstatus] or 'unavailable'
    if iftype:match('LOOPBACK') then
      iftype = 'loopback'
      ifstatus = NET_STATUS['UP']
    elseif wireless[ifname] then
      iftype = 'wireless'
    elseif iftype:match('BROADCAST,MULTICAST') then
      iftype = 'ethernet'
    else
      iftype = 'unknown'
    end
    groups[#groups+1] = {name = ifname, type = iftype, status = ifstatus}
  end

  local group = {}
  for str in string.gmatch(output, '([^'..sep..']+)') do
    if str:match('^%d:') and #group > 0 then
      add_group(group)
      group = {str}
    else
      group[#group+1]=str
    end
  end
  add_group(group)

  return groups
end

--Make a table of the local interfaces
local function get_local_interfaces()
  local output = util.run('ip link', true)
  return parse_ip_link(output, util.read_file('/proc/net/wireless'))
end

local function get_wifi_link(iface)
  local wireless = parse_proc_net_wireless(util.read_file('/proc/net/wireless'))
  local wpa_output = util.run('wpa_cli status', true)
  local info = {}
  for line in wpa_output:gmatch('([^\n]+)') do
    local _, _, key, value = line:find('^([^=]*)=([^=]*)$')
    if key then
      info[key] = value
    end
  end
  local level = wireless[iface.name] and wireless[iface.name].level or 0
  return {
    ssid=info.ssid,
    signal=tonumber(level),
    frequency=tonumber(info.freq),
  }
end

local scan_timer = nil
--make a table of the scanned wifis
function net:get_area_wifi(iface)
  local scan_output = util.run('wpa_cli abort_scan && wpa_cli scan', true)
  if scan_output:match('FAIL') then
    if scan_timer and scan_timer.started then
      scan_timer:stop()
      scan_timer = nil
    end
  end
  if scan_timer and scan_timer.started then
    return
  end
  if not scan_timer or not scan_timer.started then
    scan_timer = gears.timer({
      timeout   = 1,
      autostart = false,
      callback  = function()
        local output = util.run('wpa_cli scan_results', true)
        local _, count = output:gsub('\n', '\n')
        if count <= 3 then
          if scan_timer.started then
            scan_timer.timeout = 3
            return
          end
        end
        scan_timer:stop()
        local wireless = {}
        local skip = 1
        for line in output:gmatch('[^\r\n]+') do
          if skip <= 2 then
            skip = skip + 1
          else
            local _, _, bssid, frequency, signal, encryption, ssid = line:find("([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)")
            table.insert(wireless, {
              bssid=bssid,
              frequency=tonumber(frequency),
              signal=tonumber(signal),
              encryption=encryption,
              ssid=ssid,
            })
          end
        end
        if not self.wireless[iface.name] then
          self.wireless[iface.name] = {}
        end
        if #self.wireless[iface.name] ~= #wireless then
          table.sort(wireless, function(a, b) return (math.abs(a.signal) or 100) > (math.abs(b.signal) or 100) end)
          self.wireless[iface.name] = wireless
          self:menu()
        end
      end
    })
  end
  scan_timer:start()
end

local function connect_wifi(ssid, security)
  local panel = mouse.screen.right_panel
  local wifi_widget = wibox.widget({
    layout=wibox.layout.grid,
    homogeneous=true,
    spacing=0,
    min_cols_size=2,
    min_rows_size=1,
  })

  local row = 1
  wifi_widget:add_widget_at(wibox.widget.textbox('SSID: '), row, 1)
  wifi_widget:add_widget_at(wibox.widget.textbox(ssid), row, 2)
  row = row + 1
  if security then
    wifi_widget:add_widget_at(wibox.widget.textbox('Security: '), row, 1)
    wifi_widget:add_widget_at(wibox.widget.textbox(security), row, 2)
    row = row + 1
    wifi_widget:add_widget_at(wibox.widget.textbox('Password: '), row, 1)
    local wifi_form = form(function(self)
      panel:toggle_visible(false)
      self:set_active_input(nil)
    end)
    local password_box = form_textbox(wifi_form, 'password')
    password_box.type = 'password'
    wifi_form:set_active_input(password_box.widget)
    wifi_widget:add_widget_at(password_box, row, 2)
    row = row + 1
  end

  panel:set_content(wifi_widget)
  panel:toggle_visible(true)
end

function net:toggle_interface(iface)
  self.interfaces = get_local_interfaces()
  for _, interface in pairs(self.interfaces) do
    if interface[1] == iface then 
      local action = interface[3] == 'connected'  and 'down' or 'up'
      local command = 'sudo ip link set dev '..iface..' '..action
      util.run(command, true)
    end
  end
end

local function disconnect_wifi()

end

function net:toggle_wifi(iface)
  local output = util.run('sudo rfkill -r -n', true)
  local rfkill = {}
  for line in output:gmatch("[^\r\n]+") do
    local interface = {}
    for str in line:gmatch("%w+") do
      table.insert(interface, str)
    end
    table.insert(rfkill, interface)
  end

  for _, interface in pairs(rfkill) do
    local index, wtype, name, softblock, hardblock = interface[1], interface[2], interface[3], interface[4] == 'blocked' and true or false, interface[5] == 'blocked' and true or false
    if wtype == 'wlan' then
      local action = 'block'
      if softblock or hardblock then
        action = 'unblock'
      else
        self.connected = false
        self.signal = 0
        self.ssid = ''
        self.frequency = 0
      end
      util.run('sudo rfkill '..action..' '..wtype, true)
      self:menu()
    end
  end
end

local function generate_line(data, order, lengths, format, skip_replace)
  local line = {}
  for _, key in pairs(order) do
    local len = lengths[key]
    local v = data[key]
    if not skip_replace and type(format[key]) == 'function' then
      v = format[key](v)
    end
    if len then
      if len < 0 then
        table.insert(line, v)
      elseif #v > len then
        table.insert(line, v:sub(1, len-3)..'...'..(' '):rep(3))
      else
        table.insert(v..(" "):rep(len+3-#v))
      end
    end
  end
  return table.concat(line)
end

local function generate_wifi_line(data, skip_replace)
  local line = {}
  local lengths = {
    encryption = -1,
    ssid = -1,
  }
  local format = {
    encryption = function(v)
      return v ~= '[ESS]' and '✓ ' or 'x ' 
    end,
    ssid = true,
  }
  local order = {
    'encryption',
    'ssid',
  }

  return generate_line(data, order, lengths, format, skip_replace)
end

local function generate_iface_line(data, skip_replace)
  local lengths = {
    status = -1,
    name = -1,
  }
  local format = {
    status = function(v)
      if v:match('disconnected') or v:match('unavailable') then
        return '✗'
      elseif v:match('connected') then
        return '✓'
      elseif v:match('connecting') then
        return ' ❗  '
      end
      return '     '
    end,
    name = function(v, list)
      if data.pos == 'last' then
        return '╰╴'..v
      else
        return '├╴'..v
      end
    end,
  }
  local order = {
    'status',
    'name',
  }

  return generate_line(data, order, lengths, format, skip_replace)
end

function net:generate_wifi_menu(iface)
  local link = get_wifi_link(iface)
  self.connected = link and true or false
  if self.connected then
    self.signal = link.signal
    self.ssid = link.ssid
    self.frequency = link.frequency
  else
    self.signal = 0
    self.ssid = ''
    self.frequency = 0
  end
  if self.widget then
    self.widget:set_image(icon(self.signal, 0--[[self.frequency]], self.connected, self.internet))
  end

  self:get_area_wifi(iface)
  local wifi_list = {{generate_wifi_line({encryption='⚷ ', ssid='SSID'}, true)}}
  for _, data in pairs(self.wireless[iface.name] or {}) do 
    local work = {
      generate_wifi_line(data),
      function()
        connect_wifi(data.ssid, data.encryption)
        self:menu()
      end,
      icon(math.abs(data.signal), data.frequency, true, true)
    }
    table.insert(wifi_list, work)
  end

  table.insert(wifi_list, {'Rescan', function()
    self:get_area_wifi(iface)
  end})
  table.insert(wifi_list, {'Disconnect', function()
    disconnect_wifi(iface.name)
  end})
  table.insert(wifi_list, {'Toggle Interface', function()
    self:toggle_wifi(iface.name)
  end})
  local face = {generate_iface_line(iface), wifi_list}
  local found = nil
  for i, face1 in pairs(self.networks) do
    if face1.name == face[1] then
      found = i
      break
    end
  end
  if found then
    self.networks[found] = face
  else
    table.insert(self.networks, face)
  end
end

--generate the network menu
function net:generate_menu()
  local interfaces = get_local_interfaces()
  self.networks = {}
  --Sort by network type
  table.sort(interfaces, function(a, b) return a.type < b.type end)
  local last_type = nil
  for i, iface in pairs(interfaces) do
    -- Insert type separator(ie: BRIDGE)
    if i ~= 1 and last_type ~= iface.type then
      iface.pos = 'new'
      last_type = iface.type
      table.insert(self.networks, {last_type:upper()})
    else
      iface.pos = 'current'
    end
    if i >= #interfaces or interfaces[i+1].type ~= last_type then
      iface.pos = 'last'
    end

    if iface.type == 'wireless' then
      -- wifi interfaces
      self:generate_wifi_menu(iface)
    elseif i ~= 1 then
      --any network interface that is not the header and does not have a submenu
      local face = {generate_iface_line(iface), function()
        self:toggle_interface(iface.name)
        self:menu()
      end}
      table.insert(self.networks, face)
    end
  end
end

function net:menu()
  if self.rendering then
    return
  end
  self.rendering = true
  self:generate_menu()
  self.args.menu = awful.menu({
    theme = {
      height = beautiful.menu_height,
      width = beautiful.menu_width,
    },
    items = self.networks,
  })
  self.rendering = false
end

return function()
  local self = setmetatable({}, net)
  self.rendering = false
  self.ssid = ''
  self.connected = false
  self.signal = 0
  self.frequency = 0
  self.encryption = nil
  self.internet = true
  self.networks = {}
  self.wireless = {}

  self.args = {
    image = icon(self.signal, 0 --[[self.frequency]], self.connected, self.internet),
    menu = {},
  }
  self.widget = awful.widget.launcher(self.args)
  self:menu()

  awful.tooltip({
    objects = {self.widget},
    timer_function = function()
      if self.ssid then
        return self.ssid..'\n'..tostring(self.frequency):sub(1, 1)..'ghz'
      else
        return 'Not Connected'
      end
    end
  })
  gears.timer({
    timeout=10,
    autostart=true,
    callback=function()
      self.internet = get_net_status()
      local link = get_wifi_link({name='wlp2s0'})
      self.connected = link and true or false
      if self.connected then
        self.signal = link.signal
        self.ssid = link.ssid
        self.frequency = link.frequency
      else
        self.signal = 0
        self.ssid = ''
        self.frequency = 0
      end
      self.widget:set_image(icon(self.signal, 0--[[self.frequency]], self.connected, self.internet))
    end,
  })
  return self
end
