require "scripts.meta.constants"

local function init()
    local OptionsManager = require "scripts.game.options"
    Options = OptionsManager:new()

    OPERATING_SYSTEM = love.system.getOS()
    USE_CANVAS_RESIZING = true
    SCREEN_WIDTH, SCREEN_HEIGHT = 0, 0

    if OPERATING_SYSTEM == "Web" then
        USE_CANVAS_RESIZING = false
        CANVAS_SCALE = 2
        love.window.setMode(CANVAS_WIDTH * CANVAS_SCALE, CANVAS_HEIGHT * CANVAS_SCALE, {
            fullscreen = false,
            resizable = true,
            vsync = Options:get("is_vsync"),
            minwidth = CANVAS_WIDTH,
            minheight = CANVAS_HEIGHT,
        })
    else
        love.window.setMode(Options:get("windowed_width"), Options:get("windowed_height"), {
            fullscreen = Options:get("is_fullscreen"),
            resizable = true,
            vsync = Options:get("is_vsync"),
            minwidth = CANVAS_WIDTH,
            minheight = CANVAS_HEIGHT,
        })
        if Options:get("is_window_maximized") then
            love.window.maximize()
        end
    end

    WINDOW_WIDTH, WINDOW_HEIGHT = gfx.getDimensions()
	local screen_sx = WINDOW_WIDTH / CANVAS_WIDTH
	local screen_sy = WINDOW_HEIGHT / CANVAS_HEIGHT
	local scale = math.min(screen_sx, screen_sy)
	CANVAS_OX = math.floor(max(0, (WINDOW_WIDTH - CANVAS_WIDTH * scale) / 2))
	CANVAS_OY = math.floor(max(0, (WINDOW_HEIGHT - CANVAS_HEIGHT * scale) / 2))
    
    -- Splash screen
    love.graphics.clear()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.draw(love.graphics.newImage('images/splash.png'), CANVAS_OX, CANVAS_OY, 0, scale)
    love.graphics.present()
    love.graphics.origin()
end

return init
