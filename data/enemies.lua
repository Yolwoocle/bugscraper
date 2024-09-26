require "scripts.util"

local enemies = {
	Larva =              require "scripts.actor.enemies.larva",
	Fly =                require "scripts.actor.enemies.fly",
	SpikedFly =          require "scripts.actor.enemies.spiked_fly",
	Woodlouse =          require "scripts.actor.enemies.woodlouse",
	Mosquito =           require "scripts.actor.enemies.mosquito",
	Slug =               require "scripts.actor.enemies.slug",
	Spider =             require "scripts.actor.enemies.spider",
	StinkBug =           require "scripts.actor.enemies.stink_bug",
	SnailShelled =       require "scripts.actor.enemies.snail_shelled", 
	Boomshroom =         require "scripts.actor.enemies.boomshroom", 
	Dung =               require "scripts.actor.enemies.dung",
	DungBeetle =         require "scripts.actor.enemies.dung_beetle",
	FlyingDung =         require "scripts.actor.enemies.flying_dung",
	
	ElectricArc =        require "scripts.actor.enemies.electric_arc", 
	ElectricRays =       require "scripts.actor.enemies.electric_rays", 
	SnailShelledBouncy = require "scripts.actor.enemies.snail_shelled_bouncy", 
	Grasshopper =        require "scripts.actor.enemies.grasshopper", 
	Chipper =            require "scripts.actor.enemies.chipper",  
	MetalFly =           require "scripts.actor.enemies.metal_fly",
	BulbBuddy =          require "scripts.actor.enemies.bulb_buddy", 
	SwitchBug =          require "scripts.actor.enemies.switch_bug", --*
	W2boss =             require "scripts.actor.enemies.w2boss", --*

	ShovelBee =          require "scripts.actor.enemies.shovel_bee", 
	DrillBee =           require "scripts.actor.enemies.drill_bee", 
	HoneycombFootball =  require "scripts.actor.enemies.honeycomb_football", 
	HoneypotAnt =        require "scripts.actor.enemies.honeypot_ant",
	Chipper360 =         require "scripts.actor.enemies.chipper_360", 
	TimedSpikes =        require "scripts.actor.enemies.timed_spikes",
	LarvaSpawner =       require "scripts.actor.enemies.larva_spawner", --*

	Turret =             require "scripts.actor.enemies.turret", --*
	Centipede =          require "scripts.actor.enemies.centipede", --*
	BigBug =             require "scripts.actor.enemies.big_bug", --*
	Slime =              require "scripts.actor.enemies.slime", --*
	Frog =               require "scripts.actor.enemies.frog", --*
	Motherboard =        require "scripts.actor.enemies.motherboard", --*
	BigChipper360 =      require "scripts.actor.enemies.big_chipper_360", --*
	MotherboardButton =  require "scripts.actor.enemies.motherboard_button", --*

	MushroomAnt =        require "scripts.actor.enemies.mushroom_ant",

	BeeBoss =            require "scripts.actor.enemies.bee_boss", --*
	
	Dummy =              require "scripts.actor.enemies.dummy",
	ButtonBigPressed =   require "scripts.actor.enemies.button_big_pressed",
	ButtonBig =          require "scripts.actor.enemies.button_big",
	ButtonBigGlass =     require "scripts.actor.enemies.button_big_glass",
	ButtonSmallGlass =   require "scripts.actor.enemies.button_small_glass",
	ButtonSmall =        require "scripts.actor.enemies.button_small",
	ExitSign =           require "scripts.actor.enemies.exit_sign",
	UpgradeDisplay =     require "scripts.actor.enemies.upgrade_display",
	GunDisplay =         require "scripts.actor.enemies.gun_display",
	VendingMachine =     require "scripts.actor.enemies.vending_machine.vending_machine",
	
	Cocoon =             require "scripts.actor.enemies.cocoon",
	FaintedPlayer =      require "scripts.actor.enemies.fainted_player",

	PoisonCloud =        require "scripts.actor.enemies.poison_cloud",
	PongBall =           require "scripts.actor.enemies.pong_ball",
	Explosion =          require "scripts.actor.enemies.explosion",
}

return enemies