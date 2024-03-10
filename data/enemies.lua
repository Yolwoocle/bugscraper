require "scripts.util"
local Class = require "scripts.meta.class"
local Enemy = require "scripts.actor.enemy"
local Loot = require "scripts.actor.loot"
local Bullet = require "scripts.actor.bullet"
local Guns = require "data.guns"
local sounds = require "data.sounds"
local images = require "data.images"

local Larva = require "data.enemies.larva"
local Fly = require "data.enemies.fly"
local SpikedFly = require "data.enemies.spiked_fly"
local Mosquito = require "data.enemies.mosquito"
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
	self.Mosquito = Mosquito
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