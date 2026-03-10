local TextMenuItem = require "scripts.ui.menu.items.text_menu_item"
local images       = require "data.images"

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
	self.image = images[achievement.image]
end

function AchievementMenuItem:update(dt)
	AchievementMenuItem.super.update(self, dt)
	self.text_ox = 38
end

function AchievementMenuItem:draw_text()
	AchievementMenuItem.super.draw_text(self)

	exec_color(COL_LIGHTEST_GRAY, function()
		print_ycentered(self.description, game.menu_manager:get_menu_padding() + 16 + self.ox + self.text_ox, self.y + self.oy + self.text_oy + 16)
	end)

	local x = game.menu_manager:get_menu_padding() + 16 + self.ox
	love.graphics.draw(self.image, x, floor(self.y + self.oy - 6))
end

function AchievementMenuItem:on_click()
	AchievementMenuItem.super.on_click()
end


return AchievementMenuItem