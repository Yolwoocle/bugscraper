require "scripts.util"
local images = require "data.images"
local Class = require "scripts.meta.class"
local PlayerPreview = require "scripts.ui.player_preview"
local shaders = require "data.shaders"

local GameUI = Class:inherit()

function GameUI:init(game, is_visible)
	self.game = game

    self.is_visible = param(is_visible, true)
	self.stomp_arrow_target = nil

	self.floating_text = ""
	self.floating_text_y = -50
	self.floating_text_target_y = -100

	self.player_previews = {}
	local w = 108
	local spacing = 10
	local x = CANVAS_WIDTH/2 - ((w + spacing) * (MAX_NUMBER_OF_PLAYERS-1) + w)/2
	local y = 200
	for i = 1, MAX_NUMBER_OF_PLAYERS do
		table.insert(self.player_previews, PlayerPreview:new(i, x, y, w, 64))
		x = x + w + spacing	
	end

	self.splash_x = 0
	self.splash_vx = 0
	self.show_splash = true
end

function GameUI:update(dt)
	self:update_floating_text(dt)
	for i, preview in pairs(self.player_previews) do
		preview:update(dt)
		preview.y = preview.base_y - self.game.logo_y
	end

	self:update_splash(dt)
end

function GameUI:update_floating_text(dt)
	self.floating_text_y = lerp(self.floating_text_y, self.floating_text_target_y, 0.05)
end

function GameUI:enable_floating_text(text)
	self.floating_text = text
	self.floating_text_target_y = 80
end

function GameUI:disable_floating_text()
	self.floating_text_target_y = -50
end

function GameUI:set_visible(bool)
    self.is_visible = bool
end

function GameUI:draw()
	if not self.is_visible then return end
	self:draw_stomp_arrow()
	if game.debug and game.debug.title_junk then
		-- self:draw_logo()
		self:draw_join_tutorial()
		self:draw_timer()
		self:draw_version()
	end 
	self:draw_offscreen_indicators()
	self:draw_floating_text()
	self:draw_upgrades()
	self:draw_player_previews()
	
	self:draw_splash_animation()
	-- local r
    -- r = game.level.cabin_inner_rect
    -- rect_color(COL_GREEN, "line", r.ax, r.ay, r.w, r.h)
	-- r = game.level.cabin_rect
    -- rect_color(COL_RED, "line", r.ax, r.ay, r.w, r.h)
end

function GameUI:draw_front()
	if not self.is_visible then return end

	self:draw_FPS()
end

function GameUI:draw_logo()
	for i=1, #LOGO_COLS + 1 do
		local ox, oy = cos(game.logo_a + i*.4)*8, sin(game.logo_a + i*.4)*8
		local logo_x = floor((CANVAS_WIDTH - images.logo_noshad:getWidth())/2)
		
		local col = LOGO_COLS[i]
		local img = images.logo_shad
		if col == nil then
			col = COL_WHITE
			img = images.logo_noshad
		end
		gfx.setColor(col)
		gfx.draw(img, math.floor(logo_x + ox), math.floor(game.logo_y + oy))
		if DEMO_BUILD then
			if i == 4 then
				print_outline(COL_WHITE, COL_BLACK_BLUE, Text:text("game.demo"), logo_x + ox + 90, game.logo_y + oy + 19)
			else
				print_outline(col, col, Text:text("game.demo"), logo_x + ox + 90, game.logo_y + oy + 19)
			end
		end
	end
end

function GameUI:draw_version()
	local old_font = love.graphics.getFont()
	love.graphics.setFont(FONT_MINI)

	local text = concat("v", BUGSCRAPER_VERSION)
	local x = math.floor(CANVAS_WIDTH - get_text_width(text) - 2)
	local y = self.game.logo_y
	print_outline(COL_DARK_GRAY, COL_VERY_DARK_GRAY, text, x, y)
	love.graphics.setFont(old_font)

	-- if OPERATING_SYSTEM == "Web" and not game.has_seen_controller_warning then
	-- 	print_centered_outline(COL_MID_GRAY, COL_BLACK_BLUE, "⚠️ "..Text:text("game.warning_web_controller"), CANVAS_WIDTH/2, y+6)
	-- end
end

function GameUI:draw_join_tutorial()
	if true then return end --removeme

	local def_x = math.floor((game.level.door_rect.ax + game.level.door_rect.bx) / 2 )
	-- local def_y = game.logo_y - 10
	local def_y = CANVAS_HEIGHT - game.logo_y + 8
	local number_of_keyboard_users = Input:get_number_of_users(INPUT_TYPE_KEYBOARD)

	local icons = {
		Input:get_button_icon(1, Input:get_input_profile("global"):get_primary_button("join_game", INPUT_TYPE_CONTROLLER), BUTTON_STYLE_XBOX),
		Input:get_button_icon(1, Input:get_input_profile("global"):get_primary_button("join_game", INPUT_TYPE_CONTROLLER), BUTTON_STYLE_PLAYSTATION5),
		Input:get_button_icon(1, Input:get_input_profile("global"):get_primary_button("join_game", INPUT_TYPE_KEYBOARD)),
	}
	if number_of_keyboard_users >= 1 then
		table.remove(icons)
	end
	
	local x = def_x
	local y = def_y

	print_outline(COL_WHITE, COL_BLACK_BLUE, Text:text("input.prompts.join"), x, y)
	for i, icon in pairs(icons) do
		x = x - icon:getWidth() - 2
		love.graphics.draw(icon, x, y)
		if i ~= #icons then
			print_outline(COL_WHITE, COL_BLACK_BLUE, "/", x-3, y)
		end
	end
	
	if number_of_keyboard_users == 1 then
		local icon_split_kb = Input:get_button_icon(1, Input:get_input_profile("global"):get_primary_button("split_keyboard"))
		local split_label = ternary(number_of_keyboard_users == 1, Text:text("input.prompts.split_keyboard"), Text:text("input.prompts.unsplit_keyboard")) 
		
		-- SCOTCH SCOTCH SCOTCH SCOTCH SCOTCH SCOTCH SCOTCH SCOTCH !!!!!!
		-- TODO: create a "ButtonPrompt" object that can be reused in menus and other places
		local total_w = get_text_width(split_label) + icon_split_kb:getWidth()
		x = CANVAS_WIDTH/2 - total_w/2 + 2
		y = -16 + game.logo_y

		print_outline(COL_WHITE, COL_BLACK_BLUE, split_label, x + 2 + icon_split_kb:getWidth(), y)
		love.graphics.draw(icon_split_kb, x, y)
	end
end

function GameUI:draw_timer()
	if not Options:get("timer_on") then
		return
	end

	rect_color({0,0,0,0.5}, "fill", 0, 10, 50, 12)
	gfx.print(time_to_string(game.time), 8, 8)
end

function GameUI:draw_FPS()
	if not Options:get("show_fps_warning") then
		return
	end
	
	local t = "⚠ "..Text:text("game.fps", love.timer.getFPS())
	
	if game.t > 2 and love.timer.getFPS() <= 50 then
		print_outline(nil, nil, t, CANVAS_WIDTH - get_text_width(t) - 3, 3)
		-- if game.menu_manager.cur_menu ~= nil then
		-- 	t = "⚠ "..Text:text("game.fps_warning")
		-- 	print_outline(nil, nil, t, CANVAS_WIDTH - get_text_width(t) - 3, 3+get_text_height())
		-- end
	end
end

function GameUI:draw_offscreen_indicators()
	local cam_x, cam_y = self.game.camera:get_position()
	for i, player in pairs(self.game.players) do
		if (player.x + player.w < cam_x) or (cam_x + CANVAS_WIDTH < player.x) 
			or (player.y + player.h < cam_y) or (cam_y + CANVAS_HEIGHT < player.y) then 
			self:draw_offscreen_indicator_for(player)
		end
	end
end

function GameUI:draw_offscreen_indicator_for(player)
	-- local padding = 17
	local padding = 24
	local radius = 10
	
	local cam_x, cam_y = self.game.camera:get_position()
	local x = math.floor(clamp(player.mid_x - cam_x, padding, CANVAS_WIDTH - padding))
	local y = math.floor(clamp(player.mid_y - cam_y, padding, CANVAS_HEIGHT - padding))
	local rot = math.atan2(player.mid_y - (y + cam_y), player.mid_x - (x + cam_x))
	
	local scale = 0.5
	exec_color(player.skin.color_palette[3], function()
		draw_centered(images.offscreen_indicator, x+1, y, rot, scale, scale)
		draw_centered(images.offscreen_indicator, x-1, y, rot, scale, scale)
		draw_centered(images.offscreen_indicator, x, y+1, rot, scale, scale)
		draw_centered(images.offscreen_indicator, x, y-1, rot, scale, scale)
	end)
	exec_color(player.skin.color_palette[1], function()
		draw_centered(images.offscreen_indicator, x, y, rot, scale, scale)
	end)
	
	shaders.draw_in_color:sendColor("fillColor", player.skin.color_palette[4])
	exec_color(player.skin.color_palette[4], function()
		print_centered(player.skin.icon, x, y)
	end)
	print_centered_outline(player.skin.color_palette[1], player.skin.color_palette[4], Text:text("player.abbreviation", player.n), x, y - 16)
end

function GameUI:draw_stomp_arrow()
	if self.stomp_arrow_target and self.stomp_arrow_target.is_active then
		-- draw_centered(images.stomp_arrow, self.stomp_arrow_target.mid_x, self.stomp_arrow_target.y - 12)

		if self.stomp_arrow_target.is_removed then
			self:set_stomp_arrow_target(nil)
			Options:set("has_seen_stomp_tutorial", true)
		end
	end
end

function GameUI:set_stomp_arrow_target(target)
	if target and Options:get("has_seen_stomp_tutorial") then
		return
	end
	self.stomp_arrow_target = target
end

function GameUI:draw_floating_text()
	if #self.floating_text > 0 then
		print_centered_outline(nil, nil, self.floating_text, CANVAS_WIDTH/2, self.floating_text_y)
	end
end

function GameUI:get_upgrade_preview_position(i)
	local padding = 4
	local item_size = 20
	return CANVAS_WIDTH - padding - item_size/2 - item_size * (i-1)
end

function GameUI:draw_upgrades()
	local item_size = 20
	local i = 1
	local y = 4 + item_size/2
	for _, upgrade in pairs(game.upgrades) do
		local x = self:get_upgrade_preview_position(i)
		draw_centered(upgrade.sprite, x, y)
		i = i + 1
	end
end

function GameUI:draw_player_previews()
	for i, preview in pairs(self.player_previews) do
		preview:draw()
	end
end

function GameUI:on_player_joined(player)
	for i, preview in pairs(self.player_previews) do
		preview:on_player_joined(player)
	end
end

function GameUI:update_splash(dt)
	if self.splash_x < -CANVAS_WIDTH*2 then
		game.show_splash = false
	end
	self.splash_vx = self.splash_vx - dt*500
	self.splash_x = self.splash_x + self.splash_vx * dt
end

function GameUI:draw_splash_animation()
	if not game.show_splash then 
		return
	end
	love.graphics.draw(images.splash, self.splash_x, 0)
end

return GameUI