require "scripts.util"
local menu_util = require "scripts.ui.menu.menu_util"
local Menu = require "scripts.ui.menu.menu"

local RangeOptionMenuItem = require "scripts.ui.menu.items.range_option_menu_item"
local BoolOptionMenuItem  = require "scripts.ui.menu.items.bool_option_menu_item"
local EnumOptionMenuItem  = require "scripts.ui.menu.items.enum_option_menu_item"

local DEFAULT_MENU_BG_COLOR = menu_util.DEFAULT_MENU_BG_COLOR
local func_set_menu     = menu_util.func_set_menu
local PROMPTS_NORMAL    = menu_util.PROMPTS_NORMAL

local items = {}
table.insert(items, { "🌐 {menu.options.game.language}", func_set_menu("options_language") })
table.insert(items, { "" })
table.insert(items, { "<<< {menu.options.input.title} >>>" })
table.insert(items, { "🔘 {menu.options.input.input}", func_set_menu("options_input") })
table.insert(items, { "" })
table.insert(items, { "<<< {menu.options.audio.title} >>>" })
table.insert(items, { BoolOptionMenuItem, "🔊 {menu.options.audio.sound}", "sound_on" })
table.insert(items, { 
    RangeOptionMenuItem, "🔉 {menu.options.audio.volume}", "volume", { 0.0, 1.0 }, 0.05, "%",
        function(self)
            self.is_selectable = Options:get("sound_on")
        end
    }
)
table.insert(items, { 
    RangeOptionMenuItem, "  🔈 {menu.options.audio.sfx_volume}", "sfx_volume", { 0.0, 1.0 }, 0.05, "%",
        function(self)
            self.is_selectable = Options:get("sound_on")
        end
    }
)
table.insert(items, { 
    RangeOptionMenuItem, "  🎵 {menu.options.audio.music_volume}", "music_volume", { 0.0, 1.0 }, 0.05, "%",
        function(self)
            self.is_selectable = Options:get("sound_on")
        end
    }
)
table.insert(items, { 
    BoolOptionMenuItem, "🔊 {menu.options.audio.ambience}", "ambience_on", 
        function(self)
            self.is_selectable = Options:get("sound_on")
        end 
    }
)
table.insert(items, { 
    BoolOptionMenuItem, "🎼 {menu.options.audio.music_pause_menu}", "play_music_on_pause_menu",
        function(self)
            self.is_selectable = Options:get("sound_on")
        end
    }
)
table.insert(items, { "" })
table.insert(items, { "<<< {menu.options.visuals.title} >>>" })

if PLATFORM_TYPE ~= "mobile" then
    table.insert(items, { BoolOptionMenuItem, "🔳 {menu.options.visuals.fullscreen}", "is_fullscreen" })
    table.insert(items, { EnumOptionMenuItem, "🔲 {menu.options.visuals.pixel_scale}", "pixel_scale", { "auto", "max_whole", "1", "2", "3", "4", "5", "6" },
            function(value)
                if tonumber(value) then
                    return tostring(value)
                else
                    return tostring(Text:text("menu.options.visuals.pixel_scale_value." .. value))
                end
            end,
            function(self)
                if OPERATING_SYSTEM == "Web" then
                    self.is_selectable = false
                end
            end
        }
    )
    table.insert(items, { BoolOptionMenuItem, "📺 {menu.options.visuals.vsync}", "is_vsync" })
end
table.insert(items, { BoolOptionMenuItem, "💧 {menu.options.visuals.menu_blur}", "menu_blur" })
table.insert(items, { RangeOptionMenuItem, "🌄 {menu.options.visuals.background_speed}", "background_speed", { 0.0, 1.0 }, 0.05, "%" })
table.insert(items, { RangeOptionMenuItem, "🥚 {menu.options.visuals.bullet_lightness}", "bullet_lightness", { 0.1, 1.0 }, 0.1, "%" })
table.insert(items, { 
    EnumOptionMenuItem, "☁ {menu.options.visuals.scale_filter}", "scale_filter", { "crisp", "smooth" },
    function(value)
        return tostring(Text:text("menu.options.visuals.scale_filter_value." .. value))
    end,
})

table.insert(items, { "" })
table.insert(items, { "<<< {menu.options.game.title} >>>" })
table.insert(items, { "🎓 {menu.options.game.tutorial}", func_set_menu("confirm_tutorial") }) 
table.insert(items, { 
    RangeOptionMenuItem, "🛜 {menu.options.game.screenshake}", "screenshake", { 0.0, 2.0 }, 0.05, function(value)
        if value == 2.0 then
            return "Vlambeer"
        end
		return string.format("%d%%", round(value * 100)) 
	end }
)
table.insert(items, { BoolOptionMenuItem, "🕐 {menu.options.game.timer}", "timer_on" })

-- if PLATFORM_TYPE == "pc" or PLATFORM_TYPE == "web" then
    table.insert(items, { BoolOptionMenuItem, "↖ {menu.options.game.mouse_visible}", "mouse_visible" })
    table.insert(items, { BoolOptionMenuItem, "🛅 {menu.options.game.pause_on_unfocus}", "pause_on_unfocus" })
-- end

table.insert(items, { BoolOptionMenuItem, "⏭ {menu.options.game.skip_boss_intros}", "skip_boss_intros" })
table.insert(items, { BoolOptionMenuItem, "⚠ {menu.options.game.show_fps_warning}", "show_fps_warning" })
    -- { BoolOptionMenuItem, "⚠ convention_mode", "convention_mode" },

return Menu:new(game, "{menu.options.title}", items, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)