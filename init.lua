-- Add local luarocks repo to package.path, if available
pcall(require, "luarocks.loader")

--early init
local awesome = require 'awesome'
local error_handler = require 'error_handler'
error_handler.setup(awesome)

local config = require 'config'
local theme = require('theme.' .. config.theme)

local beautiful = require 'beautiful'
beautiful.init(theme)
