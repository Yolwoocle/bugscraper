local Menu                = require "scripts.ui.menu.menu"
local BossIntroMenu       = require "scripts.ui.menu.boss_intro_menu"
local RangeOptionMenuItem = require "scripts.ui.menu.items.range_option_menu_item"
local BoolOptionMenuItem  = require "scripts.ui.menu.items.bool_option_menu_item"
local EnumOptionMenuItem  = require "scripts.ui.menu.items.enum_option_menu_item"
local StatsMenuItem       = require "scripts.ui.menu.items.menu_item_stats"
local ControlsMenuItem    = require "scripts.ui.menu.items.controls_menu_item"
local CustomDrawMenuItem  = require "scripts.ui.menu.items.menu_item_custom_draw"
local waves               = require "data.waves"
local Enemies             = require "data.enemies"
local debug_draw_waves    = require "scripts.debug.draw_waves"
local images              = require "data.images"
local DebugCommandMenu   = require "scripts.ui.menu.debug_command_menu"

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

local DEFAULT_MENU_BG_COLOR = { 0, 0, 0, 0.8 }

local PROMPTS_NORMAL = {
    { { "ui_select" }, "input.prompts.ui_select" },
    { { "ui_back" },   "input.prompts.ui_back" },
}

local PROMPTS_GAME_OVER = {
    { { "ui_select" }, "input.prompts.ui_select" },
    {},
}

local PROMPTS_CONTROLS = {
    { { "ui_select" },     "input.prompts.ui_select" },
    { { "ui_back" },       "input.prompts.ui_back" },
}

local function draw_elevator_progress()
    local pad_x = 40
    local pad_y = 50
    local x1, y1 = CANVAS_WIDTH - pad_x, pad_y
    local x2, y2 = CANVAS_WIDTH - pad_x, CANVAS_HEIGHT - pad_y

    local end_w = 5
    love.graphics.rectangle("fill", x1 - end_w / 2, y1 - end_w, end_w, end_w)
    love.graphics.rectangle("fill", x2 - end_w / 2, y2, end_w, end_w)
    love.graphics.line(x1, y1, x2, y2)

    local n_floors = game.level.max_floor
    local sep_w = 3
    local h = y2 - y1
    for i = 1, n_floors - 1 do
        local y = y2 - (i / n_floors) * h
        local sep_x = x1 - sep_w / 2
        local sep_y = round(y - sep_w / 2)
        if i % 5 == 0 then
            love.graphics.rectangle("fill", sep_x, sep_y, sep_w, sep_w)
        end
        if i == game:get_floor() then
            love.graphics.rectangle("line", sep_x - 2, sep_y - 1, sep_w + 3, sep_w + 3)
        end
    end

    local text = concat(game:get_floor(), "/", game.level.max_floor)
    local text_y = clamp(y2 - (game:get_floor() / n_floors) * h, y1, y2)
    love.graphics.print(text, x1 - get_text_width(text) - 5, text_y - get_text_height(text) / 2 - 2)
end

-----------------------------------------------------
------ [[[[[[[[[[[[[[[[ MENUS ]]]]]]]]]]]]]]]] ------
-----------------------------------------------------

local function generate_menus()
    local menus = {}

    menus.quit = Menu:new(game, {
        { "" },
        { "{menu.quit.description}" },
        { "{menu.no}",              function() game.menu_manager:back() end },
        { "{menu.yes}",             quit_game },
        { "" },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    menus.title = Menu:new(game, {
        { ">>>> Bugscraper (logo here) <<<<" },
        { "" },
        { "PLAY",                            function() game:new_game() end },
        { "OPTIONS",                         func_set_menu('options') },
        { "QUIT",                            quit_game },
        { "" },
        { "" },
    }, DEFAULT_MENU_BG_COLOR)

    menus.debug_command = DebugCommandMenu:new(game)

    menus.boss_intro = BossIntroMenu:new(game, { 38 / 255, 43 / 255, 68 / 255, 0.8 }, "Dung Manager", {
        { image = images.boss_intro_dung_layer5, z_mult = 0.3 },
        { image = images.boss_intro_dung_layer4, z_mult = 0.5 },
        { image = images.boss_intro_dung_layer3, z_mult = 0.7 },
        { image = images.boss_intro_dung_layer2, z_mult = 0.9 },
        { image = images.boss_intro_dung_layer1, z_mult = 1.4 },
        { image = images.boss_intro_dung_layer0, z_mult = 1.5 },
    })

    menus.view_waves = Menu:new(game, {
        { "waves" },
        { CustomDrawMenuItem, debug_draw_waves },
        { "",                 function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end },
        { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end }, { "", function() end },
    }, DEFAULT_MENU_BG_COLOR, {}, function() end
    )


    local pause_items = {
        [1]  = { "" },
        [2]  = { "<<<<<<<<< " .. Text:text("menu.pause.title") .. " >>>>>>>>>" },
        [3]  = { "" },
        [4]  = { "▶ " .. Text:text("menu.pause.resume"), function() game.menu_manager:unpause() end },
        [5]  = { "🔄 " .. Text:text("menu.pause.retry"), function() game:new_game() end },
        [6]  = { "🎚 " .. Text:text("menu.pause.options"), func_set_menu('options') },
        [7]  = { "💡 " .. Text:text("menu.pause.feedback"), func_set_menu("feedback") },
        [8]  = { "❤ " .. Text:text("menu.pause.credits"), func_set_menu('credits') },
        [9]  = { "🔚 " .. Text:text("menu.pause.quit"), func_set_menu('quit') },
        [10] = { "" },
        [11] = { "❤ " .. Text:text("menu.win.wishlist") .. " 🔗", func_url("steam://advertise/2957130/") },
        [12] = { "😈 " .. Text:text("menu.pause.discord") .. " 🔗", func_url("https://discord.gg/BAMMwMn2m5") },
    }
    if OPERATING_SYSTEM == "Web" then
        -- Disable quitting on web
        table.remove(pause_items, 9)
    end
    if not DEMO_BUILD then
        -- Disable wishlist if not demo
        table.remove(pause_items, 11)
    end
    if DEBUG_MODE then
        table.insert(pause_items, { " " })
        table.insert(pause_items, { "[DEBUG] Skip to world 2", function()
            for k, e in pairs(game.actors) do
                if e.is_enemy then
                    e:kill()
                end
            end
            game:set_floor(20)
            for _, p in pairs(game.players) do
                p:set_pos(CANVAS_CENTER[1], CANVAS_CENTER[2])
            end
            game.can_start_game = true
            game.camera:reset()
            game:start_game()
            game.menu_manager:unpause()
        end })
        table.insert(pause_items, { "[DEBUG] Skip to world 2 boss", function()
            for k, e in pairs(game.actors) do
                if e.is_enemy then
                    e:kill()
                end
            end
            game:set_floor(38)
            for _, p in pairs(game.players) do
                p:set_pos(CANVAS_CENTER[1], CANVAS_CENTER[2])
            end
            game.can_start_game = true
            game.camera:reset()
            game:start_game()
            game.menu_manager:unpause()
        end })
        table.insert(pause_items, { "[DEBUG] Skip to world 3", function()
            for k, e in pairs(game.actors) do
                if e.is_enemy then
                    e:kill()
                end
            end
            game:set_floor(40)
            for _, p in pairs(game.players) do
                p:set_pos(CANVAS_CENTER[1], CANVAS_CENTER[2])
            end
            game.can_start_game = true
            game.camera:reset()
            game:start_game()
            game.menu_manager:unpause()
        end })
        table.insert(pause_items, { "[DEBUG] Skip to world 3 boss", function()
            for k, e in pairs(game.actors) do
                if e.is_enemy then
                    e:kill()
                end
            end
            game:set_floor(58)
            for _, p in pairs(game.players) do
                p:set_pos(CANVAS_CENTER[1], CANVAS_CENTER[2])
            end
            game.can_start_game = true
            game.camera:reset()
            game:start_game()
            game.menu_manager:unpause()
        end })
        table.insert(pause_items, { "[DEBUG] Skip to world 4", function()
            for k, e in pairs(game.actors) do
                if e.is_enemy then
                    e:kill()
                end
            end
            game:set_floor(60)
            for _, p in pairs(game.players) do
                p:set_pos(CANVAS_CENTER[1], CANVAS_CENTER[2])
            end
            game.can_start_game = true
            game.camera:reset()
            game:start_game()
            game.menu_manager:unpause()
        end })
        table.insert(pause_items, { "[DEBUG] Skip to world 4 boss", function()
            for k, e in pairs(game.actors) do
                if e.is_enemy then
                    e:kill()
                end
            end
            game:set_floor(78)
            for _, p in pairs(game.players) do
                p:set_pos(CANVAS_CENTER[1], CANVAS_CENTER[2])
            end
            game.can_start_game = true
            game.camera:reset()
            game:start_game()
            game.menu_manager:unpause()
        end })
    end
    menus.pause = Menu:new(game, pause_items, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL, draw_elevator_progress)

    menus.feedback = Menu:new(game, {
        { "<<<<<<<<< " .. Text:text("menu.feedback.title") .. " >>>>>>>>>" },
        { "" }, -- pinnnnn
        { Text:text("menu.feedback.bugs"),                                 func_url("https://github.com/Yolwoocle/bugscraper/issues") },
        { Text:text("menu.feedback.features"),                             func_url("https://github.com/Yolwoocle/bugscraper/issues") },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL, draw_elevator_progress)

    menus.options = Menu:new(game, {
        { "<<<<<<<<< {menu.options.title} >>>>>>>>>" },
        { "" },
        { "<<< {menu.options.input.title} >>>" },
        { "🔘 {menu.options.input.input}", func_set_menu("options_input") },
        { "" },
        { "<<< {menu.options.audio.title} >>>" },
        { BoolOptionMenuItem, "🔊 {menu.options.audio.sound}", "sound_on" },
        { RangeOptionMenuItem, "🔉 {menu.options.audio.volume}", "volume", { 0.0, 1.0 }, 0.05, "%",
            function(self)
                self.is_selectable = Options:get("sound_on")
            end
        },
        { RangeOptionMenuItem, "🎵 {menu.options.audio.music_volume}", "music_volume", { 0.0, 1.0 }, 0.05, "%",
            function(self)
                self.is_selectable = Options:get("sound_on")
            end
        },
        { BoolOptionMenuItem, "🎼 {menu.options.audio.music_pause_menu}", "play_music_on_pause_menu",
            function(self)
                self.is_selectable = Options:get("sound_on")
            end
        },
        { "" },
        { "<<< {menu.options.visuals.title} >>>" },
        { BoolOptionMenuItem, "🔳 {menu.options.visuals.fullscreen}", "is_fullscreen" },
        { EnumOptionMenuItem, "🔲 {menu.options.visuals.pixel_scale}", "pixel_scale", { "auto", "max_whole", "1", "2", "3", "4", "5", "6" },
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
        },
        { BoolOptionMenuItem, "📺 {menu.options.visuals.vsync}", "is_vsync" },
        { BoolOptionMenuItem, "💧 {menu.options.visuals.menu_blur}", "menu_blur" },
        { RangeOptionMenuItem, "🌄 {menu.options.visuals.background_speed}", "background_speed", { 0.0, 1.0 }, 0.05, "%" },
        { "" },
        { "<<< {menu.options.game.title} >>>" },
        { RangeOptionMenuItem, "🛜 " .. Text:text("menu.options.game.screenshake"), "screenshake", { 0.0, 1.0 }, 0.05, "%" },
        { BoolOptionMenuItem, "🕐 {menu.options.game.timer}", "timer_on" },
        { BoolOptionMenuItem, "↖ {menu.options.game.mouse_visible}", "mouse_visible" },
        { BoolOptionMenuItem, "🛅 {menu.options.game.pause_on_unfocus}", "pause_on_unfocus" },
        { BoolOptionMenuItem, "⚠ {menu.options.game.show_fps_warning}", "show_fps_warning" },

    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    menus.options_input = Menu:new(game, {
        { "<<<<<<<<< " .. Text:text("menu.options.input_submenu.title") .. " >>>>>>>>>" },
        { "" },
        { "<<< " .. Text:text("menu.options.input_submenu.keyboard") .. " >>>" },
        { "⌨ " .. Text:text("menu.options.input_submenu.keyboard_solo"), func_set_menu("controls_keyboard_solo") },
        { "⌨ " .. Text:text("menu.options.input_submenu.keyboard_p1"), func_set_menu("controls_keyboard_split_p1") },
        { "⌨ " .. Text:text("menu.options.input_submenu.keyboard_p2"), func_set_menu("controls_keyboard_split_p2") },
        { "" },
        { "<<< " .. Text:text("menu.options.input_submenu.controller") .. " >>>" },
        { "🎮 " .. Text:text("menu.options.input_submenu.controller_p1"), func_set_menu("controls_controller_p1") },
        { "🎮 " .. Text:text("menu.options.input_submenu.controller_p2"), func_set_menu("controls_controller_p2") },
        { "🎮 " .. Text:text("menu.options.input_submenu.controller_p3"), func_set_menu("controls_controller_p3") },
        { "🎮 " .. Text:text("menu.options.input_submenu.controller_p4"), func_set_menu("controls_controller_p4") },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    local function create_keyboard_controls_menu(title, input_profile_id)
        return Menu:new(game, {
            { "<<<<<<<<< " .. title .. " >>>>>>>>>" },
            { "" },
            { "🔄 {menu.options.input_submenu.reset_controls}", function()
                Input:reset_controls(input_profile_id, INPUT_TYPE_KEYBOARD)
                Input:reset_controls("global", INPUT_TYPE_KEYBOARD)
            end },
            { "" },
            { "<<< {menu.options.input_submenu.gameplay} >>>" },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "left", "⬅ " .. Text:text("input.prompts.left") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "right", "➡ " .. Text:text("input.prompts.right") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "up", "⬆ " .. Text:text("input.prompts.up") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "down", "⬇ " .. Text:text("input.prompts.down") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "jump", "⏏ " .. Text:text("input.prompts.jump") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "shoot", "🔫 " .. Text:text("input.prompts.shoot") },
            { "" },
            { "<<< {menu.options.input_submenu.interface} >>>" },
            { "{menu.options.input_submenu.note_ui_min_button}" },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "ui_left", "⬅ " .. Text:text("input.prompts.ui_left") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "ui_right", "➡ " .. Text:text("input.prompts.ui_right") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "ui_up", "⬆ " .. Text:text("input.prompts.ui_up") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "ui_down", "⬇ " .. Text:text("input.prompts.ui_down") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "ui_select", "👆 " .. Text:text("input.prompts.ui_select") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "ui_back", "🔙 " .. Text:text("input.prompts.ui_back") },
            { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "pause", "⏸ " .. Text:text("input.prompts.pause") },
            { "" },
            { "<<< {menu.options.input_submenu.global} >>>" },
            { "{menu.options.input_submenu.note_global_keyboard}" },
            { "{menu.options.input_submenu.note_ui_min_button}" },
            { ControlsMenuItem, -1, "global", INPUT_TYPE_KEYBOARD, "join_game", "📥 " .. Text:text("input.prompts.join") },
            { ControlsMenuItem, -1, "global", INPUT_TYPE_KEYBOARD, "split_keyboard", "🗄 " .. Text:text("input.prompts.split_keyboard") },
        }, DEFAULT_MENU_BG_COLOR, PROMPTS_CONTROLS)
    end

    local function create_controller_controls_menu(title, input_profile_id, player_n)
        return Menu:new(game, {
            { "<<<<<<<<< " .. title .. " >>>>>>>>>" },
            { "", nil,
                function(self)
                    local user = Input:get_user(player_n)
                    if user == nil then
                        self:set_label_text(Text:text("menu.options.input_submenu.subtitle_no_player", player_n))
                        return
                    end
                    local joystick = user.joystick
                    if joystick ~= nil then
                        self:set_label_text("🎮 " .. joystick:getName())
                    else
                        self:set_label_text(Text:text("menu.options.input_submenu.subtitle_no_controller"))
                    end
                end },
            { "" },
            { EnumOptionMenuItem, "🔘 {menu.options.input_submenu.controller_button_style}",
                "button_style_p" .. tostring(player_n), BUTTON_STYLES,
                "menu.options.input_submenu.controller_button_style_value"
            },
            { RangeOptionMenuItem, "🫨 {menu.options.input_submenu.vibration}",
                "vibration_p" .. tostring(player_n), { 0.0, 1.0 }, 0.2, "%", nil,
                function(self)
                    Input:vibrate(player_n, 0.4, 1.0)
                end
            },
            { RangeOptionMenuItem, "🕹 {menu.options.input_submenu.deadzone}",
                "axis_deadzone_p" .. tostring(player_n), { 0.0, 0.95 }, 0.05, "%",
                function(self)
                    if self.is_selected and self.value < 0.3 then
                        self:set_annotation("⚠ {menu.options.input_submenu.low_deadzone_warning}")
                    else
                        self.annotation = nil
                    end
                end
            },
            { Text:text("menu.options.input_submenu.note_deadzone") },
            { "" },
            { "🔄 " .. Text:text("menu.options.input_submenu.reset_controls"), function()
                Input:reset_controls(input_profile_id, INPUT_TYPE_CONTROLLER)
                Input:reset_controls("global", INPUT_TYPE_KEYBOARD)
            end },
            { "<<< {menu.options.input_submenu.gameplay} >>>" },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "left", "⬅ " .. Text:text("input.prompts.left") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "right", "➡ " .. Text:text("input.prompts.right") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "up", "⬆ " .. Text:text("input.prompts.up") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "down", "⬇ " .. Text:text("input.prompts.down") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "jump", "⏏ " .. Text:text("input.prompts.jump") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "shoot", "🔫 " .. Text:text("input.prompts.shoot") },
            { "" },
            { "<<< {menu.options.input_submenu.interface} >>>" },
            { Text:text("menu.options.input_submenu.note_ui_min_button") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "ui_left", "⬅ " .. Text:text("input.prompts.ui_left") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "ui_right", "➡ " .. Text:text("input.prompts.ui_right") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "ui_up", "⬆ " .. Text:text("input.prompts.ui_up") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "ui_down", "⬇ " .. Text:text("input.prompts.ui_down") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "ui_select", "👆 " .. Text:text("input.prompts.ui_select") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "ui_back", "🔙 " .. Text:text("input.prompts.ui_back") },
            { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "pause", "⏸ " .. Text:text("input.prompts.pause") },
            { "" },
            { "<<< {menu.options.input_submenu.global} >>>" },
            { "{menu.options.input_submenu.note_global_controller}" },
            { "{menu.options.input_submenu.note_ui_min_button}" },
            { ControlsMenuItem, -1, "global", INPUT_TYPE_CONTROLLER, "join_game", "📥 " .. Text:text("input.prompts.join") },

        }, DEFAULT_MENU_BG_COLOR, PROMPTS_CONTROLS)
    end

    ------------------------------------------------------------

    menus.controls_keyboard_solo = create_keyboard_controls_menu(Text:text("menu.options.input_submenu.keyboard_solo"),
        "keyboard_solo")
    menus.controls_keyboard_split_p1 = create_keyboard_controls_menu(Text:text("menu.options.input_submenu.keyboard_p1"),
        "keyboard_split_p1")
    menus.controls_keyboard_split_p2 = create_keyboard_controls_menu(Text:text("menu.options.input_submenu.keyboard_p2"),
        "keyboard_split_p2")
    menus.controls_controller_p1 = create_controller_controls_menu(Text:text("menu.options.input_submenu.controller_p1"),
        "controller_1", 1)
    menus.controls_controller_p2 = create_controller_controls_menu(Text:text("menu.options.input_submenu.controller_p2"),
        "controller_2", 2)
    menus.controls_controller_p3 = create_controller_controls_menu(Text:text("menu.options.input_submenu.controller_p3"),
        "controller_3", 3)
    menus.controls_controller_p4 = create_controller_controls_menu(Text:text("menu.options.input_submenu.controller_p4"),
        "controller_4", 4)

    ------------------------------------------------------------

    local game_over_items = {
        { "<<<<<<<<< " .. Text:text("menu.game_over.title") .. " >>>>>>>>>" },
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
        -- { StatsMenuItem, Text:text("menu.game_over.max_combo"), function(self) return concat(game.stats.max_combo) end },
        { "" },
        { "▶ " .. Text:text("menu.game_over.continue"), function()
            -- scotch
            game.has_seen_controller_warning = true
            game:new_game()
        end },
    }
    if DEMO_BUILD then
        table.insert(game_over_items, 
            { "❤ " .. Text:text("menu.win.wishlist") .. " 🔗", func_url("steam://advertise/2957130/") }
        )
    end
    menus.game_over = Menu:new(game, game_over_items, DEFAULT_MENU_BG_COLOR, PROMPTS_GAME_OVER, draw_elevator_progress)

    ------------------------------------------------------------

    menus.credits = Menu:new(game, {
        { "<<<<<<<<< " .. Text:text("menu.credits.title") .. " >>>>>>>>>" },
        { "" },
        { "<<< " .. Text:text("menu.credits.game_by") .. " >>>" },
        { "Yolwoocle (Léo Bernard) 🔗", func_url("https://yolwoocle.com/") },
        { "" },
        { "<<< " .. Text:text("menu.credits.music_and_sound_design") .. " >>>" },
        { "OLX 🔗", function() func_url("https://www.youtube.com/@olxdotwav") end },
        { "" },
        { "<<< " .. Text:text("menu.credits.playtesting") .. " >>>" },
        { "hades140701", function() end },
        { "Corentin Vaillant", function() end },      --func_url("https://github.com/CorentinVaillant/")},
        { "NerdOfGamers + partner", function() end }, --func_url("https://ryancavendell.itch.io/")},
        { "Azuras03 (NicolasYT)", function() end },
        { "Lars Loe (MadByte)", function() end },
        { "Theobosse", function() end },
        { "Alexis", function() end }, -- func_url("https://binarysunrise.dev")},
        { "Binary Sunrise", function() end },
        { "AnnaWorldEater", function() end },
        { "Sylvain Fraresso", function() end },
        { "Tom Le Ber", function() end },
        { "Guillaume Tran", function() end },
        { "Lucas Froehlinger 😎", function() end },
        { "" },
        { "<<< " .. Text:text("menu.credits.special_thanks") .. " >>>" },
        { "ArkanYota", function() end },       --func_url("https://github.com/ARKANYOTA")},
        { "Gouspourd", function() end },       -- func_url("https://gouspourd.itch.io/")},
        { "Raphytator", function() end },      -- func_url("https://raphytator.itch.io/") },
        { "Louie Chapman", function() end },   -- func_url("https://louiechapm.itch.io/") },
        { "Indie Game Lyon", function() end }, -- func_url("https://www.indiegamelyon.com/")},
        { "Fabien Delpiano", function() end },
        { "Quentin Picault", function() end },
        { "Guillaume Tran", function() end },
        { "Toulouse Game Dev", function() end }, -- func_url("https://www.indiegamelyon.com/")},
        { "LÖVE framework", function() end },    -- func_url("https://love2d.org/") },
        { "" },
        { "<<< " .. Text:text("menu.credits.asset_creators") .. " >>>" },
        { "Kenney", function() end }, -- func_url("https://kenney.nl/")},
        { "somepx", function() end }, -- func_url("https://somepx.itch.io/")},
        { "emhuo", function() end },  -- func_url("https://emhuo.itch.io/")},
        { "Endesga", function() end },  -- func_url("https://emhuo.itch.io/")},
        { "freesound.org [" .. Text:text("menu.see_more") .. "]", func_set_menu("credits_sounds") },
        { Text:text("menu.open_source.title").." [" .. Text:text("menu.see_more") .. "]", func_set_menu("open_source") },
        { "" },
        { "<< " .. Text:text("menu.credits.licenses") .. " >>" },
        { "CC0 🔗", func_url("https://creativecommons.org/publicdomain/zero/1.0/") },
        { "CC BY 3.0 🔗", func_url("https://creativecommons.org/licenses/by/3.0/") },
        { "CC BY 4.0 🔗", func_url("https://creativecommons.org/licenses/by/4.0/") },
        { "MIT 🔗", func_url("https://opensource.org/license/mit") },
        { "Zlib 🔗", func_url("https://www.zlib.net/zlib_license.html") },
        { "OFL-1.1 🔗", func_url("https://spdx.org/licenses/OFL-1.1.html") },
        { "" },
        -- { random_sample({ "🐜", "🐛", "🐝", "🪲", "🐰" }) .. "❤" },
        { "🐜❤" },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    menus.open_source = Menu:new(game, {
        { "<<< " .. Text:text("menu.open_source.title") .. " >>>" },
        { "" },
        -- { Text:text("menu.credits.asset_item", "", "", ""), func_url()}
        { Text:text("menu.credits.asset_item", "'GamepadGuesser'", "idbrii", "MIT"),                       func_url("https://github.com/idbrii/love-gamepadguesser/tree/main") },
        { Text:text("menu.credits.asset_item", "'bump.lua'", "kikito", "MIT"),                             func_url("https://github.com/kikito/bump.lua") },
        { Text:text("menu.credits.asset_item", "'love-error-explorer'", "snowkittykira", "MIT"),           func_url("https://github.com/snowkittykira/love-error-explorer") },
        { Text:text("menu.credits.asset_item", "'batteries'", "1bardesign", "Zlib"),                       func_url("https://github.com/1bardesign/batteries") },
        { Text:text("menu.credits.asset_item", "'mlib'", "davisdude", "Zlib"),                             func_url("https://github.com/davisdude/mlib") },
        { Text:text("menu.credits.asset_item", "'Fira Code'", "The Fira Code Project Authors", "OFL-1.1"), func_url("https://github.com/tonsky/FiraCode/") },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    menus.credits_sounds = Menu:new(game, {
        { "<<< freesound.org credits >>>" },
        { "" },
        { Text:text("menu.credits.asset_item", "'jf Glass Breaking.wav'", "cmusounddesign", "CC BY 3.0"),                    func_url("https://freesound.org/people/cmusounddesign/sounds/85168/") },
        { Text:text("menu.credits.asset_item", "'Glass Break'", "avrahamy", "CC0"),                                          func_url("https://freesound.org/people/avrahamy/sounds/141563/") },
        { Text:text("menu.credits.asset_item", "'Glass shard tinkle texture'", "el-bee", "CC BY 4.0"),                       func_url("https://freesound.org/people/el-bee/sounds/636238/") },
        { Text:text("menu.credits.asset_item", "'Bad Beep (Incorrect)'", "RICHERlandTV", "CC BY 3.0"),                       func_url("https://freesound.org/people/RICHERlandTV/sounds/216090/") },
        { Text:text("menu.credits.asset_item", "[Keyboard press]", "MattRuthSound", "CC BY 3.0"),                            func_url("https://freesound.org/people/MattRuthSound/sounds/561661/") },
        { Text:text("menu.credits.asset_item", "'Paper Throw Into Air(fuller) 2'", "RossBell", "CC0"),                       func_url("https://freesound.org/people/RossBell/sounds/389442/") },
        { Text:text("menu.credits.asset_item", "'Slime'", "Lukeo135", "CC0"),                                                func_url("https://freesound.org/people/Lukeo135/sounds/530617/") },
        { Text:text("menu.credits.asset_item", "'brushes_on_snare'", "Heigh-hoo", "CC0"),                                    func_url("https://freesound.org/people/Heigh-hoo/sounds/20297/") },
        { Text:text("menu.credits.asset_item", "'01 Elevator UP'", "soundslikewillem", "CC BY 4.0"),                         func_url("https://freesound.org/people/soundslikewillem/sounds/340747/") },
        { Text:text("menu.credits.asset_item", "'indsustrial_elevator_door_open'", "joedeshon", "CC BY 4.0"),                func_url("https://freesound.org/people/joedeshon/sounds/368737/") },
        { Text:text("menu.credits.asset_item", "'indsustrial_elevator_door_close'", "joedeshon", "CC BY 4.0"),               func_url("https://freesound.org/people/joedeshon/sounds/368738/") },
        { Text:text("menu.credits.asset_item", "'Footsteps on gravel'", "Joozz", "CC BY 4.0"),                               func_url("https://freesound.org/people/Joozz/sounds/531952/") },
        { Text:text("menu.credits.asset_item", "'THE CRASH'", "sandyrb", "CC BY 4.0"),                                       func_url("https://freesound.org/people/sandyrb/sounds/95078/") },
        { Text:text("menu.credits.asset_item", "'Door slam - Gun shot'", "coolguy244e", "CC BY 4.0"),                        func_url("https://freesound.org/people/coolguy244e/sounds/266915/") },
        { Text:text("menu.credits.asset_item", "'bee fly'", "soundmary", "CC BY 4.0"),                                       func_url("https://freesound.org/people/soundmary/sounds/194932/") },
        { Text:text("menu.credits.asset_item", "'Pop, Low, A (H1)'", "InspectorJ", "CC BY 4.0"),                             func_url("https://freesound.org/people/InspectorJ/sounds/411639/") },
        { Text:text("menu.credits.asset_item", "'Crack 1'", "JustInvoke", "CC BY 3.0"),                                      func_url("https://freesound.org/people/JustInvoke/sounds/446118/") },
        { Text:text("menu.credits.asset_item", "'Emergency Siren'", "onderwish", "CC0"),                                     func_url("https://freesound.org/people/onderwish/sounds/470504/") },
        { Text:text("menu.credits.asset_item", "'Wood burning in the stove'", "smand", "CC0"),                               func_url("https://freesound.org/people/smand/sounds/521118/") },
        { Text:text("menu.credits.asset_item", "'Bike falling down an escalator'", "dundass", "CC BY 3.0"),                  func_url("https://freesound.org/people/dundass/sounds/509831/") },
        { Text:text("menu.credits.asset_item", "'squishing and squeezing a wet sponge in a bowl'", "breadparticles", "CC0"), func_url("https://freesound.org/people/breadparticles/sounds/575332/#comments") },
        { Text:text("menu.credits.asset_item", "'Insect Bug Smash & Crush'", "EminYILDIRIM", "CC BY 4.0"),                   func_url("https://freesound.org/people/EminYILDIRIM/sounds/570767/") },
        { Text:text("menu.credits.asset_item", "'Inhaler  Puff 170427_1464'", "megashroom", "CC0"),                          func_url("https://freesound.org/s/390174/") },
        { Text:text("menu.credits.asset_item", "'Poof/Puff'", "JustInvoke", "CC BY 4.0"),                                    func_url("https://freesound.org/s/446124/") },
        { Text:text("menu.credits.asset_item", "'rolling bag'", "Sunejackie", "CC BY 4.0"),                                  func_url("https://freesound.org/s/542402/") },
        -- { Text:text("menu.credits.asset_item", "'Ruler Bounce 3'", "belanhud", "CC0"),                         func_url("https://freesound.org/s/537904/")},
        { Text:text("menu.credits.asset_item", "'Springboard A'", "lmbubec", "CC0"),                                         func_url("https://freesound.org/s/119793/") },
        { Text:text("menu.credits.asset_item", "'Springboard B'", "lmbubec", "CC0"),                                         func_url("https://freesound.org/s/119794/") },
        { Text:text("menu.credits.asset_item", "'80s alarm'", "tim.kahn", "CC BY 4.0"),                                      func_url("https://freesound.org/s/83280/") },
        { Text:text("menu.credits.asset_item", "'Metal container impact firm'", "jorickhoofd", "CC BY 4.0"),                 func_url("https://freesound.org/s/160077/") },
        { Text:text("menu.credits.asset_item", "'Roller blind circuit breaker'", "newlocknew", "CC BY 4.0"),                 func_url("https://freesound.org/s/583451/") },
        { Text:text("menu.credits.asset_item", "'Digging, Ice, Hammer, A'", "InspectorJ", "CC BY 4.0"),                      func_url("https://freesound.org/s/420878/ ") },
        { Text:text("menu.credits.asset_item", "'Whoosh For Whip Zoom'", "BennettFilmTeacher", "CC0"),                      func_url("https://freesound.org/s/420878/ ") },
        { Text:text("menu.credits.asset_item", "'Balloon_Inflate_Quick_Multiple'", "Terhen", "CC BY 3.0"),                      func_url("https://freesound.org/s/420878/ ") },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    local items = {
        { "<<<<<<<<< CONGRATULATIONS! >>>>>>>>>" },
        { "" },
        { StatsMenuItem, Text:text("menu.game_over.kills"), function(self)
            return game.stats
                .kills
        end },
        { StatsMenuItem, Text:text("menu.game_over.time"), function(self)
            return time_to_string(game.stats.time)
        end },
        { StatsMenuItem, Text:text("menu.game_over.floor"), function(self)
            return concat(game.stats.floor, "/",
                game.level.max_floor)
        end },
        { "" },
        { "❤ " .. Text:text("menu.win.wishlist") .. " 🔗", func_url("steam://advertise/2957130/") },
        { "▶ " .. Text:text("menu.win.continue"), function()
            --scotch
            game.has_seen_controller_warning = true
            game:new_game()
        end },
        { "" },

    }

    if not DEMO_BUILD then
        table.remove(items, 7) -- Remove whishlist if not demo
    end

    menus.win = Menu:new(game, items, { 0, 0, 0, 0.85 }, PROMPTS_GAME_OVER)

    ------------------------------------------------------------

    menus.joystick_removed = Menu:new(game, {
        { "<<<<<<<<< " .. Text:text("menu.joystick_removed.title") .. " >>>>>>>>>" },
        { "" },
        { Text:text("menu.joystick_removed.description") },
        { "", nil,
            function(self)
                local keyset = {}
                for joystick, _ in pairs(game.menu_manager.joystick_wait_set) do
                    local player_n = Input:get_joystick_user_n(joystick)
                    table.insert(keyset, { player_n, joystick:getName() })
                end
                table.sort(keyset, function(a, b) return a[1] < b[1] end)

                local s = ""
                for _, value in pairs(keyset) do
                    s = s .. "🎮 " .. Text:text("menu.joystick_removed.item", value[1], value[2]) .. "\n"
                end

                self:set_label_text(s)
                --..concat("\n", game.menu_manager.joystick_wait_cooldown, " (", game.menu_manager.joystick_wait_mode, ")")
            end,
        },
        { "" },
        { "" },
        { "" },
        { "" },
        { "⚠ " .. Text:text("menu.joystick_removed.continue"),
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
