require "scripts.util"
local Timer = require "scripts.timer"

local Class = require "scripts.meta.class"

local Cutscene = Class:inherit()

function Cutscene:init(scenes)
    self.scenes = scenes
    self.current_scene = nil
    self.current_scene_i = -1

    self.timer = Timer:new()
    self.is_playing = false
end

function Cutscene:set_current_scene(scene_i) 
    if self.current_scene then
        self.current_scene:exit()
    end
    self.current_scene_i = scene_i
    self.current_scene = self.scenes[self.current_scene_i]
    self.current_scene:enter()

    self.timer:start(self.current_scene.duration)
end

function Cutscene:play()
    self:set_current_scene(1)
    self.is_playing = true
end

function Cutscene:stop()
    self.is_playing = false
    self.timer:stop()
end

function Cutscene:update(dt)
    if self.is_playing then
        self.current_scene:update(dt)
        
        if self.timer:update(dt) then
            local next_i = mod_plus_1(self.current_scene_i + 1, #self.scenes)
            if next_i ~= 1 then
                self:set_current_scene(next_i)
            else
                self:stop()
            end
        end
    end
end

return Cutscene