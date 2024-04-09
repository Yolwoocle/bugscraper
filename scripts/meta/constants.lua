local function rgb(r,g,b)
	return {r/255, g/255, b/255, 1}
end

local function color(hex)
	if not hex then  return  {1.0, 1.0, 1.0}  end
	if type(hex) ~= "number" then  return {1.0, 1.0, 1.0}  end

	local b = hex % 256;  hex = (hex - b) / 256
	local g = hex % 256;  hex = (hex - b) / 256
	local r = hex % 256
	return {r/255, g/255, b/255}
end

CANVAS_WIDTH = 480
CANVAS_HEIGHT = 270

--------------------------------------------- 

BLOCK_WIDTH = 16
BW = BLOCK_WIDTH

--------------------------------------------- 

MAX_NUMBER_OF_PLAYERS = 4

--------------------------------------------- 

COL_WHITE = {1, 1, 1, 1}
COL_BLACK = {0, 0, 0, 1}
COL_RED = {1, 0, 0, 1}
COL_YELLOW = {1, 1, 0, 1}
COL_GREEN = {0, 1, 0, 1}
COL_CYAN = {0, 1, 1, 1}
COL_BLUE = {0, 0, 1, 1}
COL_MAGENTA = {1, 0, 1, 1}

-- Reference is EDG32 palette
COL_VERY_DARK_GRAY = rgb(38, 43, 68)
COL_DARK_GRAY = rgb(58, 68, 102)
COL_MID_GRAY = color(0x5a6988)
COL_LIGHT_GRAY = color(0x8b9bb4)
COL_LIGHTEST_GRAY = color(0xc0cbdc)

COL_DARK_RED = rgb(158, 40, 53)
COL_LIGHT_RED = color(0xe43b44)
COL_PINK = color(0xf6757a)

COL_YELLOW_ORANGE = color(0xfeae34)
COL_ORANGE = color(0xf77622)

COL_LIGHT_BROWN = color(0xb86f50)
COL_MID_BROWN = color(0x743f39)
COL_DARK_BROWN = rgb(63, 40, 50)

COL_LIGHT_YELLOW = color(0xfee761)

COL_LIGHT_GREEN = color(0x63c74d)
COL_MID_DARK_GREEN = rgb(38, 92, 66)
COL_DARK_GREEN = rgb(25, 60, 62)

COL_SKY = rgb(104, 174, 212)

COL_BLACK_BLUE = rgb(24, 20, 37)
COL_DARK_BLUE = rgb(18, 78, 137)
COL_MID_BLUE = rgb(0, 149, 233)
COL_LIGHT_BLUE = color(0x2ce8f5)

COL_DARK_PURPLE = rgb(104, 56, 108)

SELECTED_HIGHLIGHT_COLOR = COL_LIGHT_RED
LOGO_COLS = {COL_LIGHT_YELLOW, COL_LIGHT_BLUE, COL_LIGHT_RED}
MENU_PADDING = CANVAS_WIDTH * 0.25

---------------------------------------------

MAX_ASSIGNABLE_BUTTONS = 8

INPUT_TYPE_KEYBOARD = "k"
INPUT_TYPE_CONTROLLER = "c"

BUTTON_STYLE_SWITCH = "switch"
BUTTON_STYLE_PLAYSTATION4 = "playstation4"
BUTTON_STYLE_PLAYSTATION5 = "playstation5"
BUTTON_STYLE_XBOX = "xbox"
BUTTON_STYLE_GENERIC = "generic"
BUTTON_STYLE_DETECT = "detect"
BUTTON_STYLES = {
	BUTTON_STYLE_SWITCH,
	BUTTON_STYLE_PLAYSTATION4,
	BUTTON_STYLE_PLAYSTATION5,
	BUTTON_STYLE_XBOX,
	BUTTON_STYLE_DETECT,
}
CONTROLLER_BRANDS = {
    BUTTON_STYLE_SWITCH,
    BUTTON_STYLE_PLAYSTATION4,
    BUTTON_STYLE_PLAYSTATION5, 
    BUTTON_STYLE_XBOX,
}

BUTTON_HOLD_REPEAT_TIME = 0.35
BUTTON_HOLD_REPEAT_INTERVAL = 0.07

RAW_INPUT_MAP_DEFAULT_EMPTY = {
    left =      {},
    right =     {},
    up =        {},
    down =      {},
    jump =      {},
    shoot =     {},
    pause =     {},
    
    ui_select = {},
    ui_back =   {},
    ui_left =   {},
    ui_right =  {},
    ui_up =     {},
    ui_down =   {},
    ui_reset_keys = {},
    split_keyboard = {},
    leave_game = {},

    debug = {}
}

RAW_INPUT_MAP_DEFAULT_GLOBAL = {
    left =      {},
    right =     {},
    up =        {},
    down =      {},
    jump =      {"k_c", "k_b", "c_a", "c_b"},
    shoot =     {},
    pause =     {},
    
    ui_select = {},
    ui_back =   {},
    ui_left =   {},
    ui_right =  {},
    ui_up =     {},
    ui_down =   {},
    ui_reset_keys = {},
    split_keyboard = {"k_space"},
    leave_game = {},

    debug = {"k_f1", "c_back"},
}

RAW_INPUT_MAP_DEFAULT_CONTROLLER = {
    left =      {"c_leftstickxneg", "c_dpleft"},
    right =     {"c_leftstickxpos", "c_dpright"},
    up =        {"c_leftstickyneg", "c_dpup"},
    down =      {"c_leftstickypos", "c_dpdown"},
    jump =      {"c_a", "c_b"},
    shoot =     {"c_x", "c_y", "c_righttrigger"},
    pause =     {"c_start"},
    
    ui_select = {"c_a"},
    ui_back =   {"c_b"},
    ui_left =   {"c_leftstickxneg", "c_dpleft"},
    ui_right =  {"c_leftstickxpos", "c_dpright"},
    ui_up =     {"c_leftstickyneg", "c_dpup"},
    ui_down =   {"c_leftstickypos", "c_dpdown"},
    ui_reset_keys = {"c_lefttrigger"},
    split_keyboard = {},
    leave_game = {"c_lefttrigger"},

    debug = {},
}

RAW_INPUT_MAP_DEFAULT_KEYBOARD_SOLO = {
    left =      {"k_left", "k_a"},
    right =     {"k_right", "k_d"},
    up =        {"k_up", "k_w"},
    down =      {"k_down", "k_s"},
    jump =      {"k_c", "k_b"},
    shoot =     {"k_x", "k_v"},
    pause =     {"k_escape", "k_p"},
    
    ui_select = {"k_c", "k_b", "k_return"},
    ui_back =   {"k_x", "k_escape", "k_backspace"},
    ui_left =   {"k_left", "k_a"},
    ui_right =  {"k_right", "k_d"},
    ui_up =     {"k_up", "k_w"},
    ui_down =   {"k_down", "k_s"},
    ui_reset_keys = {"k_tab"},
    split_keyboard = {},
    leave_game = {"k_tab"},

    debug = {},
}

RAW_INPUT_MAP_DEFAULT_SPLIT_KEYBOARD_P1 = {
    left =      {"k_a"},
    right =     {"k_d"},
    up =        {"k_w"},
    down =      {"k_s"},
    jump =      {"k_f"},
    shoot =     {"k_g"},
    pause =     {"k_escape", "k_p"},
    
    ui_select = {"k_f"},
    ui_back =   {"k_g", "k_escape"},
    ui_left =   {"k_a"},
    ui_right =  {"k_d"},
    ui_up =     {"k_w"},
    ui_down =   {"k_s"},
    ui_reset_keys = {"k_tab"},
    split_keyboard = {},
    leave_game = {"k_tab"},

    debug = {},
}

RAW_INPUT_MAP_DEFAULT_SPLIT_KEYBOARD_P2 = {
    left =      {"k_h"},--, "k_left"},
    right =     {"k_k"},--, "k_right"},
    up =        {"k_u"},--, "k_up"},
    down =      {"k_j"},--, "k_down"},
    jump =      {"k_l"},
    shoot =     {"k_;"},
    pause =     {"k_escape", "k_p"},
    
    ui_select = {"k_l", "k_return"},
    ui_back =   {"k_k", "k_backspace"},
    ui_left =   {"k_h", "k_left"},
    ui_right =  {"k_k", "k_right"},
    ui_up =     {"k_u", "k_up"},
    ui_down =   {"k_j", "k_down"},
    ui_reset_keys = {"k_o"},
    split_keyboard = {},
    leave_game = {"k_o"},

    debug = {},
}

UI_ACTIONS = {"ui_up", "ui_down", "ui_left", "ui_right", "ui_select", "ui_back", "pause"}

AXIS_TABLE = {
    leftstickxpos =  true,
    leftstickxneg =  true,
    leftstickypos =  true,
    leftstickyneg =  true,

    rightstickxpos = true,
    rightstickxneg = true,
    rightstickypos = true,
    rightstickyneg = true,

    lefttrigger =    true,
    righttrigger =   true,
}

AXIS_DEADZONE = 0.2
AXIS_ANGLE_MARGIN = 3 * math.pi/8
AXIS_TO_KEY_NAME_MAP = {
    ["leftx+"] = "leftstickxpos",
    ["leftx-"] = "leftstickxneg",
    ["lefty+"] = "leftstickypos",
    ["lefty-"] = "leftstickyneg",

    ["rightx+"] = "rightstickxpos",
    ["rightx-"] = "rightstickxneg",
    ["righty+"] = "rightstickypos",
    ["righty-"] = "rightstickyneg",

    ["triggerleft+"] = "lefttrigger",
    ["triggerleft-"] = "lefttrigger",
    ["triggerright+"] = "righttrigger",
    ["triggerright-"] = "righttrigger",
}

GLOBAL_INPUT_USER_PLAYER_N = -1

--------------------------------------------- 

MUSIC_MODE_OFF = "off"
MUSIC_MODE_INGAME = "ingame"
MUSIC_MODE_PAUSE = "pause"

--------------------------------------------- 

UPGRADE_TYPE_TEMPORARY = "temporary"
UPGRADE_TYPE_INSTANT = "instant"
UPGRADE_TYPE_PERMANENT = "permanent"

UPGRADE_TARGET_SINGLE = "single"
UPGRADE_TARGET_ALL = "all"

--------------------------------------------- 

SMASH_EASTER_EGG_PROBABILITY = 1/50