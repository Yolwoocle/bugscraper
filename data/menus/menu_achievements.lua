require "scripts.util"
local menu_util = require "scripts.ui.menu.menu_util"
local Menu = require "scripts.ui.menu.menu"
local achievements = require "data.achievements"
local AchievementMenuItem = require "scripts.ui.menu.items.achievement_menu_item"

local DEFAULT_MENU_BG_COLOR = menu_util.DEFAULT_MENU_BG_COLOR
local PROMPTS_NORMAL    = menu_util.PROMPTS_NORMAL

local items = {}

for _, achievement in pairs(achievements) do
    table.insert(items, { AchievementMenuItem, achievement })
    table.insert(items, { "" })
end

return Menu:new(game, "{menu.achievements.title}", items, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL, nil, {
    item_separation = 20
})