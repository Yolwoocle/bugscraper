require "scripts.util"
require "scripts.meta.constants"
local Class = require "scripts.meta.class"
-- local ffi = require "scripts.ffi"

local ScreenshotManager = Class:inherit()

function ScreenshotManager:init()
	self.buffer_canvas = love.graphics.newCanvas(CANVAS_WIDTH * SCREENSHOT_SCALE, CANVAS_HEIGHT * SCREENSHOT_SCALE)
end


local function time_diff(name, func)
	local start = love.timer.getTime( )
	func()
	local result = love.timer.getTime() - start
	-- print_debug(string.format("Measure '%s': %.4f ms", name, result * 1000 ))
	return result
end
function ScreenshotManager:screenshot()
	-- Average time measured for 100 screenshots:
	-- - canvas draw:       0.0758 ms
	-- - new image data:    5.0995 ms
	-- - encode image data: 100.0161 ms
	-- TODO: put the last 2 steps into a thread to avoid lag spikes

	local filename = os.date('bugscraper_%Y-%m-%d_%H-%M-%S.png') 
	
	love.graphics.setCanvas(self.buffer_canvas)
	love.graphics.clear()
	love.graphics.draw(canvas, 0, 0, 0, SCREENSHOT_SCALE)
	love.graphics.setCanvas()
	
	local imgdata = self.buffer_canvas:newImageData()
	local imgpng = imgdata:encode("png", filename)
	
	local filepath = love.filesystem.getSaveDirectory().."/"..filename

	-- notification = "Screenshot path pasted to clipboard"
	-- love.system.setClipboardText(filepath)
	-- print(notification)

	return filename, filepath, imgdata, imgpng
end


function ScreenshotManager:screenshot_measure()
	local n = 100
	local t1 = 0
	local t2 = 0
	local t3 = 0

	local filename
	local imgdata
	local imgpng 
	local filepath
	for i = 1, n do
	
		filename = os.date('bugscraper_%Y-%m-%d_%H-%M-%S.png') 
		
		t1 = t1 + time_diff("canvas draw", function()
			love.graphics.setCanvas(self.buffer_canvas)
			love.graphics.clear()
			love.graphics.draw(canvas, 0, 0, 0, SCREENSHOT_SCALE)
			love.graphics.setCanvas()
		end)/n
	
		t2 = t2 + time_diff("new image data", function()
			imgdata = self.buffer_canvas:newImageData()
		end)/n
		t3 = t3 + time_diff("encode image data", function()
			imgpng = imgdata:encode("png", filename)
		end)/n
	
		filepath = love.filesystem.getSaveDirectory().."/"..filename
	end

	print_debug(string.format("Measure for %d screenshots:", n))
	print_debug(string.format("- canvas draw:       %.4f ms", t1 * 1000 ))
	print_debug(string.format("- new image data:    %.4f ms", t2 * 1000 ))
	print_debug(string.format("- encode image data: %.4f ms", t3 * 1000 ))

	-- notification = "Screenshot path pasted to clipboard"
	-- love.system.setClipboardText(filepath)
	-- print(notification)

	return filename, filepath, imgdata, imgpng
end

-- function screenshot_clip()
-- 	gif_timer = 0
-- 	curgif = gifcat.newGif(os.time()..".gif",window_w*gif_scale, window_h*gif_scale, 10)

-- 	-- Optional method to just print out the progress of the gif
-- 	-- Thanks to https://github.com/maxiy01/gifcat 
-- 	curgif:onUpdate(function(gif,curframes,totalframes)
-- 		print(string.format("Progress: %.2f%% (%d/%d)",gif:progress()*100,curframes,totalframes))
-- 	end)
-- 	curgif:onFinish(function(gif,totalframes)
-- 		print(totalframes.." frames written")
-- 	end)
-- end

-- function capture_clip_frame()
-- 	if curgif and gif_timer > 0.1 then
-- 		-- Save a frame to our gif.
-- 		-- love.graphics.captureScreenshot(function(screenshot) curgif:frame(screenshot) end)

-- 		local buffer_canvas = love.graphics.newCanvas(CANVAS_WIDTH * screenshot_scale, CANVAS_HEIGHT * screenshot_scale)
-- 		local imgdata = buffer_canvas:newImageData()
-- 		curgif:frame(imgdata)
		
-- 		gif_timer = gif_timer - 0.1

-- 		-- Show a little recording icon in the upper right hand corner. This will
-- 		--   not get shown in the gif because it is displayed after the call to
-- 	end
-- 	if not gif_timer then  gif_timer = 0  end
-- 	gif_timer = gif_timer + love.timer.getDelta()
-- end

return ScreenshotManager