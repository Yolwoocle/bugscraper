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

COL_MID_DARK_GREEN = rgb(38, 92, 66)
COL_DARK_GREEN = rgb(25, 60, 62)

COL_SKY = rgb(104, 174, 212)

COL_BLACK_BLUE = rgb(24, 20, 37)
COL_DARK_BLUE = rgb(18, 78, 137)
COL_MID_BLUE = rgb(0, 149, 233)
COL_LIGHT_BLUE = color(0x2ce8f5)

COL_DARK_PURPLE = rgb(104, 56, 108)

SELECTED_HIGHLIGHT_COLOR = COL_LIGHT_RED

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

BUTTON_HOLD_REPEAT_TIME = 0.35
BUTTON_HOLD_REPEAT_INTERVAL = 0.07

AXIS_DEADZONE = 0.2
AXIS_FUNCTIONS = {
    leftstickxpos =  function(joystick) return joystick:getAxis(1) >  AXIS_DEADZONE end,
    leftstickxneg =  function(joystick) return joystick:getAxis(1) < -AXIS_DEADZONE end,
    leftstickypos =  function(joystick) return joystick:getAxis(2) >  AXIS_DEADZONE end,
    leftstickyneg =  function(joystick) return joystick:getAxis(2) < -AXIS_DEADZONE end,

    rightstickxpos = function(joystick) return joystick:getAxis(3) >  AXIS_DEADZONE end,
    rightstickxneg = function(joystick) return joystick:getAxis(3) < -AXIS_DEADZONE end,
    rightstickypos = function(joystick) return joystick:getAxis(4) >  AXIS_DEADZONE end,
    rightstickyneg = function(joystick) return joystick:getAxis(4) < -AXIS_DEADZONE end,

    lefttrigger =    function(joystick) return joystick:getAxis(5) > -1 + AXIS_DEADZONE end,
    righttrigger =   function(joystick) return joystick:getAxis(6) > -1 + AXIS_DEADZONE end,
}
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