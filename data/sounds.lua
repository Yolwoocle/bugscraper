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
	"game_over_1", "game_over_1.wav",
	"game_over_2", "game_over_2.wav",

	"explosion", "explosion.wav",

	"footstep00", "footstep00.wav", -- CC0 https://kenney.nl/
	"footstep01", "footstep01.wav",
	"footstep02", "footstep02.wav",
	"footstep03", "footstep03.wav",
	"footstep04", "footstep04.wav",
	"footstep05", "footstep05.wav",
	"footstep06", "footstep06.wav",
	"footstep07", "footstep07.wav",
	"footstep08", "footstep08.wav",
	"footstep09", "footstep09.wav",

	"metalfootstep_00", "footstep/metalfootstep_000.ogg", -- CC0 https://kenney.nl/
	"metalfootstep_01", "footstep/metalfootstep_001.ogg",
	"metalfootstep_02", "footstep/metalfootstep_002.ogg",
	"metalfootstep_03", "footstep/metalfootstep_003.ogg",
	"metalfootstep_04", "footstep/metalfootstep_004.ogg",

	"impactglass_heavy_000", "impactglass_heavy_000.ogg", -- CC0 https://kenney.nl/
	"impactglass_heavy_001", "impactglass_heavy_001.ogg",
	"impactglass_heavy_002", "impactglass_heavy_002.ogg",
	"impactglass_heavy_003", "impactglass_heavy_003.ogg",
	"impactglass_heavy_004", "impactglass_heavy_004.ogg",

	"impactglass_light_000", "impactglass_light_000.ogg",
	"impactglass_light_001", "impactglass_light_001.ogg",
	"impactglass_light_002", "impactglass_light_002.ogg",
	"impactglass_light_003", "impactglass_light_003.ogg",
	"impactglass_light_004", "impactglass_light_004.ogg",

	"glass_fracture", "glass_fracture.wav", -- CC BY https://freesound.org/people/cmusounddesign/sounds/85168/
	"glass_break", "glass_break.wav", 
	-- CC0  window shatter https://freesound.org/people/avrahamy/sounds/141563/
	-- + combined & deeper CCBY   glass shatter https://freesound.org/people/cmusounddesign/sounds/85168/
	-- + combined & fade out CCBY sprinkle texture https://freesound.org/people/el-bee/sounds/636238/

	"button_press", "button_press.wav",
	-- CCBY RICHERlandTV Buzz https://freesound.org/people/RICHERlandTV/sounds/216090/
	-- CCBY keypress slowed down https://freesound.org/people/MattRuthSound/sounds/561661/
	-- CC0 Impact Sound https://kenney.nl/

	"cloth1", "cloth1.wav", -- CC0 Kenney
	"cloth2", "cloth2.wav",
	"cloth3", "cloth3.wav",
	"cloth_drop", "cloth_drop.wav", -- CC0 Kenney + CC0 https://freesound.org/people/RossBell/sounds/389442/

	"larva_damage1", "larva_damage1.wav",
	"larva_damage2", "larva_damage2.wav",
	"larva_damage3", "larva_damage3.wav",
	"larva_death", "larva_death.wav",
}

for i=1, #sfxnames, 2 do    sounds[sfxnames[i]] = new_source(sfxnames[i+1], "static")    end

sounds.shot1:setVolume(0.5)
sounds.shot2:setPitch(0.8)

for i=0,9 do
	sounds["footstep0"..tostring(i)]:setVolume(0.2)
end

return sounds