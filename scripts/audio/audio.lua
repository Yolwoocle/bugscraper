require "scripts.util"
local Class = require "scripts.meta.class"
local images = require "data.images"
local sounds = require "data.sounds"

local AudioManager = Class:inherit()

function AudioManager:init()
end

function AudioManager:update(dt)
end

function AudioManager:play(snd, volume, pitch)
    -- Formalize inputs
    local sndname = snd
	if type(snd) == "table" then
        sndname = random_sample(snd)
    end

    volume = volume or 1
    pitch = pitch or 1
    
    if not Options:get("sound_on") then  return  end
	
    local sound = self:get_sound(sndname)
    if sound == nil then   return   end
	
	-- for i, s in ipairs(snd_table) do
	-- 	if not s:isPlaying() then
	-- 		local source = s
	-- 		source:setVolume(volume * snd_table.volume)
	-- 		source:setPitch(pitch   * snd_table.pitch)
	-- 		source:play()

	-- 		return
	-- 	end
	-- end

	local new_sound = sound:clone()
	new_sound:set_volume(volume * sound.volume)
	new_sound:set_pitch(pitch * sound.pitch)
	new_sound:play()
end

function AudioManager:play_pitch(snd, pitch, object)
	if not snd then      return   end
	if pitch <= 0 then   return   end

	local sfx = sounds[snd]
	if not sfx then   return   end
	sfx:setPitch(pitch)
	if object then self:set_source_position_relative_to_object(sfx, object) end
	self:play(sfx)
	--snd:setPitch(1)
end

function AudioManager:play_random_pitch(snd, var, object)
	var = var or 0.2
	local pitch = random_range(1/var, var)
	self:play_pitch(snd, pitch, object)
end

function AudioManager:play_var(snd, vol_var, pitch_var, parms)
	parms = parms or {}
	var = var or 0.2
	vol_var = vol_var or 0
	pitch_var = pitch_var or 1
	local def_vol = parms.volume or 1
	local volume = random_range(def_vol-vol_var, def_vol)
	local pitch = random_range(1/pitch_var, pitch_var) * (parms.pitch or 1)
	self:play(snd, volume, pitch, parms.object)
end

function AudioManager:set_music(name)
	-- Unused
	local track = self.music_tracks[name]
	if track then
		self.curmusic_name = name
		self.curmusic = track
	end
end

function AudioManager:play_music()
	if game.music_on then
		self.curmusic:play()
	end
end

function AudioManager:pause_music()
	self.curmusic:pause()
end

function AudioManager:on_leave_start_area()
	self:play_music()
end

function AudioManager:on_pause()
	self:pause_music()
end

function AudioManager:on_unpause()
	self:play_music()
end

function AudioManager:set_source_position_relative_to_object(source, obj)
	if not source then print("AudioManager:set_source_position_relative_to_object : No source defined!") return end
	if not obj then print("AudioManager:set_source_position_relative_to_object : No object defined!") return end
	local mult = 0.05
	source:setPosition(
		mult * (obj.x - CANVAS_WIDTH*.5) / (CANVAS_WIDTH),
		mult * (obj.y - CANVAS_HEIGHT*.5) / (CANVAS_HEIGHT)
	)
end

function AudioManager:get_sound(name)
    if type(name) == "string" then
		-- Substitute patterns like "sfx_jump_{01-05}" to "sfx_jump_XX" (XX is a random value between 01 and 05)
		name = name:gsub("{(.-)%-(.-)}", function(a_str, b_str)
			assert(type(a_str) == "string", "argument a is not a string (in '"..tostring(name).."')")
			assert(type(b_str) == "string", "argument b is not a string (in '"..tostring(name).."')")
			local len = math.max(#a_str, #b_str)
			local a = tonumber(a_str)
			local b = tonumber(b_str)
			assert(type(a) == "number", "argument a is not a number (in '"..tostring(name).."')")
			assert(type(b) == "number", "argument b is not a number (in '"..tostring(name).."')")
			local n = random_range_int(a, b)
			return string.format("%0"..len.."d", n)
		end)
	end

	return sounds[name]
end

return AudioManager