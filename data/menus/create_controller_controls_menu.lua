local menu_util = require "scripts.ui.menu.menu_util"
local Menu                = require "scripts.ui.menu.menu"
local RangeOptionMenuItem = require "scripts.ui.menu.items.range_option_menu_item"
local BoolOptionMenuItem  = require "scripts.ui.menu.items.bool_option_menu_item"
local EnumOptionMenuItem  = require "scripts.ui.menu.items.enum_option_menu_item"
local ControlsMenuItem    = require "scripts.ui.menu.items.controls_menu_item"

local DEFAULT_MENU_BG_COLOR = menu_util.DEFAULT_MENU_BG_COLOR
local PROMPTS_CONTROLS  = menu_util.PROMPTS_CONTROLS

local function create_controller_controls_menu(title, input_profile_id, player_n)
    return Menu:new(game, title, {
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
        { ControlsMenuItem, player_n, input_profile_id, INPUT_TYPE_CONTROLLER, "leave_game", "🔚 " .. Text:text("input.prompts.leave_game") },
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

return create_controller_controls_menu