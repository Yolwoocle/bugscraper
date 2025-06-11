require "scripts.util"
local Class = require "scripts.meta.class"
local ElevatorDoor = require "scripts.level.elevator_door"
local Timer = require "scripts.timer"

local images = require "data.images"

local Entrance = Class:inherit()

function Entrance:init(rect, door)
    self.rect = rect
    self.door = door
end