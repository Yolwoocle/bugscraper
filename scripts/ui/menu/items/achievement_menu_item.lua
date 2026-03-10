local TextMenuItem = require "scripts.ui.menu.items.text_menu_item"
local images       = require "data.images"
local shaders      = require "data.shaders"

local AchievementMenuItem = TextMenuItem:inherit()

function AchievementMenuItem:init(i, x, y, achievement)	
	local name = "{achievements."..achievement.name..".name}"
	AchievementMenuItem.super.init(self, i, x, y, name)

	self:set_label_text(name)
	self:set_value_text("")
	self.value = ""

	self.is_selectable = true
	self.description = Text:parse("{achievements."..achievement.name..".description}")
	
	self.achievement = achievement
	self.achievement_id = achievement.name
	self.image = images[achievement.image]

	self.granted = Achievements:is_achievement_granted(self.achievement_id)
end

function AchievementMenuItem:update(dt)
	AchievementMenuItem.super.update(self, dt)
	self.text_ox = 42
end

function AchievementMenuItem:on_set()
	AchievementMenuItem.super.on_set(self)

	self.granted = Achievements:is_achievement_granted(self.achievement_id)
end

function AchievementMenuItem:draw_text()
	AchievementMenuItem.super.draw_text(self)

	local x = game.menu_manager:get_menu_padding() + 16 + self.ox

	exec_color(COL_LIGHTEST_GRAY, function()
		Text:push_font(FONT_MINI)
		print_ycentered(self.description, x + self.text_ox, self.y + self.oy + self.text_oy + 16)
		Text:pop_font()
	end)

	local y = floor(self.y + self.oy - 8)

	
	if self.granted then
		rect_color(COL_WHITE, "fill", x-2, y-2, 36, 36)
		love.graphics.draw(self.image, x, y)
	else
		rect_color(COL_BLACK_BLUE, "fill", x-1, y-1, 34, 34)
		exec_using_shader(
			shaders.achievement_locked,
			function()
				love.graphics.draw(self.image, x, y)
			end
		)
		draw_centered(images.achievement_lock, x + 30, y + 30)
	end
end

function AchievementMenuItem:on_click()
	AchievementMenuItem.super.on_click()

	Achievements:grant(self.achievement_id)
end


return AchievementMenuItem