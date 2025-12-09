require "scripts.util"
local upgrades = require "data.upgrades"
local enemies = require "data.enemies"
local images = require "data.images"
local BackroomWithDoor = require "scripts.level.backroom.backroom_with_door"
local BackgroundCafeteria = require "scripts.level.background.background_cafeteria"
local backgrounds = require "data.backgrounds"
local Rect = require "scripts.math.rect"

local Loot = require "scripts.actor.loot"
local guns = require "data.guns"

local BackroomCEOOffice = BackroomWithDoor:inherit()

function BackroomCEOOffice:init(params)
	params = params or {}
    BackroomCEOOffice.super.init(self, params)
	self.name = "ceo_office"

	self.cafeteria_background = BackgroundCafeteria:new(self)

	self.bg_w1 = backgrounds.BackgroundW1:new(self)
	self.bg_w2 = backgrounds.BackgroundFactory:new(self)
	self.bg_w3 = backgrounds.BackgroundServers:new(self)
	self.bg_w4 = backgrounds.BackgroundGreenhouse:new(self)
	self.bg_w0 = backgrounds.BackgroundW0:new(self)

	self.background_state = "normal"
	self.freeze_fury = false
end

function BackroomCEOOffice:generate(world_generator)
	world_generator:reset()
	world_generator:write_rect(Rect:new(2, 2, 79+24, 15), TILE_CARPET)
	world_generator:write_rect(Rect:new(27, 3, 54+24, 8), TILE_CARPET)
	world_generator:write_rect(Rect:new(78, 9, 78, 9), TILE_CARPET)

	world_generator:write_rect(Rect:new(4, 13, 8, 13), TILE_WOOD_SEMISOLID)
	world_generator:write_rect(Rect:new(27, 9, 27, 9), TILE_CARPET)
	world_generator:write_rect(Rect:new(78, 9, 78, 9), TILE_CARPET)
	
	game.camera.max_x = 50*16

	game:new_actor(Loot.Gun:new(44*16, 12*16, nil, 0, 0, guns.unlootable.ResignationLetter:new(), {
		life = math.huge,
		min_attract_dist = -1,
	}), 440, 105)

	local upgrade_display = enemies.UpgradeDisplay:new(62*16, 14*16)
	game:new_actor(upgrade_display)
	upgrade_display:assign_upgrade(upgrades.UpgradeAppleJuice:new())

	game:new_actor(enemies.BossDoor:new(78*16, 10*16, {cutscene = "enter_ceo_office"}))

	local ceo = game:new_actor(enemies.NPC:new(98*16 + 8, 14*16, {
		npc_name = "ceo",
		animations = {
			normal = { images.ceo_npc_idle, 0.2, 4 },
			shocked = { images.ceo_npc_shocked, 0.2, 1 },
			airborne = { images.ceo_npc_airborne, 0.2, 1 },
			jetpack = { images.ceo_npc_jetpack, 0.2, 1 },
			clap = { images.ceo_npc_clap_hand, 0.02, 3, nil, { looping = false } },
			tangled_wires = {images.ceo_tangled_wires, 0.1, 1},
			tangled_wires_shocked = {images.ceo_tangled_wires_shocked, 0.1, 1},
		},
		flip_x = true,
	}))
	ceo.gravity = 0
	ceo.is_affected_by_bounds = false

	local desk = game:new_actor(enemies.NPC:new(98*16, 15*16, {
		npc_name = "ceo_desk",
		animation = { images.ceo_office_desk, 0.2, 1 },
		flip_x = true,
	}))
	desk.z = -2

	local button = game:new_actor(enemies.NPC:new(98*16, 15*16 - 5, {
		npc_name = "button",
		animations = {
			normal = { images.small_button_crack2, 0.2, 1 },
			cracked = { images.small_button_crack0, 0.2, 1 },
			unpressed = { images.small_button, 0.2, 1 },
			pressed = { images.small_button_pressed, 0.2, 1 },
		},
	}))
	button.gravity = 0
	button.is_affected_by_bounds = false
	button.is_visible = false
	button.z = -1

	local big_glove = game:new_actor(enemies.NPC:new(88*16, 1*16, {
		npc_name = "big_glove",
		animation = { images.big_punching_glove, 0.2, 1 },
	}))
	big_glove.z = -2
	big_glove.gravity = 0
	big_glove.is_affected_by_bounds = false
	button.is_affected_by_walls = false

	-- Start button
	local nx = CANVAS_WIDTH * 0.7
	local ny = game.level.cabin_inner_rect.by
	local l = create_actor_centered(enemies.ButtonSmallGlass, floor(nx), floor(ny))
	game:new_actor(l)
	
	-- game:new_actor(enemies.FinalBoss:new(88*16, 14*16))
	-- for i=1, 4 do
	-- 	local l = create_actor_centered(enemies.ButtonSmall, 1600 - i * 32, 300)
	-- 	l.disappear_after_press = false
	-- 	l.on_press = function(_self, presser)
	-- 		if presser.kill then
	-- 			presser:kill()
	-- 		end
	-- 	end
	-- 	game:new_actor(l)
	-- end
end

function BackroomCEOOffice:can_exit()
	return false
end

function BackroomCEOOffice:update(dt)

end

function BackroomCEOOffice:draw()
	if self.background_state == "normal" then
		self.cafeteria_background:draw()
		love.graphics.draw(images.ceo_office_room, -16, -16)
		rect_color(COL_BLACK_BLUE, "fill", 76*16, 16*16, 105*16, 30*16)
		
	elseif self.background_state == "void" then
		rect_color(COL_BLACK_BLUE, "fill", -16, -16, CANVAS_WIDTH+32, CANVAS_HEIGHT+32)
		
	elseif self.background_state == "w4" then
		self.bg_w4:draw()
		
	elseif self.background_state == "w3" then
		self.bg_w3:draw()
		
	elseif self.background_state == "w2" then
		self.bg_w2:draw()
		
	elseif self.background_state == "w1" then
		self.bg_w1:draw()
		
	elseif self.background_state == "w0" then
		self.bg_w0:draw()

	end
end

return BackroomCEOOffice