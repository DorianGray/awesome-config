local acpi = require 'init'()
local socket = require 'socket'
acpi.register('*', function(class, subclass, device, ...)
  print(class, subclass, device, ...)
end)
acpi.register('jack/headphone', function(class, subclass, device, action)
  print('headphone jack ', action..'ged')
end)
acpi.register('jack', function(...)
  print('a jack was plugged!')
end)
while true do
  acpi.events()
  socket.sleep(0.1)
end
