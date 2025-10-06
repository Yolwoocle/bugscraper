require "scripts.util"
local Background = require "scripts.level.background.background"

local BackgroundLayered = Background:inherit()

function BackgroundLayered:init(level)
	BackgroundLayered.super.init(self, level)
	self.name = "background_layered"

	self.layers = {}
end

function BackgroundLayered:on_background_set()
	for _, layer in pairs(self.layers) do
		layer.layer_y = layer.initial_y
	end
end

function BackgroundLayered:add_layer(layer)
	table.insert(self.layers, layer)
end

function BackgroundLayered:update(dt)
	BackgroundLayered.super.update(self, dt)
	
	for _, layer in pairs(self.layers) do
		layer:update(dt)
	end
end

function BackgroundLayered:draw()
	BackgroundLayered.super.draw(self)
	
	for _, layer in pairs(self.layers) do
		layer:draw()
	end
end

return BackgroundLayered