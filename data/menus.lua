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

local DEFAULT_MENU_BG_COLOR = {0, 0, 0, 0.9}

local PROMPTS_NORMAL = {
    {{"ui_select"}, "input.prompts.ui_select"},
    {{"ui_back"}, "input.prompts.ui_back"},
}

local PROMPTS_GAME_OVER = {
    {{"ui_select"}, "input.prompts.ui_select"},
    {},
}

local PROMPTS_CONTROLS = {
    {{"ui_select"}, "input.prompts.ui_select"},
    {{"ui_reset_keys"}, "input.prompts.ui_reset_keys"},
    {{"ui_back"}, "input.prompts.ui_back"},
}

local function draw_elevator_progress()
    local pad_x = 40
    local pad_y = 50
    local x1, y1 = CANVAS_WIDTH - pad_x, pad_y
    local x2, y2 = CANVAS_WIDTH - pad_x, CANVAS_HEIGHT - pad_y
    
    local end_w = 5
    love.graphics.rectangle("fill", x1 - end_w/2, y1 - end_w, end_w, end_w)
    love.graphics.rectangle("fill", x2 - end_w/2, y2, end_w, end_w)
    love.graphics.line(x1, y1, x2, y2)
    
    local n_floors = game.level.max_floor
    local sep_w = 3
    local h = y2 - y1
    for i = 1, n_floors-1 do
        local y = y2 - (i/n_floors) * h
        local sep_x = x1 - sep_w/2
        local sep_y = round(y - sep_w/2)
        love.graphics.rectangle("fill", sep_x, sep_y, sep_w, sep_w)
        if i == game:get_floor() then
            love.graphics.rectangle("line", sep_x-2, sep_y-1, sep_w+3, sep_w+3)
        end
    end

    local text = concat(game:get_floor(), "/", game.level.max_floor)
    local text_y = clamp(y2 - (game:get_floor()/n_floors) * h, y1, y2)
    love.graphics.print(text, x1- get_text_width(text) - 5, text_y- get_text_height(text)/2-2)
end


local function debug_draw_waves(self)
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
            local image = e.spr
            e:remove()

            local weight = enemy[2] 

            love.graphics.setColor(DEBUG_IMAGE_TO_COL[image] or ternary(j % 2 == 0, COL_WHITE, COL_RED))
            local w = total_w * (weight/weight_sum)
            love.graphics.rectangle("fill", x, y, w, 10)
            love.graphics.setColor(COL_WHITE)

            love.graphics.draw(image, x, y, 0, 0.8, 0.8)
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
        {CustomDrawMenuItem, debug_draw_waves},
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
        { "<<<<<<<<< "..Text:text("menu.pause.title").." >>>>>>>>>" },
        { "" },
        { "▶ "..Text:text("menu.pause.resume"), function() game.menu_manager:unpause() end },
        { "🔄 "..Text:text("menu.pause.retry"), function() game:new_game() end },
        { "🎚 "..Text:text("menu.pause.options"), func_set_menu('options') },
        { "❤ "..Text:text("menu.pause.credits"), func_set_menu('credits' ) },
        { "💡 "..Text:text("menu.pause.feedback"), func_set_menu("feedback") },
        { "🔚 "..Text:text("menu.pause.quit"), quit_game },
        { "" },
        -- { "[DEBUG] VIEW WAVES", func_set_menu('view_waves' ) },
        -- { "[DEBUG] joystick_removed", func_set_menu('joystick_removed' ) },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL, draw_elevator_progress)
    if OPERATING_SYSTEM == "Web" then
        -- Disable quitting on web
        menus.pause.items[8].is_selectable = false
    end
    
    menus.feedback = Menu:new(game, {
        { "<<<<<<<<< "..Text:text("menu.feedback.title").." >>>>>>>>>" },
        { "" },
        { Text:text("menu.feedback.bugs"), func_url("https://github.com/Yolwoocle/bugscraper/issues")},
        { Text:text("menu.feedback.features"), func_url("https://github.com/Yolwoocle/bugscraper/issues")},
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL, draw_elevator_progress)

    menus.options = Menu:new(game, {
        { "<<<<<<<<< "..Text:text("menu.options.title").." >>>>>>>>>" },
        { "" },
        { "<<< "..Text:text("menu.options.input.title").." >>>" },
        { "🔘 "..Text:text("menu.options.input.input"), func_set_menu("options_input")},
        { ""},
        { "<<< "..Text:text("menu.options.audio.title").." >>>" },
        { "🔊 "..Text:text("menu.options.audio.sound"), function(self, option)
            Options:toggle_sound()
        end,
        function(self)
            self.value = Options:get("sound_on")
            self.value_text = Options:get("sound_on") and "✅" or "❎"
        end},
        { SliderMenuItem, "🔉 "..Text:text("menu.options.audio.volume"), function(self, diff)
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
        { SliderMenuItem, "🎵 "..Text:text("menu.options.audio.music_volume"), function(self, diff)
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
        { "🎼 "..Text:text("menu.options.audio.music_pause_menu"), function(self, option)
            Options:toggle_play_music_on_pause_menu()
            if Options:get("play_music_on_pause_menu") then
                game.music_player:play()
            end
        end,
        function(self)
            self.value = Options:get("play_music_on_pause_menu")
            self.value_text = Options:get("play_music_on_pause_menu") and "✅" or "❎"
            self.is_selectable = Options:get("sound_on")
        end},
        -- { "🔈 "..Text:text("menu.options.audio.background_sounds"), function(self, option)
        --     Options:toggle_background_noise()
        -- end,
        -- function(self)
        --     self.value = Options:get("disable_background_noise")
        --     self.value_text = (not Options:get("disable_background_noise")) and "✅" or "❎"
        --     self.is_selectable = Options:get("sound_on")
        -- end},
        {""},

        -- {"MUSIC: [ON/OFF]", function(self)
        -- 	game:toggle_sound()
        -- end},
        { "<<< "..Text:text("menu.options.visuals.title").." >>>"},
        { "🔳 "..Text:text("menu.options.visuals.fullscreen"), function(self)
            Options:toggle_fullscreen()
        end,
        function(self)
            self.value = Options:get("is_fullscreen")
            self.value_text = Options:get("is_fullscreen") and "✅" or "❎"
        end},

        { SliderMenuItem, "🔲 "..Text:text("menu.options.visuals.pixel_scale"), function(self, diff)
            diff = diff or 1
            self:next_value(diff)

            local scale = self.value
            
            Audio:play("menu_select")
            Options:set_pixel_scale(scale)
        end, { "auto", "max_whole", 1, 2, 3, 4, 5, 6}, function(self)
            self.value = Options:get("pixel_scale")
            if type(self.value) == "string" then
                self.value_text = tostring(Text:text("menu.options.visuals.pixel_scale_value."..self.value))
            else
                self.value_text = tostring(self.value)
            end

            if OPERATING_SYSTEM == "Web" then  self.is_selectable = false  end
        end},

        { "📺 "..Text:text("menu.options.visuals.vsync"), function(self)
            Options:toggle_vsync()
        end,
        function(self)
            self.value = Options:get("is_vsync")
            self.value_text = Options:get("is_vsync") and "✅" or "❎"
        end},
        { ""},
        { "<<< "..Text:text("menu.options.game.title").." >>>"},
        { SliderMenuItem, "🛜 "..Text:text("menu.options.game.screenshake"), function(self, diff)
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

        { "🕐 "..Text:text("menu.options.game.timer"), function(self)
            Options:toggle_timer()
        end,
        function(self)
            self.value = Options:get("timer_on")
            self.value_text = Options:get("timer_on") and "✅" or "❎"
        end},

        { "↖ "..Text:text("menu.options.game.mouse_visible"), function(self)
            Options:toggle_mouse_visible()
            love.mouse.setVisible(Options:get("mouse_visible"))
        end,
        function(self)
            self.value = Options:get("mouse_visible")
            self.value_text = Options:get("mouse_visible") and "✅" or "❎"
        end},
        
        { "⏸ "..Text:text("menu.options.game.pause_on_unfocus"), function(self)
            Options:toggle_pause_on_unfocus()
        end,
        function(self)
            self.value = Options:get("pause_on_unfocus")
            self.value_text = Options:get("pause_on_unfocus") and "✅" or "❎"
        end},
        
        -- { "SCREENSHAKE", function(self)
        --     Options:toggle_screenshake()
        --     love.mouse.setVisible(Options:get("screenshake_on"))
        -- end,
        -- function(self)
        --     self.value = Options:get("screenshake_on")
        --     self.value_text = Options:get("screenshake_on") and "✅" or "❎"
        -- end},
        
        { "⚠ "..Text:text("menu.options.game.show_fps_warning"), function(self, option)
            Options:toggle("show_fps_warning")
        end,
        function(self)
            self.value = Options:get("show_fps_warning")
            self.value_text = Options:get("show_fps_warning") and "✅" or "❎"
        end},
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)
    
    menus.options_input = Menu:new(game, {
        { "<<<<<<<<< "..Text:text("menu.options.input_submenu.title").." >>>>>>>>>" },
        { "" },
        { "<<< "..Text:text("menu.options.input_submenu.keyboard").." >>>" },
        { "⌨ "..Text:text("menu.options.input_submenu.keyboard_solo"), func_set_menu("controls_keyboard_solo")},
        { "⌨ "..Text:text("menu.options.input_submenu.keyboard_p1"), func_set_menu("controls_keyboard_split_p1")},
        { "⌨ "..Text:text("menu.options.input_submenu.keyboard_p2"), func_set_menu("controls_keyboard_split_p2")},
        { "" },
        { "<<< "..Text:text("menu.options.input_submenu.controller").." >>>" },
        { "🎮 "..Text:text("menu.options.input_submenu.controller_p1"), func_set_menu("controls_controller_p1")},
        { "🎮 "..Text:text("menu.options.input_submenu.controller_p2"), func_set_menu("controls_controller_p2")},
        { "🎮 "..Text:text("menu.options.input_submenu.controller_p3"), func_set_menu("controls_controller_p3")},
        { "🎮 "..Text:text("menu.options.input_submenu.controller_p4"), func_set_menu("controls_controller_p4")},
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    local function create_keyboard_controls_menu(title, input_profile_id)
        return Menu:new(game, {
            { "<<<<<<<<< "..title.." >>>>>>>>>" },
            { "" },
            { "🔄 "..Text:text("menu.options.input_submenu.reset_controls"), function() Input:reset_controls(input_profile_id, INPUT_TYPE_KEYBOARD) end },
            { "" },
            { "<<< "..Text:text("menu.options.input_submenu.gameplay").." >>>" },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "left",  "⬅ "..Text:text("input.prompts.left") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "right", "➡ "..Text:text("input.prompts.right") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "up",    "⬆ "..Text:text("input.prompts.up") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "down",  "⬇ "..Text:text("input.prompts.down") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "jump",  "⏏ "..Text:text("input.prompts.jump") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "shoot", "🔫 "..Text:text("input.prompts.shoot") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "leave_game", "🔚 "..Text:text("input.prompts.leave_game") },
            { "" },
            { "<<< "..Text:text("menu.options.input_submenu.interface").." >>>" },
            { Text:text("menu.options.input_submenu.note_ui_min_button") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "ui_left",    "⬅ "..Text:text("input.prompts.ui_left")},
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "ui_right",   "➡ "..Text:text("input.prompts.ui_right")},
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "ui_up",      "⬆ "..Text:text("input.prompts.ui_up")},
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "ui_down",    "⬇ "..Text:text("input.prompts.ui_down")},
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "ui_select",  "👆 "..Text:text("input.prompts.ui_select")},
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "ui_back",    "🔙 "..Text:text("input.prompts.ui_back")},
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "pause",      "⏸ "..Text:text("input.prompts.pause") },
            { "" },
            { "<<< "..Text:text("menu.options.input_submenu.global").." >>>" },
            { Text:text("menu.options.input_submenu.note_global_keyboard") },
            { Text:text("menu.options.input_submenu.note_ui_min_button") },
            { ControlsMenuItem, -1, "global", INPUT_TYPE_KEYBOARD, "join_game",      "📥 "..Text:text("input.prompts.join") },
            { ControlsMenuItem, -1, "global", INPUT_TYPE_KEYBOARD, "split_keyboard", "🗄 "..Text:text("input.prompts.split_keyboard") },
        }, DEFAULT_MENU_BG_COLOR, PROMPTS_CONTROLS)
    end

    local function create_controller_controls_menu(title, input_profile_id, player_n)
        return Menu:new(game, {
            { "<<<<<<<<< "..title.." >>>>>>>>>" },
            { "", nil,
            function(self) 
                local user = Input:get_user(player_n)
                if user == nil then  
                    self.label_text = Text:text("menu.options.input_submenu.subtitle_no_player", player_n)
                    return
                end
                local joystick = user.joystick
                if joystick ~= nil then
                    self.label_text = "🎮 "..joystick:getName()
                else
                    self.label_text = Text:text("menu.options.input_submenu.subtitle_no_controller")
                end
            end},
            { "" },
            { "🔄 "..Text:text("menu.options.input_submenu.reset_controls"), function() Input:reset_controls(input_profile_id, INPUT_TYPE_CONTROLLER) end },
            { SliderMenuItem, "🔘 "..Text:text("menu.options.input_submenu.controller_button_style"), function(self, diff)
                diff = diff or 1
                self:next_value(diff)
                Options:set_button_style(player_n, self.value)
                Audio:play("menu_select", 1.0)
            end, BUTTON_STYLES,
            function(self)
                self.value = Options:get("button_style_p"..tostring(player_n))
                self.value_text = Text:text("menu.options.input_submenu.controller_button_style_value."..Options:get("button_style_p"..tostring(player_n)))
            end},

            { SliderMenuItem, "🫨 "..Text:text("menu.options.input_submenu.vibration"), function(self, diff)
                diff = diff or 1
                self.value = (self.value + diff)
                if self.value < 0 then self.value = 5 end
                if self.value > 5 then self.value = 0 end
                
                Options:set("vibration_p"..tostring(player_n), self.value/5)
                Audio:play("menu_select", 1.0, 0.8+(self.value/5)*0.4)
                Input:vibrate(player_n, 0.4, 1.0)
            end, range_table(0,5),
            function(self)
                local value = Options:get("vibration_p"..tostring(player_n))
                self.value_text = concat(math.floor(100 * value), "%")
            end},

            { SliderMenuItem, "🕹 "..Text:text("menu.options.input_submenu.deadzone"), function(self, diff)
                diff = diff or 1
                self.value = (self.value + diff)
                if self.value < 1 then self.value = 19 end
                if self.value > 19 then self.value = 1 end
                
                Options:set_axis_deadzone(player_n, self.value/20)
                Audio:play("menu_select", 1.0, 0.8+(self.value/20)*0.4)
            end, range_table(1,19),
            function(self)
                self.value = Options:get("axis_deadzone_p"..tostring(player_n)) * 20
                self.value_text = concat(floor(100 * self.value / 20), "%")
                
                self.label_text = "🕹 "..Text:text("menu.options.input_submenu.deadzone")
                if self.is_selected and self.value <= 4 then
                    self.label_text = self.label_text.."\n⚠ "..Text:text("menu.options.input_submenu.low_deadzone_warning")
                end
            end},
            { Text:text("menu.options.input_submenu.note_deadzone") },
            { "" },
            { "<<< "..Text:text("menu.options.input_submenu.gameplay").." >>>" },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "left",  "⬅ "..Text:text("input.prompts.left") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "right", "➡ "..Text:text("input.prompts.right") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "up",    "⬆ "..Text:text("input.prompts.up") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "down",  "⬇ "..Text:text("input.prompts.down") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "jump",  "⏏ "..Text:text("input.prompts.jump") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "shoot", "🔫 "..Text:text("input.prompts.shoot") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "leave_game", "🔚 "..Text:text("input.prompts.leave_game") },
            { "" },
            { "<<< "..Text:text("menu.options.input_submenu.interface").." >>>" },
            { Text:text("menu.options.input_submenu.note_ui_min_button") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "ui_left",    "⬅ "..Text:text("input.prompts.ui_left")},
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "ui_right",   "➡ "..Text:text("input.prompts.ui_right")},
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "ui_up",      "⬆ "..Text:text("input.prompts.ui_up")},
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "ui_down",    "⬇ "..Text:text("input.prompts.ui_down")},
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "ui_select",  "👆 "..Text:text("input.prompts.ui_select")},
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "ui_back",    "🔙 "..Text:text("input.prompts.ui_back")},
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "pause",      "⏸ "..Text:text("input.prompts.pause") },
            { "" },            
            { "<<< "..Text:text("menu.options.input_submenu.global").." >>>" },
            { Text:text("menu.options.input_submenu.note_global_controller") },
            { Text:text("menu.options.input_submenu.note_ui_min_button") },
            { ControlsMenuItem, -1, "global", INPUT_TYPE_CONTROLLER, "join_game", "📥 "..Text:text("input.prompts.join") },

        }, DEFAULT_MENU_BG_COLOR, PROMPTS_CONTROLS)
    end
    
    menus.controls_keyboard_solo =     create_keyboard_controls_menu(Text:text("menu.options.input_submenu.keyboard_solo"), "keyboard_solo")
    menus.controls_keyboard_split_p1 = create_keyboard_controls_menu(Text:text("menu.options.input_submenu.keyboard_p1"), "keyboard_split_p1")
    menus.controls_keyboard_split_p2 = create_keyboard_controls_menu(Text:text("menu.options.input_submenu.keyboard_p2"), "keyboard_split_p2")
    menus.controls_controller_p1 =     create_controller_controls_menu(Text:text("menu.options.input_submenu.controller_p1"), "controller_1", 1)
    menus.controls_controller_p2 =     create_controller_controls_menu(Text:text("menu.options.input_submenu.controller_p2"), "controller_2", 2)
    menus.controls_controller_p3 =     create_controller_controls_menu(Text:text("menu.options.input_submenu.controller_p3"), "controller_3", 3)
    menus.controls_controller_p4 =     create_controller_controls_menu(Text:text("menu.options.input_submenu.controller_p4"), "controller_4", 4)

    menus.game_over = Menu:new(game, {
        {"<<<<<<<<< "..Text:text("menu.game_over.title").." >>>>>>>>>"},
        { "" },
        { StatsMenuItem, Text:text("menu.game_over.kills"), function(self) return game.stats.kills end },
        { StatsMenuItem, Text:text("menu.game_over.time"),  function(self)
            return time_to_string(game.stats.time)
        end },
        { StatsMenuItem, Text:text("menu.game_over.floor"), function(self) return concat(game.stats.floor, "/", game.level.max_floor) end },
        -- { StatsMenuItem, Text:text("menu.game_over.max_combo"), function(self) return concat(game.stats.max_combo) end },
        { "" },
        { Text:text("menu.game_over.continue"), function() game:new_game() end },
        { "" },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_GAME_OVER, draw_elevator_progress)

    menus.credits = Menu:new(game, {
        {"<<<<<<<<< "..Text:text("menu.credits.title").." >>>>>>>>>"},
        { "" },
        { "<<< "..Text:text("menu.credits.game_by").." >>>"},
        { "Léo Bernard", func_url("https://yolwoocle.github.io/")},
        { "" },
        { "<<< "..Text:text("menu.credits.music_and_sound_design").." >>>"},
        { "OLX", func_url("https://www.youtube.com/@olxdotwav")},
        -- { "'Galaxy Trip' by Raphaël Marcon / CC BY 4.0", func_url("https://raphytator.itch.io/")},
        { ""},
        { "<<< "..Text:text("menu.credits.playtesting").." >>>"},
        { "hades140701", function() end },
        { "Corentin Vaillant", func_url("https://github.com/CorentinVaillant/")},
        { "NerdOfGamers + partner", func_url("https://ryancavendell.itch.io/")},
        { "Azuras03 (NicolasYT)", function() end},
        { "Lars Loe (MadByte)", function() end},
        { "Theobosse", function() end},
        { "Alexis", function() end},
        { "Binary Sunrise", func_url("https://binarysunrise.dev")},
        { ""},
        { "<<< "..Text:text("menu.credits.special_thanks").." >>>"},
        { "Gouspourd", func_url("https://gouspourd.itch.io/")},
        { "ArkanYota", func_url("https://github.com/ARKANYOTA")},
        { "Louie Chapman", func_url("https://louiechapm.itch.io/") },
        { "Raphaël Marcon", func_url("https://raphytator.itch.io/") },
        { "Indie Game Lyon", func_url("https://www.indiegamelyon.com/")},
        { "LÖVE framework", func_url("https://love2d.org/") },
        { ""},
        { "<<< "..Text:text("menu.credits.asset_creators").." >>>"},
        { "Kenney", func_url("https://kenney.nl/")},
        { "somepx", func_url("https://somepx.itch.io/")},
        { "emhuo", func_url("https://emhuo.itch.io/")},
        { "freesound.org ["..Text:text("menu.see_more").."]", func_set_menu("credits_sounds")},
        { "Open source libraries ["..Text:text("menu.see_more").."]", func_set_menu("open_source")},
        { ""},
        { "<< "..Text:text("menu.credits.licenses").." >>"},
        { "CC0", func_url("https://creativecommons.org/publicdomain/zero/1.0/")},
        { "CC BY 3.0", func_url("https://creativecommons.org/licenses/by/3.0/")},          
        { "CC BY 4.0", func_url("https://creativecommons.org/licenses/by/4.0/")},
        { "MIT", func_url("https://opensource.org/license/mit")},
        { ""},
        { "🐜❤"},
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    menus.open_source = Menu:new(game, {
        {"<<< "..Text:text("menu.open_source.title").." >>>"},
        {""},
        -- { Text:text("menu.credits.asset_item", "", "", ""), func_url()}
        { Text:text("menu.credits.asset_item", "'GamepadGuesser'", "idbrii", "MIT"), func_url("https://github.com/idbrii/love-gamepadguesser/tree/main")};
        { Text:text("menu.credits.asset_item", "'bump.lua'", "kikito", "MIT"), func_url("https://github.com/kikito/bump.lua")};
        { Text:text("menu.credits.asset_item", "'love-error-explorer'", "snowkittykira", "MIT"), func_url("https://github.com/snowkittykira/love-error-explorer")};
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    menus.credits_sounds = Menu:new(game, {
        {"<<< freesound.org credits >>>"},
        {""},
        { Text:text("menu.credits.asset_item", "'jf Glass Breaking.wav'", "cmusounddesign", "CC BY 3.0"),      func_url("https://freesound.org/people/cmusounddesign/sounds/85168/")},
        { Text:text("menu.credits.asset_item", "'Glass Break'", "avrahamy", "CC0"),                            func_url("https://freesound.org/people/avrahamy/sounds/141563/")},
        { Text:text("menu.credits.asset_item", "'Glass shard tinkle texture'", "el-bee", "CC BY 4.0"),         func_url("https://freesound.org/people/el-bee/sounds/636238/")},
        { Text:text("menu.credits.asset_item", "'Bad Beep (Incorrect)'", "RICHERlandTV", "CC BY 3.0"),         func_url("https://freesound.org/people/RICHERlandTV/sounds/216090/")},
        { Text:text("menu.credits.asset_item", "[Keyboard press]", "MattRuthSound", "CC BY 3.0"),              func_url("https://freesound.org/people/MattRuthSound/sounds/561661/")},
        { Text:text("menu.credits.asset_item", "'Paper Throw Into Air(fuller) 2'", "RossBell", "CC0"),         func_url("https://freesound.org/people/RossBell/sounds/389442/")},
        { Text:text("menu.credits.asset_item", "'Slime'", "Lukeo135", "CC0"),                                  func_url("https://freesound.org/people/Lukeo135/sounds/530617/")},
        { Text:text("menu.credits.asset_item", "'brushes_on_snare'", "Heigh-hoo", "CC0"),                      func_url("https://freesound.org/people/Heigh-hoo/sounds/20297/")},
        { Text:text("menu.credits.asset_item", "'01 Elevator UP'", "soundslikewillem", "CC BY 4.0"),           func_url("https://freesound.org/people/soundslikewillem/sounds/340747/")},
        { Text:text("menu.credits.asset_item", "'indsustrial_elevator_door_open'", "joedeshon", "CC BY 4.0"),  func_url("https://freesound.org/people/joedeshon/sounds/368737/")},
        { Text:text("menu.credits.asset_item", "'indsustrial_elevator_door_close'", "joedeshon", "CC BY 4.0"), func_url("https://freesound.org/people/joedeshon/sounds/368738/")},
        { Text:text("menu.credits.asset_item", "'Footsteps on gravel'", "Joozz", "CC BY 4.0"),                 func_url("https://freesound.org/people/Joozz/sounds/531952/")},
        { Text:text("menu.credits.asset_item", "'THE CRASH'", "sandyrb", "CC BY 4.0"),                         func_url("https://freesound.org/people/sandyrb/sounds/95078/")},
        { Text:text("menu.credits.asset_item", "'Door slam - Gun shot'", "coolguy244e", "CC BY 4.0"),          func_url("https://freesound.org/people/coolguy244e/sounds/266915/")},
        { Text:text("menu.credits.asset_item", "'bee fly'", "soundmary", "CC BY 4.0"),                         func_url("https://freesound.org/people/soundmary/sounds/194932/")},
        { Text:text("menu.credits.asset_item", "'Pop, Low, A (H1)'", "InspectorJ", "CC BY 4.0"),               func_url("https://freesound.org/people/InspectorJ/sounds/411639/")},
        { Text:text("menu.credits.asset_item", "'Crack 1'", "JustInvoke", "CC BY 3.0"),                        func_url("https://freesound.org/people/JustInvoke/sounds/446118/")},
        { Text:text("menu.credits.asset_item", "'Emergency Siren'", "onderwish", "CC0"),                       func_url("https://freesound.org/people/onderwish/sounds/470504/")},
        { Text:text("menu.credits.asset_item", "'Wood burning in the stove'", "smand", "CC0"),                 func_url("https://freesound.org/people/smand/sounds/521118/")},
        { Text:text("menu.credits.asset_item", "'Bike falling down an escalator'", "dundass", "CC BY 3.0"),    func_url("https://freesound.org/people/dundass/sounds/509831/")},
        { Text:text("menu.credits.asset_item", "'squishing and squeezing a wet sponge in a bowl'", "breadparticles", "CC0"), func_url("https://freesound.org/people/breadparticles/sounds/575332/#comments")},
        { Text:text("menu.credits.asset_item", "'Insect Bug Smash & Crush'", "EminYILDIRIM", "CC BY 4.0"),     func_url("https://freesound.org/people/EminYILDIRIM/sounds/570767/")},
        { Text:text("menu.credits.asset_item", "'Inhaler  Puff 170427_1464'", "megashroom", "CC0"),            func_url("https://freesound.org/s/390174/")},
        { Text:text("menu.credits.asset_item", "'Poof/Puff'", "JustInvoke", "CC BY 4.0"),                      func_url("https://freesound.org/s/446124/")},
        { Text:text("menu.credits.asset_item", "'rolling bag'", "Sunejackie", "CC BY 4.0"),                    func_url("https://freesound.org/s/542402/")},
        -- { Text:text("menu.credits.asset_item", "'Ruler Bounce 3'", "belanhud", "CC0"),                         func_url("https://freesound.org/s/537904/")},
        { Text:text("menu.credits.asset_item", "'Springboard A'", "lmbubec", "CC0"),                           func_url("https://freesound.org/s/119793/")},
        { Text:text("menu.credits.asset_item", "'Springboard B'", "lmbubec", "CC0"),                           func_url("https://freesound.org/s/119794/")},
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    local items = {
        { "<<<<<<<<< CONGRATULATIONS! >>>>>>>>>" },
        { "" },
        { StatsMenuItem, Text:text("menu.game_over.kills"), function(self) return game.stats.kills end },
        { StatsMenuItem, Text:text("menu.game_over.time"),  function(self)
            return time_to_string(game.stats.time)
        end },
        { StatsMenuItem, Text:text("menu.game_over.floor"), function(self) return concat(game.stats.floor, "/", game.level.max_floor) end },
        -- { StatsMenuItem, Text:text("menu.game_over.max_combo"), function(self) return concat(game.stats.max_combo) end },
        { ""},
        { "❤ "..Text:text("menu.win.wishlist"), func_url("https://s.team/a/2957130") },
        { "▶ "..Text:text("menu.win.continue"), function() game:new_game() end },
        -- { --[["🔚 "..]]Text:text("menu.pause.quit"), quit_game },
        { "" },

    }

    -- if OPERATING_SYSTEM == "Web" or true the$n
    --     table.remove(items, 8)
    -- end
    menus.win = Menu:new(game, items, { 0, 0, 0, 0.95 }, PROMPTS_GAME_OVER)

    ------------------------------------------------------------

    menus.joystick_removed = Menu:new(game, {
        {"<<<<<<<<< "..Text:text("menu.joystick_removed.title").." >>>>>>>>>"},
        { "" },
        { Text:text("menu.joystick_removed.description")},
        { "", nil, 
        function(self)
            local keyset = {}
            for joystick ,_ in pairs(game.menu_manager.joystick_wait_set) do
                local player_n = Input:get_joystick_user_n(joystick)
                table.insert(keyset, {player_n, joystick:getName()})
            end
            table.sort(keyset, function(a, b) return a[1] < b[1] end)

            local s = ""
            for _, value in pairs(keyset) do
                s = s.."🎮 "..Text:text("menu.joystick_removed.item", value[1], value[2]).."\n"
            end

            self.label_text = s
            --..concat("\n", game.menu_manager.joystick_wait_cooldown, " (", game.menu_manager.joystick_wait_mode, ")")
        end,
        },
        { "" },
        { "" },
        { "" },
        { "" },
        { "⚠ "..Text:text("menu.joystick_removed.continue"), 
            function(self)
                if game.menu_manager.joystick_wait_cooldown > 0 then
                    return
                end
                game.menu_manager:disable_joystick_wait_mode()
            end, 
        },
        { "" },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_GAME_OVER)

    return menus
end

return generate_menus