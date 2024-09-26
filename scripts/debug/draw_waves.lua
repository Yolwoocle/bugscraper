require "scripts.util"
local waves = require "data.waves"

local function debug_draw_waves(self)
    local x = self.x - CANVAS_WIDTH/2
    local y = self.y
    local slot_w = 25
    local slot_h = 10
    for i, wave in ipairs(waves) do
        love.graphics.print(concat(i, " ",wave.min, "-", wave.max), x, y)
        x = x + 50

        local total_w = slot_w * (wave.min + wave.max)/2
        love.graphics.rectangle("fill", x, y, total_w, 10)
        local weight_sum = 0
        for j, enemy in ipairs(wave.enemies) do
            weight_sum = weight_sum + enemy[2]
        end

        for j, enemy in ipairs(wave.enemies) do
            local e = enemy[1]:new()
            local image = e.spr.image
            e:remove()
			e:final_remove()

            local weight = enemy[2] 

            love.graphics.setColor(DEBUG_IMAGE_TO_COL[image] or ternary(j % 2 == 0, COL_WHITE, COL_RED))
            local w = total_w * (weight/weight_sum)
            love.graphics.rectangle("fill", x, y, w, 10)
            love.graphics.setColor(COL_WHITE)

            love.graphics.draw(image, x, y, 0, 0.8, 0.8)
            print_outline(COL_WHITE, COL_BLACK_BLUE, concat(weight), x, y)
            x = x + w
        end
        x = self.x - CANVAS_WIDTH/2
        y = y + 24
    end
end

return debug_draw_waves