require "scripts.util"
local Class = require "scripts.class"
local Enemy = require "scripts.enemy"
local Loot = require "scripts.loot"
local Bullet = require "scripts.bullet"
local Guns = require "data.guns"
local sounds = require "data.sounds"
local images = require "data.images"

local Fly = require "data.enemies.fly"
local SpikedFly = require "data.enemies.spiked_fly"
local Larva = require "data.enemies.larva"
local Grasshopper = require "data.enemies.grasshopper"
local Slug = require "data.enemies.slug"
local SnailShelled = require "data.enemies.snail_shelled"
local Dummy = require "data.enemies.dummy"
local MushroomAnt = require "data.enemies.mushroom_ant"
local Spider = require "data.enemies.spider"
local ButtonPressed = require "data.enemies.button_pressed"
local Button = require "data.enemies.button"
local ButtonGlass = require "data.enemies.button_glass"


local Enemies = Class:inherit()

function Enemies:init()
	self.Larva = Larva
	self.Fly = Fly
	self.SpikedFly = SpikedFly
	self.Grasshopper = Grasshopper
	self.Slug = Slug
	self.SnailShelled = SnailShelled
	self.MushroomAnt = MushroomAnt
	self.Spider = Spider

	self.ButtonPressed = ButtonPressed
	self.Button = Button
	self.ButtonGlass = ButtonGlass

	self.Dummy = Dummy
end

return Enemies:new()