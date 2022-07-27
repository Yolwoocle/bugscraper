require "util"

local function new_source(path, type, args)
	local source = love.audio.newSource("sfx/"..path, type)
	if not args then  return source  end
	
	if args.looping then
		source:setLooping(true)
	end
	return source
end

local sounds = {}

--music_level_1 = new_source("music/level_1.mp3", "stream", {looping = true})
local sfxnames = {
	"jump", "jump1.wav",
	"shot1", "shot1.wav",
	"shot2", "shot2.wav",
	"shot3", "shot3.wav",
	"hurt",  "hurt.wav",
	"land",  "land.wav",
	"item_collect", "item_collect.wav",
	"menu_hover", "menu_hover.wav",
	"menu_select", "menu_select.wav",
	"kill_enemy", "kill_enemy.wav",
	"wall_slide", "wall_slide.wav",

	"footstep00", "footstep00.wav",
	"footstep01", "footstep01.wav",
	"footstep02", "footstep02.wav",
	"footstep03", "footstep03.wav",
	"footstep04", "footstep04.wav",
	"footstep05", "footstep05.wav",
	"footstep06", "footstep06.wav",
	"footstep07", "footstep07.wav",
	"footstep08", "footstep08.wav",
	"footstep09", "footstep09.wav",
}

for i=1, #sfxnames, 2 do    sounds[sfxnames[i]] = new_source(sfxnames[i+1], "static")    end

sounds.shot1:setVolume(0.5)
sounds.shot2:setPitch(0.8)

for i=0,9 do
	sounds["footstep0"..tostring(i)]:setVolume(0.2)
end

return sounds