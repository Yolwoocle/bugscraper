local Menu = require "scripts.ui.menu.menu"
local SliderMenuItem = require "scripts.ui.menu.menu_item_slider"
local StatsMenuItem = require "scripts.ui.menu.menu_item_stats"
local ControlsMenuItem = require "scripts.ui.menu.menu_item_controls"
local CustomDrawMenuItem = require "scripts.ui.menu.menu_item_custom_draw"
local waves = require "data.waves"
local Enemies = require "data.enemies"

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

local function draw_elevator_progress()
    local pad_x = 80
    local pad_y = 50
    local x1, y1 = CANVAS_WIDTH - pad_x, pad_y
    local x2, y2 = CANVAS_WIDTH - pad_x, CANVAS_HEIGHT - pad_y
    
    local end_w = 5
    love.graphics.rectangle("fill", x1 - end_w/2, y1 - end_w, end_w, end_w)
    love.graphics.rectangle("fill", x2 - end_w/2, y2, end_w, end_w)
    love.graphics.line(x1, y1, x2, y2)
    
    local n_floors = game.elevator.max_floor
    local sep_w = 3
    local h = y2 - y1
    for i = 1, n_floors-1 do
        local y = y2 - (i/n_floors) * h
        local sep_x = x1 - sep_w/2
        local sep_y = round(y - sep_w/2)
        love.graphics.rectangle("fill", sep_x, sep_y, sep_w, sep_w)
        if i == game.floor then
            love.graphics.rectangle("line", sep_x-2, sep_y-1, sep_w+3, sep_w+3)
        end
    end

    local text = concat(game.floor,"/",game.elevator.max_floor)
    local text_y = clamp(y2 - (game.floor/n_floors) * h, y1, y2)
    love.graphics.print(text, x1- get_text_width(text) - 5, text_y- get_text_height(text)/2-2)
end


local function removeme_draw_waves(self)
    local x = self.x - CANVAS_WIDTH/2
    local y = self.y
    local slot_w = 25
    local slot_h = 10
    for i, wave in ipairs(waves) do
        love.graphics.print(concat("W", i, " ",wave.min, "-", wave.max), x, y)
        x = x + 50

        local total_w = slot_w * (wave.min + wave.max)/2
        love.graphics.rectangle("fill", x, y, total_w, 10)
        local weight_sum = 0
        for j, enemy in ipairs(wave.enemies) do
            weight_sum = weight_sum + enemy[2]
        end

        for j, enemy in ipairs(wave.enemies) do
            local e = enemy[1]:new()
            local spr = e.spr
            e:remove()

            local weight = enemy[2] 

            love.graphics.setColor(REMOVEME_image_to_col[spr] or ternary(j % 2 == 0, COL_WHITE, COL_RED))
            local w = total_w * (weight/weight_sum)
            love.graphics.rectangle("fill", x, y, w, 10)
            love.graphics.setColor(COL_WHITE)

            love.graphics.draw(spr, x, y, 0, 0.8, 0.8)
            print_outline(COL_WHITE, COL_BLACK_BLUE, concat(weight), x, y)
            x = x + w
        end
        x = self.x - CANVAS_WIDTH/2
        y = y + 24
    end
end

-----------------------------------------------------
------ [[[[[[[[[[[[[[[[ MENUS ]]]]]]]]]]]]]]]] ------
-----------------------------------------------------

local function generate_menus()
    local menus = {}

    -- FIXME: This is messy, eamble multiple types of menuitems
    -- This is so goddamn overengineered and needlessly complicated
    menus.title = Menu:new(game, {
        { ">>>> Bugscraper (logo here) <<<<" },
        { "" },
        { "PLAY", function() game:new_game() end },
        { "OPTIONS", func_set_menu('options') },
        { "QUIT", quit_game },
        { "" },
        { "" },
    }, DEFAULT_MENU_BG_COLOR)

    menus.view_waves = Menu:new(game, {
        {"waves"},
        {CustomDrawMenuItem, removeme_draw_waves},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
        {"", function() end},
    }, DEFAULT_MENU_BG_COLOR, {}, function()
    end)

    menus.pause = Menu:new(game, {
        { "<<<<<<<<< PAUSED >>>>>>>>>" },
        { "" },
        { "RESUME", function() game.menu_manager:unpause() end },
        { "RETRY", function() game:new_game() end },
        { "OPTIONS", func_set_menu('options') },
        { "CREDITS", func_set_menu('credits' ) },
        -- { "CREDITS", func_set_menu('view_waves' ) },
        { "QUIT", quit_game },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL, draw_elevator_progress)
    if OPERATING_SYSTEM == "Web" then
        -- Disable quitting on web
        menus.pause.items[7].is_selectable = false
    end

    menus.options = Menu:new(game, {
        { "<<<<<<<<< OPTIONS >>>>>>>>>" },
        { "" },
        { "<<< Controls >>>" },
        { "INPUT SETTINGS...", func_set_menu("options_input")},
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
    
    menus.options_input = Menu:new(game, {
        { "<<<<<<<<< INPUT SETTINGS >>>>>>>>>" },
        { "" },
        { "<<< Keyboard >>>" },
        { "KEYBOARD (Default)", func_set_menu("controls_keyboard_solo")},
        { "KEYBOARD (Split 1)", func_set_menu("controls_keyboard_split_p1")},
        { "KEYBOARD (Split 2)", func_set_menu("controls_keyboard_split_p2")},
        { "" },
        { "<<< Gamepad >>>" },
        { "GAMEPAD 1", func_set_menu("controls_controller_p1")},
        { "GAMEPAD 2", func_set_menu("controls_controller_p2")},
        { "GAMEPAD 3", func_set_menu("controls_controller_p3")},
        { "GAMEPAD 4", func_set_menu("controls_controller_p4")},
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    local function create_keyboard_controls_menu(title, input_profile_id)
        return Menu:new(game, {
            { "<<<<<<<<< "..title.." >>>>>>>>>" },
            { "" },
            { "RESET CONTROLS", function() Input:reset_controls(input_profile_id, "k") end },
            { "" },
            { "<<< Gameplay >>>" },
            { ControlsMenuItem, -1, input_profile_id, "k", "left",  "LEFT" },
            { ControlsMenuItem, -1, input_profile_id, "k", "right", "RIGHT" },
            { ControlsMenuItem, -1, input_profile_id, "k", "up",    "UP" },
            { ControlsMenuItem, -1, input_profile_id, "k", "down",  "DOWN" },
            { ControlsMenuItem, -1, input_profile_id, "k", "jump",  "JUMP" },
            { ControlsMenuItem, -1, input_profile_id, "k", "shoot", "SHOOT" },
            { "" },
            { "<<< Interface >>>" },
            { "At least one binding is required" },
            { ControlsMenuItem, -1, input_profile_id, "k", "ui_left",    "MENU LEFT" },
            { ControlsMenuItem, -1, input_profile_id, "k", "ui_right",   "MENU RIGHT" },
            { ControlsMenuItem, -1, input_profile_id, "k", "ui_up",      "MENU UP" },
            { ControlsMenuItem, -1, input_profile_id, "k", "ui_down",    "MENU DOWN" },
            { ControlsMenuItem, -1, input_profile_id, "k", "ui_select",  "SELECT" },
            { ControlsMenuItem, -1, input_profile_id, "k", "ui_back",    "BACK" },
            { ControlsMenuItem, -1, input_profile_id, "k", "pause",      "PAUSE" },
            { ControlsMenuItem, -1, input_profile_id, "k", "leave_game", "LEAVE GAME" },
        }, DEFAULT_MENU_BG_COLOR, PROMPTS_CONTROLS)
    end

    local function create_controller_controls_menu(title, input_profile_id, player_n)
        return Menu:new(game, {
            { "<<<<<<<<< "..title.." >>>>>>>>>" },
            { "", nil,
            function(self) 
                local user = Input:get_user(player_n)
                if user == nil then  
                    self.label_text = "[NO PLAYER "..tostring(player_n).."]"
                    return
                end
                local joystick = user.joystick
                if joystick ~= nil then
                    self.label_text = "\""..joystick:getName().."\""
                else
                    self.label_text = "[NO GAMEPAD CONNECTED]"
                end
            end},
            { "" },
            { "RESET CONTROLS", function() Input:reset_controls(input_profile_id, "c") end },
            { SliderMenuItem, "BUTTON STYLE", function(self, diff)
                diff = diff or 1
                self:next_value(diff)
                Options:set_button_style(player_n, self.value)
                Audio:play("menu_select", 1.0)
            end, BUTTON_STYLES,
            function(self)
                self.value = Options:get("button_style_p"..tostring(player_n))
                self.value_text = concat(self.value)
            end},
            { "" },
            { "<<< Gameplay >>>" },
            { ControlsMenuItem, player_n, input_profile_id, "c", "left",  "LEFT"},
            { ControlsMenuItem, player_n, input_profile_id, "c", "right", "RIGHT"},
            { ControlsMenuItem, player_n, input_profile_id, "c", "up",    "UP"},
            { ControlsMenuItem, player_n, input_profile_id, "c", "down",  "DOWN"},
            { ControlsMenuItem, player_n, input_profile_id, "c", "jump",  "JUMP"},
            { ControlsMenuItem, player_n, input_profile_id, "c", "shoot", "SHOOT"},
            { ""},
            { "<<< Interface >>>" },
            { "At least one binding is required" },
            { ControlsMenuItem, player_n, input_profile_id, "c", "ui_left",    "MENU LEFT"},
            { ControlsMenuItem, player_n, input_profile_id, "c", "ui_right",   "MENU RIGHT"},
            { ControlsMenuItem, player_n, input_profile_id, "c", "ui_up",      "MENU UP"},
            { ControlsMenuItem, player_n, input_profile_id, "c", "ui_down",    "MENU DOWN"},
            { ControlsMenuItem, player_n, input_profile_id, "c", "ui_select",  "SELECT" },
            { ControlsMenuItem, player_n, input_profile_id, "c", "ui_back",    "BACK" },
            { ControlsMenuItem, player_n, input_profile_id, "c", "pause",      "PAUSE" },
            { ControlsMenuItem, player_n, input_profile_id, "c", "leave_game", "LEAVE GAME" },
    
        }, DEFAULT_MENU_BG_COLOR, PROMPTS_CONTROLS)
    end
    
    menus.controls_keyboard_solo =     create_keyboard_controls_menu("KEYBOARD SETTINGS (Default)", "keyboard_solo")
    menus.controls_keyboard_split_p1 = create_keyboard_controls_menu("KEYBOARD SETTINGS (Split 1)", "keyboard_split_p1")
    menus.controls_keyboard_split_p2 = create_keyboard_controls_menu("KEYBOARD SETTINGS (Split 2)", "keyboard_split_p2")
    menus.controls_controller_p1 =     create_controller_controls_menu("GAMEPAD SETTINGS (Player 1)", "controller_1", 1)
    menus.controls_controller_p2 =     create_controller_controls_menu("GAMEPAD SETTINGS (Player 2)", "controller_2", 2)
    menus.controls_controller_p3 =     create_controller_controls_menu("GAMEPAD SETTINGS (Player 3)", "controller_3", 3)
    menus.controls_controller_p4 =     create_controller_controls_menu("GAMEPAD SETTINGS (Player 4)", "controller_4", 4)

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
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_GAME_OVER, draw_elevator_progress)

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
        { "<<< Playtesting >>>"},
        { "Corentin Vaillant", func_url("https://github.com/CorentinVaillant/")},
        { "hades140701", function() end },
        { ""},
        { "<<< Special Thanks >>>"},
        { "Gouspourd", func_url("https://gouspourd.itch.io/")},
        { "ArkanYota", func_url("https://github.com/ARKANYOTA")},
        { "Louie Chapman", func_url("https://louiechapm.itch.io/") },
        { "Raphaël Marcon", func_url("https://raphytator.itch.io/") },
        -- { "SmellyFishstiks", func_url("https://www.lexaloffle.com/bbs/?uid=42184") },
        { "Indie Game Lyon", func_url("https://www.indiegamelyon.com/")},
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
        { "'Inhaler  Puff 170427_1464' by megashroom / CC0", func_url("https://freesound.org/s/390174/")},
        { "'Poof/Puff' by JustInvoke / CC BY 4.0", func_url("https://freesound.org/s/446124/")},
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