require "scripts.util"
local Class = require "scripts.meta.class"
local skins = require "data.skins"

local QueuedPlayer = Class:inherit()

function QueuedPlayer:init(player_n, input_profile_id, joystick)
    self.t = 0
    self.player_n = player_n
    self.input_profile_id = input_profile_id
    self.joystick = joystick

    self.selection_n = player_n
    self.selection = skins[self.selection_n]
    self.squash = 1
    self.selection_ox = 0
    self.left_prompt_ox = 0
    self.right_prompt_ox = 0
    self.scale = 0

	self.is_removed = false
end

function QueuedPlayer:update(dt)
	self.t = self.t + dt
    self.is_pressed = Input:action_pressed(self.player_n, "ui_select")
    if self.t > 0.1 and Input:action_pressed(self.player_n, "ui_select") then
        self:on_confirm()
    end

    if Input:action_pressed(self.player_n, "ui_left") then
        self:increment_selection(-1)
    end
    if Input:action_pressed(self.player_n, "ui_right") then
        self:increment_selection(1)
    end

    self.squash = move_toward(self.squash, 1, 5*dt)
    self.selection_ox = move_toward(self.selection_ox, 0, 90*dt)
    self.scale = lerp(self.scale, 1, 0.1)
    self.left_prompt_ox = move_toward(self.left_prompt_ox, 0, 40*dt)
    self.right_prompt_ox = move_toward(self.right_prompt_ox, 0, 40*dt)
end

function QueuedPlayer:on_confirm()
    Input:get_user(self.player_n):set_skin(self.selection)

    game:join_game(self.player_n)
    self.is_removed = true
end

local function _draw_rotated_rectangle(color, mode, x, y, width, height, angle)
	-- We cannot rotate the rectangle directly, but we
	-- can move and rotate the coordinate system.
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(angle)
	rect_color(color, mode, -width/2, -height/2, width, height, 6, 6) -- origin in the middle
	love.graphics.pop()
end

function QueuedPlayer:draw(x, y)
    local w = 42 * self.scale
    local palette = self.selection.color_palette
    _draw_rotated_rectangle(palette[3], "fill", x + self.selection_ox*0.1, y, w, w, self.t*2 + pi*2)
    _draw_rotated_rectangle(palette[2], "fill", x + self.selection_ox*0.3, y, w, w, -self.t + pi/5)
    _draw_rotated_rectangle(palette[1], "fill", x + self.selection_ox*0.5, y, w, w, self.t)
    
    if self.selection then
        draw_centered(self.selection.spr_idle, x + self.selection_ox, y, 0, self.squash, 1/self.squash)
        local text = string.upper(Text:text("player.name."..self.selection.text_key) or "")
        print_centered_outline(nil, nil, text, x+1+self.selection_ox, y - 20 + 1)
        print_centered_outline(nil, nil, text, x+1+self.selection_ox, y - 20)
    end
    -- print_centered_outline(nil, ncil, table_to_str(self.choices), x+1+self.selection_ox, y - 100)

    local ox, oy = math.cos(self.t*5) * 1, math.sin(self.t*5) * 1
    circle_color(palette[1], "fill", x + ox, y + oy + w*0.6 - 2, 10.5)
    local icon_left = Input:get_action_primary_icon(self.player_n, "ui_left")
    local icon_right = Input:get_action_primary_icon(self.player_n, "ui_right")
    local icon_select = Input:get_action_primary_icon(self.player_n, "ui_select")
    draw_centered(icon_left,   x - w/2 + self.left_prompt_ox, y, 0, self.scale)
    draw_centered(icon_right,  x + w/2 + self.right_prompt_ox, y, 0, self.scale)
    draw_centered(icon_select, x, y + w*0.6, 0, self.scale)
end

function QueuedPlayer:on_other_joined(player)
    local id
    if player and player.skin and player.skin.id then
        id = player.skin.id
    end

    if id == self.selection_n then
        self:increment_selection(1)
    end
end

function QueuedPlayer:increment_selection(diff)
    for i=1, #skins do
        self.selection_n = mod_plus_1(self.selection_n + diff, #skins)
        if game.skin_choices[self.selection_n] then
            self.selection = skins[self.selection_n]
            break
        end
    end
    self.squash = 1.5
    self.selection_ox = diff * 10
    self.left_prompt_ox = diff * 4
end

return QueuedPlayer