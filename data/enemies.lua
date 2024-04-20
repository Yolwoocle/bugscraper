require "scripts.util"

local enemies = {
	Larva =            require "scripts.actor.enemies.larva",
	Fly =              require "scripts.actor.enemies.fly",
	SpikedFly =        require "scripts.actor.enemies.spiked_fly",
	Mosquito =         require "scripts.actor.enemies.mosquito",
	Grasshopper =      require "scripts.actor.enemies.grasshopper",
	Slug =             require "scripts.actor.enemies.slug",
	SnailShelled =     require "scripts.actor.enemies.snail_shelled",
	Dummy =            require "scripts.actor.enemies.dummy",
	MushroomAnt =      require "scripts.actor.enemies.mushroom_ant",
	HoneypotAnt =      require "scripts.actor.enemies.honeypot_ant",
	Spider =           require "scripts.actor.enemies.spider",
	StinkBug =         require "scripts.actor.enemies.stink_bug",
	Dung =             require "scripts.actor.enemies.dung",
	DungBeetle =       require "scripts.actor.enemies.dung_beetle",
	FlyingDung =       require "scripts.actor.enemies.flying_dung",
	Woodlouse =        require "scripts.actor.enemies.woodlouse",
	
	PoisonCloud =      require "scripts.actor.enemies.poison_cloud",
	
	ButtonBigPressed = require "scripts.actor.enemies.button_big_pressed",
	ButtonBig =        require "scripts.actor.enemies.button_big",
	ButtonBigGlass =   require "scripts.actor.enemies.button_big_glass",
	
	ButtonSmallGlass = require "scripts.actor.enemies.button_small_glass",
	ButtonSmall =      require "scripts.actor.enemies.button_small",
	ExitSign =         require "scripts.actor.enemies.exit_sign",
	UpgradeDisplay =   require "scripts.actor.enemies.upgrade_display",
	
	Cocoon =           require "scripts.actor.enemies.cocoon",
	FaintedPlayer =    require "scripts.actor.enemies.fainted_player",
	
	VendingMachine =   require "scripts.actor.enemies.vending_machine.vending_machine",
	PongBall =         require "scripts.actor.enemies.pong_ball",
}

return enemies