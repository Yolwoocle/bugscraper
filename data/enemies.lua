require "scripts.util"
local Class = require "scripts.meta.class"
local Enemy = require "scripts.actor.enemy"
local Loot = require "scripts.actor.loot"
local Bullet = require "scripts.actor.bullet"
local Guns = require "data.guns"
local sounds = require "data.sounds"
local images = require "data.images"

local Larva = require "scripts.actor.enemies.larva"
local Fly = require "scripts.actor.enemies.fly"
local SpikedFly = require "scripts.actor.enemies.spiked_fly"
local Mosquito = require "scripts.actor.enemies.mosquito"
local Grasshopper = require "scripts.actor.enemies.grasshopper"
local Slug = require "scripts.actor.enemies.slug"
local SnailShelled = require "scripts.actor.enemies.snail_shelled"
local Dummy = require "scripts.actor.enemies.dummy"
local MushroomAnt = require "scripts.actor.enemies.mushroom_ant"
local HoneypotAnt = require "scripts.actor.enemies.honeypot_ant"
local Spider = require "scripts.actor.enemies.spider"
local StinkBug = require "scripts.actor.enemies.stink_bug"
local Dung = require "scripts.actor.enemies.dung"
local DungBeetle = require "scripts.actor.enemies.dung_beetle"
local FlyingDung = require "scripts.actor.enemies.flying_dung"
local Woodlouse = require "scripts.actor.enemies.woodlouse"

local PoisonCloud = require "scripts.actor.enemies.poison_cloud"

local ButtonBigPressed = require "scripts.actor.enemies.button_big_pressed"
local ButtonBig = require "scripts.actor.enemies.button_big"
local ButtonBigGlass = require "scripts.actor.enemies.button_big_glass"

local ButtonSmallGlass = require "scripts.actor.enemies.button_small_glass"
local ButtonSmall = require "scripts.actor.enemies.button_small"
local ExitSign = require "scripts.actor.enemies.exit_sign"

local Cocoon = require "scripts.actor.enemies.cocoon"

local VendingMachine = require "scripts.actor.enemies.vending_machine.vending_machine"

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