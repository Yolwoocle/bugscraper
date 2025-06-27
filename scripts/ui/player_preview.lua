require "scripts.util"
local Class = require "scripts.meta.class"
local StateMachine = require "scripts.state_machine"
local images = require "data.images"
local skins = require "data.skins"
local utf8 = require "utf8"

local PlayerPreview = Class:inherit()

function PlayerPreview:init(player_n, x, y, w, h)
    self.player_n = player_n
    self.x, self.y = x, y
    self.base_y = y
    self.w, self.h = w, h

    self.prompts = {}

    self.primary_color = nil
    self.secondary_color = nil
    self.prompt_x_alignment = "center"
    self.prompt_y_alignment = "center"
    self.padding = 6

    self.ox = 0
    self.oy = 0

    self.t = 0
    self.state_machine = StateMachine:new({
        waiting = {
            enter = function(state)
                self.prompt_x_alignment = "center"
                self.prompt_y_alignment = "center"

                self.user = nil
                self.prompts = {
                    { -1, {
                        { "join_game", INPUT_TYPE_KEYBOARD },
                        { "join_game", INPUT_TYPE_CONTROLLER, BUTTON_STYLE_XBOX },
                        { "join_game", INPUT_TYPE_CONTROLLER, BUTTON_STYLE_PLAYSTATION4 },
                    }, "", COL_WHITE },
                    { -1, {}, Text:text("input.prompts.join"), COL_WHITE },
                }
            end,
            update = function(state, dt)
                self.prompts = {
                    { -1, {
                        { "join_game", INPUT_TYPE_KEYBOARD },
                        { "join_game", INPUT_TYPE_CONTROLLER, BUTTON_STYLE_XBOX },
                        { "join_game", INPUT_TYPE_CONTROLLER, BUTTON_STYLE_PLAYSTATION4 },
                    }, "", COL_WHITE },
                    { -1, {}, Text:text("input.prompts.join"), COL_WHITE },
                }

                local number_of_keyboard_users = Input:get_number_of_users(INPUT_TYPE_KEYBOARD)
                if number_of_keyboard_users == 1 then
                    table.remove(self.prompts[1][2], 1)

                    if self.player_n == Input:find_free_user_number() then
                        table.insert(self.prompts, {
                            -1, { "split_keyboard" }, "", COL_WHITE
                        })
                        table.insert(self.prompts, {
                            -1, {}, Text:text("input.prompts.split_keyboard"), COL_WHITE
                        })
                    end
                end

                if Input:get_user(self.player_n) then
                    return "character_select"
                end
            end,
            draw = function(state)
                self:draw_bg_card_empty()
            end,
            exit = function(state)
                self.user = Input:get_user(self.player_n)
            end
        },

        character_select = {
            enter = function(state)
                self.prompt_x_alignment = "center"
                self.prompt_y_alignment = "end"

                self.t = 0
            
                self.selection_n = self:find_first_free_skin(self.player_n)
                self.selection = skins[self.selection_n]
                self.squash = 1
                self.selection_ox = 0
                self.left_prompt_ox = 0
                self.right_prompt_ox = 0
                self.scale = 0

                self.queued_player = game.queued_players[self.player_n]

                self.prompts = {
                    { self.player_n, { "ui_back" }, "🔙", COL_WHITE, x_alignment = "start", y_alignment = "start" },
                    { self.player_n, { "ui_select" }, Text:text("input.prompts.ui_select"), COL_WHITE },
                }
            end,
            update = function(state, dt)
                if not self.queued_player or self.queued_player.is_removed then
                    self.queued_player = nil
                    if Input:get_user(self.player_n) then
                        return "tutorial"
                    else
                        return "waiting"
                    end
                end

                self.t = self.t + dt
                self.is_pressed = Input:action_pressed(self.player_n, "ui_select")
                if self.t > 0.1 and Input:action_pressed(self.player_n, "ui_select") then
                    self:confirm_character_select()
                end
                if self.t > 0.1 and Input:action_pressed(self.player_n, "ui_back") then
                    self:cancel_character_select()
                end

                if Input:action_pressed(self.player_n, "ui_left") then
                    self:increment_character_selection(-1)
                    Audio:play_var("ui_menu_hover_{01-04}", 0.2, 1, {pitch= 1.5})
                end
                if Input:action_pressed(self.player_n, "ui_right") then
                    self:increment_character_selection(1)
                    Audio:play_var("ui_menu_hover_{01-04}", 0.2, 1, {pitch= 1.5})
                end

                self.squash = move_toward(self.squash, 1, 5 * dt)
                self.selection_ox = move_toward(self.selection_ox, 0, 90 * dt)
                self.scale = lerp(self.scale, 1, 0.1)
                self.left_prompt_ox = move_toward(self.left_prompt_ox, 0, 40 * dt)
                self.right_prompt_ox = move_toward(self.right_prompt_ox, 0, 40 * dt)
            end,
            draw = function(state)
                self:draw_bg_card_empty()

                if not self.queued_player or self.queued_player.is_removed or not Input:get_user(self.player_n) then
                    return
                end

                local x = self.x + self.ox + self.w / 2
                local y = self.y + self.oy + 18

                local w = 32 * self.scale
                local palette = self.selection.color_palette
                self:draw_rotated_rectangle(palette[3], "fill", x + self.selection_ox * 0.1, y, w, w, self.t * 2 + pi * 2)
                self:draw_rotated_rectangle(palette[2], "fill", x + self.selection_ox * 0.3, y, w, w, -self.t + pi / 5)
                self:draw_rotated_rectangle(palette[1], "fill", x + self.selection_ox * 0.5, y, w, w, self.t)

                if self.selection then
                    draw_centered(self.selection.img_walk_down, x + self.selection_ox, y, 0, self.squash, 1 / self.squash)
                    local text = utf8.upper(Text:text("player.name." .. self.selection.text_key) or "")
                    print_centered_outline(palette[1], nil, text, x + 1 + self.selection_ox, y + 18 + 1)
                    print_centered_outline(palette[1], nil, text, x + 1 + self.selection_ox, y + 18)

                    -- print_color(palette[2], Text:text("menu.number", self.selection_n), self.x + self.ox + self.padding, self.y)
                end

                -- Bottom dots
                local total_n = #skins
                for i = 1, total_n do
                    local ix = x - (total_n*4)/2 + 4*(i-1)

                    local _y = y + 26 + ternary(i == self.selection_n, -1, 0)
                    rect_color(ternary(i == self.selection_n, COL_WHITE, COL_BLACK_BLUE), "fill", ix, _y - 1, 4, ternary(i == self.selection_n, 5, 3))

                    local col = skins[i].color_palette[1]
                    if not game.skin_choices[i] then
                        col = COL_BLACK_BLUE
                    end
                    rect_color(col, "fill", ix+1, _y, 2, ternary(i == self.selection_n, 3, 1))
                end

                local icon_left = Input:get_action_primary_icon(self.player_n, "ui_left")
                local icon_right = Input:get_action_primary_icon(self.player_n, "ui_right")
                draw_centered(icon_left,  x - w * 0.8 + self.left_prompt_ox,  y + 18, 0, self.scale)
                draw_centered(icon_right, x + w * 0.8 + self.right_prompt_ox, y + 18, 0, self.scale)
            end,
        },

        tutorial = {
            enter = function(state)
                self.prompt_x_alignment = "start"
                self.prompt_y_alignment = "center"
                
                self.prompts = {
                    { self.player_n, { "up" }, Text:text("input.prompts.move"), COL_WHITE },
                    { self.player_n, { "jump" }, Text:text("input.prompts.jump"), COL_WHITE },
                    { self.player_n, { "shoot" }, Text:text("input.prompts.shoot"), COL_WHITE },
                }
                
                if self.user:get_skin() then
                    self.primary_color = self.user:get_skin().color_palette[1]
                    self.secondary_color = self.user:get_skin().color_palette[2]
                end

                self.oy = -8

                state.t = 0.0
                state.btn_i = 1
            end,
            update = function(state, dt)
                if not self.user or not Input:get_user(self.player_n) then
                    return "waiting"
                end

                -- TODO make this generic somewhere because this is awful 🙏
                state.t = state.t + dt
                if state.t > 1.0 then
                    state.t = state.t - 1.0
                    state.btn_i = mod_plus_1(state.btn_i + 1, 4)
                    self.prompts[1][2] = {({ "up", "left", "down", "right" })[state.btn_i]}
                end
            end,
            draw = function(state)
                self:draw_bg_card()
            end,
            exit = function(state)
                self.user = nil
            end,
        },
    }, "waiting")
end


function PlayerPreview:on_player_joined(player)
    if player.n == self.player_n then
        self.state_machine:set_state("tutorial")
    end

    local id
    if player and player.skin and player.skin.id then
        id = player.skin.id
    end

    if id == self.selection_n then
        self:increment_character_selection(1)
    end
end


function PlayerPreview:increment_character_selection(diff)
    self.selection_n = self:find_first_free_skin(mod_plus_1(self.selection_n + diff, #skins), diff)
    self.selection = skins[self.selection_n]

    self.squash = 1.5
    self.selection_ox = diff * 10
    if diff >= 0 then
        self.right_prompt_ox = diff * 4
    else
        self.left_prompt_ox = diff * 4
    end
end


function PlayerPreview:find_first_free_skin(start, diff)
    diff = diff or 1

    local skin_n = start
    for i=1, #skins do
        if game.skin_choices[skin_n] then
            return skin_n
        end
        skin_n = mod_plus_1(skin_n + diff, #skins)
    end
    return start
end

function PlayerPreview:confirm_character_select()
    Input:get_user(self.player_n):set_skin(self.selection)

    game:join_game(self.player_n)
    self.queued_player:remove()
end

function PlayerPreview:cancel_character_select()
    game:remove_queued_player(self.player_n)
    self.state_machine:set_state("waiting")
end

function PlayerPreview:draw_rotated_rectangle(color, mode, x, y, width, height, angle)
    -- We cannot rotate the rectangle directly, but we
    -- can move and rotate the coordinate system.
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    rect_color(color, mode, -width / 2, -height / 2, width, height, 6, 6) -- origin in the middle
    love.graphics.pop()
end

function PlayerPreview:update(dt)
    self.state_machine:update(dt)

    self.ox = lerp(self.ox, 0, 0.3)
    self.oy = lerp(self.oy, 0, 0.3)
    if math.abs(self.ox) <= 0.1 then self.ox = 0 end
	if math.abs(self.oy) <= 0.1 then self.oy = 0 end
end

function PlayerPreview:draw_bg_card_empty()
    local color = COL_MID_GRAY

    
    if self.state_machine.current_state_name == "waiting" then
        color = COL_MID_GRAY
        
    elseif self.state_machine.current_state_name == "character_select" then
        if self.selection then
            color = self.selection.color_palette[2]
        end
        
    elseif self.state_machine.current_state_name == "tutorial" then
        if self.user and self.user:get_skin() then
            color = self.user:get_skin().color_palette[2]
        end
    end

    exec_color(color, function() love.graphics.draw(images.player_preview_dotted, self.x + self.ox, self.y + self.oy) end)
end

function PlayerPreview:draw_input_prompts(promps)
end

function PlayerPreview:draw_player_abbreviation()
    local txt_top = ""
    local txt_bot = ""
    local color = COL_MID_GRAY
    
    if self.state_machine.current_state_name == "waiting" then
        color = COL_MID_GRAY
        
    elseif self.state_machine.current_state_name == "character_select" then
        txt_top = txt_top .. Text:text("player.abbreviation", self.player_n)
        color = self.selection.color_palette[2]
        
    end
    
    if self.state_machine.current_state_name == "tutorial" then
        txt_top = txt_top .. Text:text("player.abbreviation", self.player_n)

        if self.user and self.user:get_skin() then
            txt_bot = txt_bot .. " " .. self.user:get_skin().icon
            color = self.user:get_skin().color_palette[2]
        end
    end

    print_color(color, txt_top, self.x + self.ox + self.w - get_text_width(txt_top) - 4, self.y)--self.oy + self.h - 16)
    print_color(color, txt_bot, self.x + self.ox + self.w - get_text_width(txt_bot) - 4, self.y + self.oy + self.h - 16)
end

function PlayerPreview:draw_bg_card()
    local col = ({ COL_WHITE, COL_RED, COL_GREEN, COL_YELLOW })[self.player_n]
    local col_dark = { col[1] - 0.3, col[2] - 0.3, col[3] - 0.3, 1.0 }

    local x, y = self.x + self.ox, self.y + self.oy
    exec_color(COL_BLACK_BLUE, function() love.graphics.draw(images.player_preview_bg, x + 1, y + 2) end)
    exec_color(self.primary_color or COL_WHITE,
        function() love.graphics.draw(images.player_preview_bg, x, y) end)
    exec_color(self.secondary_color or COL_LIGHT_GRAY,
        function() love.graphics.draw(images.player_preview_detail, x, y) end)
end

function PlayerPreview:draw()
    self.state_machine:draw()
    self:draw_player_abbreviation()

    local default_prompt_height = 14
    local total_height = 0
    for _,p in pairs(self.prompts) do
        total_height = total_height + (p.height or default_prompt_height)
    end

    local y
    if self.prompt_y_alignment == "center" then
        y = self.y + self.oy + self.h / 2 - total_height / 2
    elseif self.prompt_y_alignment == "end" then
        y = self.y + self.oy + self.h - total_height - self.padding
    end

    for _, item in pairs(self.prompts) do
        local player_n, actions, label, col = unpack(item)
        if Input:get_user(player_n) then
            local prompt_x_alignment = item.x_alignment or self.prompt_x_alignment
            local x = self.x + self.ox + self.padding

            local _x, _y = x, y

            if item.y_alignment then
                if item.y_alignment == "start" then
                    _y = self.y + self.oy + self.padding
                elseif item.y_alignment == "center" then
                    _y = self.y + self.oy + self.h / 2 - total_height / 2
                elseif item.y_alignment == "end" then
                    _y = self.y + self.oy + self.h - total_height - self.padding
                end
            end

            if prompt_x_alignment == "start" then
                _x = self.x + self.padding
            elseif prompt_x_alignment == "center" then
                _x = self.x + self.w /2 
            end
            if prompt_x_alignment == "end" then
                _x = self.x + self.w - self.padding
            end
            Input:draw_input_prompt(player_n, actions, label, col, _x, _y, {
    			alignment = prompt_x_alignment,
                background_color = item.background_color,
            })
        end
        y = y + (item.height or default_prompt_height)
    end
end

return PlayerPreview
