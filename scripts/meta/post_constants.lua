-- For constants that are loaded after util or have dependencies
require "scripts.util"
local Rect = require "scripts.math.rect"

RECT_ELEVATOR = Rect:new(2, 2, 27, 15)
RECT_CAFETERIA = Rect:new(2, 2, 68, 15)

---------------------------------------------