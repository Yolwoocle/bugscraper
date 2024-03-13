local Menu = require "scripts.ui.menu.menu"
local SliderMenuItem = require "scripts.ui.menu.menu_item_slider"
local StatsMenuItem = require "scripts.ui.menu.menu_item_stats"
local ControlsMenuItem = require "scripts.ui.menu.menu_item_controls"

local function func_set_menu(menu)
	return function()
		game.menu_manager:set_menu(menu)
	end
end

local function func_url(url)
	return function()
		love.system.openURL(url)
	end
end

local DEFAULT_MENU_BG_COLOR = {0, 0, 0, 0.85}

local PROMPTS_NORMAL = {
    {{"ui_select"}, "confirm"},
    {{"ui_back"}, "back"},
}

local PROMPTS_GAME_OVER = {
    {{"ui_select"}, "confirm"},
    {},
}

local PROMPTS_CONTROLS = {
    {{"ui_select"}, "confirm"},
    {{"ui_reset_keys"}, "clear keys"},
    {{"ui_back"}, "back"},
}

-----------------------------------------------------
------ [[[[[[[[[[[[[[[[ MENUS ]]]]]]]]]]]]]]]] ------
-----------------------------------------------------

local function generate_menus()
    local menus = {}

    -- FIXME: This is messy, eamble multiple types of menuitems
    -- This is so goddamn overengineered and needlessly complicated
    menus.title = Menu:new(game, {
        { ">>>> ELEVATOR DITCH (logo here) <<<<" },
        -- {"********** PAUSED **********"},
        { "" },
        { "PLAY", function() game:new_game() end },
        { "OPTIONS", func_set_menu('options') },
        { "QUIT", quit_game },
        { "" },
        { "" },
    }, DEFAULT_MENU_BG_COLOR)

    menus.pause = Menu:new(game, {
        { "<<<<<<<<< PAUSED >>>>>>>>>" },
        { "" },
        { "RESUME", function() game.menu_manager:unpause() end },
        { "RETRY", function() game:new_game() end },
        { "OPTIONS", func_set_menu('options') },
        { "CREDITS", func_set_menu('credits') },
        { "QUIT", quit_game },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)
    if OPERATING_SYSTEM == "Web" then
        -- Disable quitting on web
        menus.pause.items[7].is_selectable = false
    end

    menus.options = Menu:new(game, {
        { "<<<<<<<<< OPTIONS >>>>>>>>>" },
        { "" },
        { "<<< Controls >>>" },
        { "KEYBOARD SETTINGS", func_set_menu("controls_keyboard")},
        { "CONTROLLER SETTINGS", func_set_menu("controls_controller")},
        { ""},
        { "<<< Audio >>>" },
        { "SOUND", function(self, option)
            Options:toggle_sound()
        end,
        function(self)
            self.value = Options:get("sound_on")
            self.value_text = Options:get("sound_on") and "ON" or "OFF"
        end},
        { SliderMenuItem, "VOLUME", function(self, diff)
            diff = diff or 1
            self.value = (self.value + diff)
            if self.value < 0 then self.value = 20 end
            if self.value > 20 then self.value = 0 end
            
            Options:set_volume(self.value/20)
            Audio:play("menu_select", nil, 0.8+(self.value/20)*0.4)
        end, range_table(0,20),
        function(self)
            self.value = Options:get("volume") * 20
            self.value_text = concat(floor(100 * self.value / 20), "%")

            self.is_selectable = Options:get("sound_on")
        end},
        { SliderMenuItem, "MUSIC VOLUME", function(self, diff)
            diff = diff or 1
            self.value = (self.value + diff)
            if self.value < 0 then self.value = 20 end
            if self.value > 20 then self.value = 0 end
            
            Options:set_music_volume(self.value/20)
            Audio:play("menu_select", (self.value/20), 0.8+(self.value/20)*0.4)
        end, range_table(0,20),
        function(self)
            self.value = Options:get("music_volume") * 20
            self.value_text = concat(floor(100 * self.value / 20), "%")

            self.is_selectable = Options:get("sound_on")
        end},
        { "MUSIC ON PAUSE MENU", function(self, option)
            Options:toggle_play_music_on_pause_menu()
            if Options:get("play_music_on_pause_menu") then
                game.music_player:play()
            end
        end,
        function(self)
            self.value = Options:get("play_music_on_pause_menu")
            self.value_text = Options:get("play_music_on_pause_menu") and "ON" or "OFF"
            self.is_selectable = Options:get("sound_on")
        end},
        { "BACKGROUND SOUNDS", function(self, option)
            Options:toggle_background_noise()
        end,
        function(self)
            self.value = Options:get("disable_background_noise")
            self.value_text = (not Options:get("disable_background_noise")) and "ON" or "OFF"
            self.is_selectable = Options:get("sound_on")
        end},
        {""},

        -- {"MUSIC: [ON/OFF]", function(self)
        -- 	game:toggle_sound()
        -- end},
        { "<<< Visuals >>>"},
        { "FULLSCREEN", function(self)
            Options:toggle_fullscreen()
        end,
        function(self)
            self.value = Options:get("is_fullscreen")
            self.value_text = Options:get("is_fullscreen") and "ON" or "OFF"
        end},

        { SliderMenuItem, "PIXEL SCALE", function(self, diff)
            diff = diff or 1
            self:next_value(diff)

            local scale = self.value
            
            Audio:play("menu_select")
            Options:set_pixel_scale(scale)
        end, { "auto", "max whole", 1, 2, 3, 4, 5, 6}, function(self)
            self.value = Options:get("pixel_scale")
            self.value_text = tostring(Options:get("pixel_scale"))

            if OPERATING_SYSTEM == "Web" then  self.is_selectable = false  end
        end},

        { "VERTICAL SYNC", function(self)
            Options:toggle_vsync()
        end,
        function(self)
            self.value = Options:get("is_vsync")
            self.value_text = Options:get("is_vsync") and "ON" or "OFF"
        end},
        { ""},
        { "<<< Game >>>"},
        { "TIMER", function(self)
            Options:toggle_timer()
        end,
        function(self)
            self.value = Options:get("timer_on")
            self.value_text = Options:get("timer_on") and "ON" or "OFF"
        end},

        { "SHOW MOUSE CURSOR", function(self)
            Options:toggle_mouse_visible()
            love.mouse.setVisible(Options:get("mouse_visible"))
        end,
        function(self)
            self.value = Options:get("mouse_visible")
            self.value_text = Options:get("mouse_visible") and "ON" or "OFF"
        end},
        
        { "PAUSE ON LOST FOCUS", function(self)
            Options:toggle_pause_on_unfocus()
            love.mouse.setVisible(Options:get("pause_on_unfocus"))
        end,
        function(self)
            self.value = Options:get("pause_on_unfocus")
            self.value_text = Options:get("pause_on_unfocus") and "ON" or "OFF"
        end},
        
        -- { "SCREENSHAKE", function(self)
        --     Options:toggle_screenshake()
        --     love.mouse.setVisible(Options:get("screenshake_on"))
        -- end,
        -- function(self)
        --     self.value = Options:get("screenshake_on")
        --     self.value_text = Options:get("screenshake_on") and "ON" or "OFF"
        -- end},
        { SliderMenuItem, "SCREENSHAKE", function(self, diff)
            diff = diff or 1
            self.value = (self.value + diff)
            if self.value < 0 then self.value = 20 end
            if self.value > 20 then self.value = 0 end
            
            Options:set_screenshake(self.value/20)
            Audio:play("menu_select", 1.0, 0.8+(self.value/20)*0.4)
        end, range_table(0,20),
        function(self)
            self.value = Options:get("screenshake") * 20
            self.value_text = concat(floor(100 * self.value / 20), "%")
        end},
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    menus.controls_keyboard = Menu:new(game, {
        { "<<<<<<<<< CONTROLS >>>>>>>>>" },
        { "" },
        { "RESET CONTROLS", function() Input:reset_controls(1, "k") end },
        { "" },
        { "<<< Gameplay >>>" },
        { ControlsMenuItem, 1, "k", "left" },
        { ControlsMenuItem, 1, "k", "right" },
        { ControlsMenuItem, 1, "k", "up" },
        { ControlsMenuItem, 1, "k", "down" },
        { ControlsMenuItem, 1, "k", "jump" },
        { ControlsMenuItem, 1, "k", "shoot" },
        { "" },
        { "<<< Interface >>>" },
        { "At least one binding is required" },
        { ControlsMenuItem, 1, "k", "ui_left" },
        { ControlsMenuItem, 1, "k", "ui_right" },
        { ControlsMenuItem, 1, "k", "ui_up" },
        { ControlsMenuItem, 1, "k", "ui_down" },
        { ControlsMenuItem, 1, "k", "ui_select" },
        { ControlsMenuItem, 1, "k", "ui_back" },
        { ControlsMenuItem, 1, "k", "pause" },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_CONTROLS)

    menus.controls_controller = Menu:new(game, {
        { "<<<<<<<<< CONTROLS >>>>>>>>>" },
        { "" },
        { "RESET CONTROLS", function() Input:reset_controls(1, "c") end },
        { SliderMenuItem, "BUTTON STYLE", function(self, diff)
            diff = diff or 1
            self:next_value(diff)
            Options:set_button_style(1, self.value)
            Audio:play("menu_select", 1.0)
        end, BUTTON_STYLES,
        function(self)
            self.value = Options:get("button_style_p1")
            self.value_text = concat(self.value)
        end},
        { "" },
        { "<<< Gameplay >>>" },
        { ControlsMenuItem, 1, "c", "left"},
        { ControlsMenuItem, 1, "c", "right"},
        { ControlsMenuItem, 1, "c", "up"},
        { ControlsMenuItem, 1, "c", "down"},
        { ControlsMenuItem, 1, "c", "jump"},
        { ControlsMenuItem, 1, "c", "shoot"},
        { ""},
        { "<<< Interface >>>" },
        { "At least one binding is required" },
        { ControlsMenuItem, 1, "c", "ui_left"},
        { ControlsMenuItem, 1, "c", "ui_right"},
        { ControlsMenuItem, 1, "c", "ui_up"},
        { ControlsMenuItem, 1, "c", "ui_down"},
        { ControlsMenuItem, 1, "c", "ui_select"},
        { ControlsMenuItem, 1, "c", "ui_back"},
        { ControlsMenuItem, 1, "c", "pause"},

    }, DEFAULT_MENU_BG_COLOR, PROMPTS_CONTROLS)

    menus.game_over = Menu:new(game, {
        {"<<<<<<<<< GAME OVER! >>>>>>>>>"},
        { "" },
        { StatsMenuItem, "Kills", function(self) return game.stats.kills end },
        { StatsMenuItem, "Time",  function(self)
            return time_to_string(game.stats.time)
        end },
        { StatsMenuItem, "Floor", function(self) return concat(game.stats.floor, "/", game.elevator.max_floor) end },
        { StatsMenuItem, "Max combo", function(self) return concat(game.stats.max_combo) end },
        { "" },
        { "RETRY", function() game:new_game() end },
        { "" },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_GAME_OVER)

    menus.credits = Menu:new(game, {
        {"<<<<<<<<< CREDITS >>>>>>>>>"},
        { "" },
        { "<<< Design, programming & art >>>"},
        { "Léo Bernard (Yolwoocle)", func_url("https://twitter.com/yolwoocle_")},
        { "" },
        { "<<< Music >>>"},
        { "OLX", func_url("https://www.youtube.com/@olx1831")},
        -- { "'Galaxy Trip' by Raphaël Marcon / CC BY 4.0", func_url("https://raphytator.itch.io/")},
        { ""},
        { "<<< Special Thanks >>>"},
        { "Gouspourd", func_url("https://gouspourd.itch.io/")},
        { "Louie Chapman", func_url("https://louiechapm.itch.io/") },
        { "Raphaël Marcon", func_url("https://raphytator.itch.io/") },
        { "hades140701", function() end },
        -- { "SmellyFishstiks", func_url("https://www.lexaloffle.com/bbs/?uid=42184") },
        { "LÖVE Engine", func_url("https://love2d.org/") },
        { ""},
        { "<<< Asset creators >>>"},
        { "Kenney", func_url("https://kenney.nl/")},
        -- { "'Hope Gold' font by somepx / CSL", func_url("https://somepx.itch.io/")},
        { "somepx", func_url("https://somepx.itch.io/")},
        { "amhuo", func_url("https://emhuo.itch.io/")},
        { "freesound.org [see more...]", func_set_menu("credits_sounds")},
        { ""},
        { "<< Asset Licenses >>"},
        { "CC0", func_url("https://creativecommons.org/publicdomain/zero/1.0/")},
        { "CC BY 3.0", func_url("https://creativecommons.org/licenses/by/3.0/")},
        { "CC BY 4.0", func_url("https://creativecommons.org/licenses/by/4.0/")},
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    menus.credits_sounds = Menu:new(game, {
        {"<<< freesound.org credits >>>"},
        {""},
        { "'jf Glass Breaking.wav' by cmusounddesign / CC BY 3.0", func_url("https://freesound.org/people/cmusounddesign/sounds/85168/")},
        { "'Glass Break' by avrahamy / CC0", func_url("https://freesound.org/people/avrahamy/sounds/141563/")},
        { "'Glass shard tinkle texture' by el-bee / CC BY 4.0", func_url("https://freesound.org/people/el-bee/sounds/636238/")},
        { "'Bad Beep (Incorrect)' by RICHERlandTV / CC BY 3.0", func_url("https://freesound.org/people/RICHERlandTV/sounds/216090/")},
        { "[Keyboard press] by MattRuthSound / CC BY 3.0", func_url("https://freesound.org/people/MattRuthSound/sounds/561661/")},
        { "'Paper Throw Into Air(fuller) 2' by RossBell / CC0", func_url("https://freesound.org/people/RossBell/sounds/389442/")},
        { "'Slime' by Lukeo135 / CC0", func_url("https://freesound.org/people/Lukeo135/sounds/530617/")},
        { "'brushes_on_snare' by Heigh-hoo / CC0", func_url("https://freesound.org/people/Heigh-hoo/sounds/20297/")},
        { "'01 Elevator UP' by soundslikewillem / CC BY 4.0", func_url("https://freesound.org/people/soundslikewillem/sounds/340747/")},
        { "'indsustrial_elevator_door_open' by joedeshon / CC BY 4.0", func_url("https://freesound.org/people/joedeshon/sounds/368737/")},
        { "'indsustrial_elevator_door_close' by joedeshon / CC BY 4.0", func_url("https://freesound.org/people/joedeshon/sounds/368738/")},
        { "'Footsteps on gravel' by Joozz / CC BY 4.0", func_url("https://freesound.org/people/Joozz/sounds/531952/")},
        { "'THE CRASH' by sandyrb / CC BY 4.0", func_url("https://freesound.org/people/sandyrb/sounds/95078/")},
        { "'Door slam - Gun shot' by coolguy244e / CC BY 4.0", func_url("https://freesound.org/people/coolguy244e/sounds/266915/")},
        { "'bee fly' by soundmary / CC BY 4.0", func_url("https://freesound.org/people/soundmary/sounds/194932/")},
        { "'Pop, Low, A (H1)' by InspectorJ / CC BY 4.0", func_url("https://freesound.org/people/InspectorJ/sounds/411639/")},
        { "'Crack 1' by JustInvoke / CC BY 3.0", func_url("https://freesound.org/people/JustInvoke/sounds/446118/")},
        { "'Emergency Siren' by onderwish / CC0", func_url("https://freesound.org/people/onderwish/sounds/470504/")},
        { "'Wood burning in the stove' by smand / CC0", func_url("https://freesound.org/people/smand/sounds/521118/")},
        { "'Bike falling down an escalator' by dundass / CC BY 3.0", func_url("https://freesound.org/people/dundass/sounds/509831/")},
        { "'squishing and squeezing a wet sponge in a bowl' by breadparticles / CC0", func_url("https://freesound.org/people/breadparticles/sounds/575332/#comments")},
        { "'Insect Bug Smash & Crush' by EminYILDIRIM / CC BY 4.0", func_url("https://freesound.org/people/EminYILDIRIM/sounds/570767/")},
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    local items = {
        { "<<<<<<<<< CONGRATULATIONS! >>>>>>>>>" },
        { "" },
        { StatsMenuItem, "Kills", function(self) return game.stats.kills end },
        { StatsMenuItem, "Time",  function(self)
            return time_to_string(game.stats.time)
        end },
        { StatsMenuItem, "Floor", function(self) return game.stats.floor end },
        { ""},
        { "NEW GAME", function() game:new_game() end },
        -- { "CREDITS", func_set_menu('credits') },
        { "QUIT", quit_game },
        { "" },
    }
    if OPERATING_SYSTEM == "Web" or true then
        table.remove(items, 8)
    end
    menus.win = Menu:new(game, items, { 0, 0, 0, 0.95 }, PROMPTS_GAME_OVER)

    return menus
end

return generate_menus