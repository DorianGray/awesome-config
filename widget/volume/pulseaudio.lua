local process = require 'awful.io.process'


local mt = {}
mt.__index = mt

local cmd = "pacmd"

function mt:__call()
	local self = setmetatable({
	  default_sink = "",
	  volume = 0,
	  is_muted = false,
	}, mt)

  self:update()	

	return self
end

function mt:update()
	local out = process.run(cmd .. " dump").stdout()

	-- get the default sink
	self.default_sink = string.match(out, "set%-default%-sink ([^\n]+)")

	if self.default_sink == nil then
		self.default_sink = ""
		return false
	end

	for sink, value in string.gmatch(out, "set%-sink%-volume ([^%s]+) (0x%x+)") do
		if sink == self.default_sink then
			self.volume = tonumber(value) / 0x10000
		end
	end

	local m
	for sink, value in string.gmatch(out, "set%-sink%-mute ([^%s]+) (%a+)") do
		if sink == self.default_sink then
			m = value
		end
	end

	self.is_muted = m == "yes"
end

function mt:set_volume(vol)
	if vol > 1 then
		vol = 1
	end

	if vol < 0 then
		vol = 0
	end

	vol = vol * 0x10000

	process.run(cmd .. " set-sink-volume " .. self.default_sink .. " " .. string.format("0x%x", math.floor(vol)))

	self:update()
end


function mt:toggle_mute()
	if self.is_muted then
		process.run(cmd .. " set-sink-mute " .. self.default_sink .. " 0")
	else
		process.run(cmd .. " set-sink-mute " .. self.default_sink .. " 1")
	end

	self:update()
end


return setmetatable({}, mt)
