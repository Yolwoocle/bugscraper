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
local HoneypotAnt = require "data.enemies.honeypot_ant"
local Spider = require "data.enemies.spider"
local StinkBug = require "data.enemies.stink_bug"
local Dung = require "data.enemies.dung"
local DungBeetle = require "data.enemies.dung_beetle"
local FlyingDung = require "data.enemies.flying_dung"
local Woodlouse = require "data.enemies.woodlouse"

local PoisonCloud = require "data.enemies.poison_cloud"

local ButtonBigPressed = require "data.enemies.button_big_pressed"
local ButtonBig = require "data.enemies.button_big"
local ButtonBigGlass = require "data.enemies.button_big_glass"

local ButtonSmallGlass = require "data.enemies.button_small_glass"
local ButtonSmall = require "data.enemies.button_small"
local ExitSign = require "data.enemies.exit_sign"

local Cocoon = require "data.enemies.cocoon"

local VendingMachine = require "data.enemies.vending_machine.vending_machine"

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
	self.HoneypotAnt = HoneypotAnt
	self.Spider = Spider
	self.StinkBug = StinkBug
	self.DungBeetle = Dung
	self.FlyingDung = FlyingDung
	self.Woodlouse = Woodlouse
	
	self.PoisonCloud = PoisonCloud

	self.ButtonBigPressed = ButtonBigPressed
	self.ButtonBig = ButtonBig
	self.ButtonBigGlass = ButtonBigGlass

	self.ButtonSmall = ButtonSmall
	self.ButtonSmallGlass = ButtonSmallGlass
	
	self.ExitSign = ExitSign
	self.VendingMachine = VendingMachine
	self.Cocoon = Cocoon

	self.Dummy = Dummy
end

return Enemies:new()