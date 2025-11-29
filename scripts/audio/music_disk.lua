require "scripts.util"
local sounds = require "data.sounds"
local Class = require "scripts.meta.class"

local MusicDisk = Class:inherit()

function MusicDisk:init(sources, params)
    params = params or {}
    self.name = nil
    self.sources = sources
    
    self.volume = params.volume or 1
    self.last_advancement = 0
    self.music_mode = MUSIC_MODE_OFF
    self.current_source = self.sources[MUSIC_MODE_INGAME]

    -- Sources are assumed to be looping
    self.loop_start = param(params.loop_start, nil)
    self.loop_end = param(params.loop_end, nil)
end

function MusicDisk:update(dt)
    -- Update loop
    if self.current_source then
        local tell = self.current_source:tell()
        if self.loop_end and tell > self.loop_end then
            local start = self.loop_start or 0.0
            self.current_source:seek(start + (tell - self.loop_end))
        end
    end
end

function MusicDisk:set_name(name)
    self.name = name
end

function MusicDisk:pause()
    if self.current_source ~= nil then
        self.current_source:pause()
    end
end

function MusicDisk:play()
    if self.current_source ~= nil then
        self.current_source:play()   
    end
end

function MusicDisk:stop()
    if self.current_source ~= nil then  
        self.current_source:stop()
    end
end

function MusicDisk:set_mode(mode)
	self.music_mode = mode

    if mode == MUSIC_MODE_OFF then
        self:stop()

    elseif self.current_source ~= nil then
        local new_source = self.sources[mode]
        local time = self.current_source:tell()
        if self.current_source ~= new_source then
            self.current_source:stop()
            if new_source then
                self.current_source = new_source
                self.current_source:play()
                self.current_source:seek(time)
            end
        end
    end
end

function MusicDisk:set_volume(vol)
    for _, source in pairs(self.sources) do
        source:setVolume(vol)
    end
end

return MusicDisk