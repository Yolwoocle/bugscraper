require "scripts.util"
local images = require "data.images"
local enemies = require "data.enemies"
local npcs = require "data.npcs"
local BackroomWithDoor = require "scripts.level.backroom.backroom_with_door"
local BackgroundCafeteria = require "scripts.level.background.background_cafeteria"
local ElevatorDoorSlidingLarge = require "scripts.level.door.elevator_door_sliding_large"
local TvPresentation    = require "scripts.level.background.tv_presentation"
local WaterDispenser   = require "scripts.actor.enemies.vending_machine.water_dispenser"
local Rect = require "scripts.math.rect"
local shaders = require "data.shaders"

local hangar = require "data.models.hangar"
local Renderer3D = require "scripts.graphics.3d.renderer_3d"
local Object3D = require "scripts.graphics.3d.object_3d"

local BackroomGroundFloor = BackroomWithDoor:inherit()

function BackroomGroundFloor:init(params)
	params = params or {}
    BackroomGroundFloor.super.init(self, params)
	self.name = "ground_floor"

	self.all_in_front = false

	self.close_door_timer = 0.5
	self.tv_presentation = TvPresentation:new(715, 100)

	self.has_opened_door = false
	self.freeze_fury = false

    self.def_3d_scale = 140
    self.object_3d = Object3D:new(hangar)
    self.renderer = Renderer3D:new({self.object_3d})
    self.object_3d.scale:sset(self.def_3d_scale, -self.def_3d_scale, self.def_3d_scale)
    self.object_3d.position.y = -120
    self.object_3d.position.z = 40
    self.object_3d.rotation.y = pi/2
	self.ball_lighting_palette = {color(0xf77622), color(0xfeae34), color(0xfee761), color(0xfee761), COL_WHITE}

	self.renderer.orthographic = false
	self.renderer.fov = 300
	self.renderer.render_offset.x = 200
	self.renderer.render_offset.y = 200
	self.renderer.line_color = color(0x202035)

	self.renderer:update(0)

	self.show_basement_bg = false

	self.number_of_exited_players = 0 -- TODO
end

function BackroomGroundFloor:generate(world_generator)
	game.level:set_bounds(Rect:new(unpack(RECT_BASEMENT)))

	game.camera.max_x = CANVAS_WIDTH + 11*16
	
    world_generator:reset()
	world_generator:write_rect(Rect:new(2, 0, 68, 15), TILE_METAL) -- Wall
	world_generator:write_rect(Rect:new(2, 15, 68, 15), TILE_STONE) -- Floor

	local b = create_actor_centered(enemies.ButtonSmallGlass, floor(15*16), floor(15*16))
	b.spawned_actor = enemies.ButtonSmallRocket
	game:new_actor(b)

	game:new_actor(enemies.PlayerTrigger:new(3 * 16, -16, 64 * 16, 16, function()
		for _, player in pairs(game.players) do
			if player.y < 0 then
				player.gravity_mult = 0
				player.vy = -30

                player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                player:reset_virtual_controller()
			end
		end
	end, { 
		min_player_trigger = 1, 
		triggers = math.huge,
	}))

	game:set_actor_draw_color(COL_BLACK_BLUE)

	Audio:set_effect("echo")
end

function BackroomGroundFloor:get_default_camera_position()
	return 312 - 16, 48
end

function BackroomGroundFloor:can_exit()
	return false
	-- return BackroomGroundFloor.super.can_exit(self)
end

function BackroomGroundFloor:on_exit()
	BackroomGroundFloor.super.on_exit(self)
end

function BackroomGroundFloor:update(dt)
	BackroomGroundFloor.super.update(self, dt)

	local cx, cy = math.floor(game.camera:get_real_position())
    self.renderer.render_offset.x = CANVAS_WIDTH/2 + cx
    self.object_3d.position.x = -cx * 0.1 + 20

	self.renderer:update(dt)
end

function BackroomGroundFloor:draw_background()
	love.graphics.clear(COL_VERY_DARK_GRAY)
end

function BackroomGroundFloor:draw_items()
	if not self.show_basement_bg then
		return
	end 
	
    self.renderer:draw()
	local cx, cy = math.floor(game.camera:get_real_position())
	-- love.graphics.draw(images.basement,        round(-16 + cx*0.9), -16)
	love.graphics.draw(images.basement_rocket, math.floor(227 + cx*0.965), 80, 0, 0.5, 0.5)
end

function BackroomGroundFloor:draw_front_walls()
	local draw = function()
		love.graphics.draw(images.basement_front, -16, -16)
	end

	if not self.show_basement_bg then
		shaders.draw_in_color:sendColor("fillColor", COL_BLACK_BLUE)
		exec_using_shader(shaders.draw_in_color, draw)
	else
		draw()
	end
end

return BackroomGroundFloor