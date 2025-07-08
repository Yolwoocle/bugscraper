local menu_util = require "scripts.ui.menu.menu_util"
local Menu                = require "scripts.ui.menu.menu"
local RangeOptionMenuItem = require "scripts.ui.menu.items.range_option_menu_item"
local BoolOptionMenuItem  = require "scripts.ui.menu.items.bool_option_menu_item"
local EnumOptionMenuItem  = require "scripts.ui.menu.items.enum_option_menu_item"
local ControlsMenuItem    = require "scripts.ui.menu.items.controls_menu_item"

local DEFAULT_MENU_BG_COLOR = menu_util.DEFAULT_MENU_BG_COLOR
local PROMPTS_CONTROLS  = menu_util.PROMPTS_CONTROLS

local function create_solo_keyboard_controls_menu(title, input_profile_id)
    return Menu:new(game, title, {
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
        { ControlsMenuItem, -1, input_profile_id, INPUT_TYPE_KEYBOARD, "leave_game", "🔚 " .. Text:text("input.prompts.leave_game") },
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

return create_solo_keyboard_controls_menu