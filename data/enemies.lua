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

local ButtonBigPressed = require "data.enemies.button_big_pressed"
local ButtonBig = require "data.enemies.button_big"
local ButtonBigGlass = require "data.enemies.button_big_glass"

local ButtonSmallPressed = require "data.enemies.button_small_pressed"
local ButtonSmall = require "data.enemies.button_small"
local ButtonSmallGlass = require "data.enemies.button_small_glass"

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

	self.ButtonBigPressed = ButtonBigPressed
	self.ButtonBig = ButtonBig
	self.ButtonBigGlass = ButtonBigGlass

	self.ButtonSmallPressed = ButtonSmallPressed
	self.ButtonSmall = ButtonSmall
	self.ButtonSmallGlass = ButtonSmallGlass

	self.Dummy = Dummy
end

return Enemies:new()