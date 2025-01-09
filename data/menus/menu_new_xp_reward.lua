require "scripts.util"
local menu_util             = require "scripts.ui.menu.menu_util"
local Menu                  = require "scripts.ui.menu.menu"
local images                = require "data.images"
local skins                 = require "data.skins"
local skin_name_to_id       = require "data.skin_name_to_id"

local StatsMenuItem         = require "scripts.ui.menu.items.menu_item_stats"
local ProgressBarMenuItem   = require "scripts.ui.menu.items.progress_bar_menu_item"

local DEFAULT_MENU_BG_COLOR = menu_util.DEFAULT_MENU_BG_COLOR
local func_url              = menu_util.func_url
local PROMPTS_GAME_OVER     = menu_util.PROMPTS_GAME_OVER


local NewXpRewardMenu = Menu:inherit()

function NewXpRewardMenu:init(game)
    NewXpRewardMenu.super.init(self, game, "", { { "" } }, DEFAULT_MENU_BG_COLOR, nil, nil)

    self.rewards = {}

    self.starburst_scale = 0
    self.starburst_color = COL_WHITE
    self.rot = 0

    self.center_image = images.empty
end

function NewXpRewardMenu:update(dt)
    NewXpRewardMenu.super.update(self, dt)

    self.rot = (self.rot + dt) % pi2
    self.starburst_scale = lerp(self.starburst_scale, 1, 0.2)
end

function NewXpRewardMenu:draw()
    NewXpRewardMenu.super.draw(self)

    local s = math.max(0, self.starburst_scale)
    exec_color(self.starburst_color, function()
        draw_centered(images.rays, CANVAS_CENTER[1], CANVAS_CENTER[2], self.rot, s)
    end)
    draw_centered(self.center_image, CANVAS_CENTER[1], CANVAS_CENTER[2], 0, s*2)

end

function NewXpRewardMenu:on_set()
    NewXpRewardMenu.super.on_set(self)

    self.starburst_scale = 0
end

function NewXpRewardMenu:set_rewards(rewards)
    self.rewards = rewards

    if #rewards > 0 then
        self:set_reward_graphics(rewards[1])
    end
end

function NewXpRewardMenu:set_reward_graphics(reward)
    if reward.type == "skin" then
        local skin = skins[reward.skin]
        if not skin then
            return
        end

        self.center_image = skin.img_walk_down
        self.starburst_color = skin.color_palette[1]
    else
    end
end

return NewXpRewardMenu
