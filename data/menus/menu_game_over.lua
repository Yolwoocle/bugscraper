require "scripts.util"
local menu_util             = require "scripts.ui.menu.menu_util"
local Menu                  = require "scripts.ui.menu.menu"

local StatsMenuItem         = require "scripts.ui.menu.items.menu_item_stats"
local ProgressBarMenuItem   = require "scripts.ui.menu.items.progress_bar_menu_item"

local DEFAULT_MENU_BG_COLOR = menu_util.DEFAULT_MENU_BG_COLOR
local func_url              = menu_util.func_url
local PROMPTS_GAME_OVER     = menu_util.PROMPTS_GAME_OVER

local game_over_items       = {
    { "" },
    { "" },
    { StatsMenuItem, Text:text("menu.game_over.kills"), function(self)
        return
            game.stats.kills
    end },
    { StatsMenuItem, Text:text("menu.game_over.time"), function(self)
        return time_to_string(game.stats.time)
    end },
    { StatsMenuItem, Text:text("menu.game_over.floor"), function(self)
        return concat(game.stats.floor, "/",
            game.level.max_floor)
    end },
    { StatsMenuItem, Text:text("menu.game_over.score"), function(self)
        return concat(game.stats.score)
    end },
    -- { StatsMenuItem, Text:text("menu.game_over.max_combo"), function(self) return concat(game.stats.max_combo) end },
    { "" },
    { ProgressBarMenuItem,
        {
            update_value = function(item, dt)
                item.augment_xp_delay = math.max(0, item.augment_xp_delay - dt)

                local actual_level = Metaprogression:get_xp_level()
                local shown_level_threshold = Metaprogression:get_xp_level_threshold(item.shown_level)

                local value_target
                if shown_level_threshold == math.huge then
                    value_target = 1
                    shown_level_threshold = 1
                    item.value = 1
                elseif actual_level > item.shown_level then
                    value_target = 1
                else
                    value_target = Metaprogression:get_xp() / shown_level_threshold
                end

                if math.abs(item.value - 1) < 0.01 and actual_level > item.shown_level then
                    -- New level!!
                    item.value = 0
                    item.overlay_value = nil
                    item.shown_level = item.shown_level + 1
                    item.augment_xp_delay = 0.5

                    local reward_info = Metaprogression:get_xp_level_info(item.shown_level - 1)
                    if reward_info then
                        game.menu_manager.menus["new_xp_reward"]:set_rewards(reward_info.rewards)
                        game.menu_manager:set_menu("new_xp_reward")
                    end
                end

                local old_value = item.value * shown_level_threshold
                if item.augment_xp_delay <= 0 then
                    item.value = lerp(item.value, value_target, 0.1)
                end

                if math.floor(item.value * shown_level_threshold / 5) * 5 > math.floor(old_value / 5) * 5 then
                    Audio:play("xp_tick", 1, lerp(1 - item.value, 0.5, 1.5))
                end

                local shown_xp = round(item.value * shown_level_threshold)
                item.text = concat(shown_xp, "/", shown_level_threshold)
                if shown_level_threshold == math.huge then
                    item.text = concat(shown_xp)
                end
            end, 
            init_value = function(item)
                local threshold = Metaprogression:get_xp_level_threshold(Metaprogression.old_xp_level)
                item.value = Metaprogression.old_xp / threshold
                item.overlay_value = item.value
                item.shown_level = Metaprogression.old_xp_level

                if threshold == math.huge then
                    item.overlay_value = nil
                    item.value = 1
                end

                item.augment_xp_delay = 0.5
            end
        }
    },
    { "" },
    { "▶ {menu.game_over.continue}", function()
        -- scotch
        game.has_seen_controller_warning = true
        game:new_game()
    end },
    { "🔄 {menu.game_over.quick_restart}", function()
        game.has_seen_controller_warning = true
        game:new_game({ quick_restart = true })
    end },
}
if DEMO_BUILD then
    table.insert(game_over_items,
        { "❤ {menu.win.wishlist} 🔗", func_url("steam://advertise/2957130/") }
    )
end

local game_over_menu = Menu:new(game, "{menu.game_over.title}", game_over_items, DEFAULT_MENU_BG_COLOR, PROMPTS_GAME_OVER, nil)

return game_over_menu
