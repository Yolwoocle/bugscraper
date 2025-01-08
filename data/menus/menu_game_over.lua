require "scripts.util"
local menu_util = require "scripts.ui.menu.menu_util"
local Menu = require "scripts.ui.menu.menu"

local StatsMenuItem       = require "scripts.ui.menu.items.menu_item_stats"

local DEFAULT_MENU_BG_COLOR = menu_util.DEFAULT_MENU_BG_COLOR
local func_url          = menu_util.func_url
local PROMPTS_GAME_OVER = menu_util.PROMPTS_GAME_OVER

local game_over_items = {
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
    { "▶ {menu.game_over.continue}", function()
        -- scotch
        game.has_seen_controller_warning = true
        game:new_game()
    end },
    { "🔄 {menu.game_over.quick_restart}", function()
        game.has_seen_controller_warning = true
        game:new_game({quick_restart = true})
    end },
} 
if DEMO_BUILD then
    table.insert(game_over_items,
        { "❤ {menu.win.wishlist} 🔗", func_url("steam://advertise/2957130/") }
    )
end

return Menu:new(game, "{menu.game_over.title}", game_over_items, DEFAULT_MENU_BG_COLOR, PROMPTS_GAME_OVER)
