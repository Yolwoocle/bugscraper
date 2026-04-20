require "scripts.util"
local Class = require "scripts.meta.class"

local TouchScreen = Class:inherit()

-- INFORMATIONS Globales
local overlay_opactity = 0.5
local color_bg = {0.2, 0.2, 0.2, overlay_opactity} -- Fond du bouton
local color_text = {1, 1, 1, 1}                    -- Couleur du texte
local color_press = {0.4, 0.4, 0.4, overlay_opactity} -- Couleur quand on appuie

-- Constantes globales 
---- Boutons
local button_size = 50
local button_spacing = 10

---- Joystick
local joystick_radius = 100

-- VARIABLES
local presses = {} -- Stocke les touches actuellement appuyées

--[[
presses : {
    touch_id: ["t_left", "t_right", "t_up", "t_down", "t_escape"]
}
--]] 
local global_screen_pressed = false
local is_loaded = false

local joystick_id = nil 
local joystick_pos = {x = 100, y = 200, tx = nil, ty = nil}  -- x,y Le centre du joystick; tx, ty: là ou on clique
local joystick_key_pressed = {}  -- {"t_up", "t_left"}


local game = nil

local function _get_curr_menu()
    if game and game.menu_manager and game.menu_manager.cur_menu then
        return game.menu_manager.cur_menu
    end
    return nil
end

local function _is_choosing_perso()
    if not game or not game.queued_players then 
        return false
    end
    for player_n = 1,MAX_NUMBER_OF_PLAYERS do
        local queued_player = game.queued_players[player_n]
        if queued_player then
            local user = Input:get_user(player_n)
            if user and user.primary_input_type and user.primary_input_type == INPUT_TYPE_TOUCH then
                return true
            end
        end
    end
    return false


end

function _active_is_choosing_perso()
    return _is_choosing_perso()
end

function _is_a_menu()
    if _get_curr_menu() ~= nil then
        return true
    end
    return false
    
end

function _active_is_in_game()
    if _get_curr_menu() == nil then
        if _is_choosing_perso() then
            return false
        end
        return true
    end
    return false
end

function _is_a_cinematic()
    return false
end

function _active_is_not_a_cinematic()
    -- TODO
    return not _is_a_cinematic()
end

function _active_ok()
    if _is_choosing_perso() then
        return true
    end
    if _get_curr_menu() == nil then
        return false
    end

    if _is_a_cinematic() then
        return false
    end

    -- TODO: desactiver quand c'est dans le menu stat par exemple
    return true
end

function _active_back()
    if _is_choosing_perso() then
        return true
    end
    if _get_curr_menu() == nil then
        return false
    end

    if _is_a_cinematic() then
        return false
    end

    return _get_curr_menu().is_backable
end

function _active_vertical_ui()
    -- Tant que c'est un menu non cinématique
    if _get_curr_menu() == nil then
        return false
    end

    if _is_a_cinematic() then
        return false
    end

    return true
end

function _active_horizontal_ui()
    if _is_choosing_perso() then
        return true
    end

    -- Tant que c'est un menu non cinématique
    if _get_curr_menu() == nil then
        return false
    end
    if _is_a_cinematic() then
        return false
    end

    -- TODO: verifier si c'est un slider
    return false 
end



local buttons = {
    -- Always (except animation)
    { x=540, y=200, w=button_size, h=button_size, label="Esc",   key="t_escape",   active = _active_is_not_a_cinematic},

    { x=170, y=200, w=button_size, h=button_size, label="Jmp",   key="t_jump",     active = _active_is_in_game},
    { x=200, y=200, w=button_size, h=button_size, label="Sho",   key="t_shoot",    active = _active_is_in_game},
    { x=230, y=200, w=button_size, h=button_size, label="IntM",  key="t_interact", active = _active_is_in_game},

    { x=270, y=200, w=button_size, h=button_size, label="Ok",    key="t_ok",       active = _active_ok},
    { x=340, y=200, w=button_size, h=button_size, label="Back",  key="t_back",     active = _active_back},
    { x=340, y=200, w=button_size, h=button_size, label="Left",  key="t_left_ui",  active = _active_horizontal_ui},
    { x=340, y=200, w=button_size, h=button_size, label="Right", key="t_right_ui", active = _active_horizontal_ui},
    { x=340, y=200, w=button_size, h=button_size, label="Up",    key="t_up_ui",    active = _active_vertical_ui},
    { x=340, y=200, w=button_size, h=button_size, label="Down",  key="t_down_ui",  active = _active_vertical_ui},
}


-- FONCTIONS
function TouchScreen:init(cur_game)
	WINDOW_WIDTH, WINDOW_HEIGHT = love.graphics.getDimensions()
    joystick_pos.y = math.floor(WINDOW_HEIGHT * 4 / 5)
    joystick_pos.x = math.floor(WINDOW_WIDTH * 1 / 8)
    local i = 0
    for _, button in ipairs(buttons) do
        if button.key == "t_escape" then
            button.x = math.floor(WINDOW_WIDTH / 2 - button_size / 2)
            button.y = button_spacing
        else
            button.x = math.floor(WINDOW_WIDTH) - (button_size+2*button_spacing)*(i+1)
            button.y = WINDOW_HEIGHT - (button_size+button_spacing*8)
            i= i+1
        end
    end
    game = cur_game
    print("Menu : ", _get_curr_menu())
end


local function is_key_pressed(key)
    for id, loop_keys in pairs(presses) do
        for i, loop_key in ipairs(loop_keys) do
            if loop_key == key then
                return true
            end
        end
    end
    return false
end

local function is_joystick_pressed(key)
    if not joystick_id then return nil end
    for i, joystick_key in ipairs(joystick_key_pressed) do
        if joystick_key == key then
            return true
        end
    end
end

-- Donne les position par rapport a joytick_postion
function joystick_direction(new_x, new_y)
    dx = new_x - joystick_pos.x
    dy = new_y - joystick_pos.y

    -- Il faut qu'on return plusieurs direction genre par exemple en haut a droite
    -- On calcule la direction du joystick
    if dy == 0 and dx == 0 then return {} end

    angle = math.atan2(dy, dx)
    direction = {}
    -- 3. Détection des directions (Logique de tranches)
    -- Rappel : Droite = 0, Bas = pi/2, Gauche = pi, Haut = -pi/2
    
    -- Horizontal (Gauche ou Droite)
    if math.abs(angle) < (3/8 * math.pi) then
        table.insert(direction, "t_right")
    elseif math.abs(angle) > (5/8 * math.pi) then
        table.insert(direction, "t_left")
    end

    -- Vertical (Haut ou Bas)
    if angle > (1/8 * math.pi) and angle < (7/8 * math.pi) then
        table.insert(direction, "t_down")
    elseif angle < (-1/8 * math.pi) and angle > (-7/8 * math.pi) then
        table.insert(direction, "t_up")
    end

    return direction
--[[    
    if math.pi/6 <= angle and angle <= 5/6*math.pi then
        table.insert(direction, "t_up")
    end
    if abs(angle) >= 2/3*math.pi then
        table.insert(direction, "t_left")
    end
    if -math.pi/6 >= angle and angle >= -5/6*math.pi then
        table.insert(direction, "t_up")
    end
    if abs(angle) <= math.pi/3 then
        table.insert(direction, "t_left")
    end

    return direction
--]]
end

-- function is_game_paused()
--     if self.cur_menu == nil then
--         self:pause()
--     elseif self.is_paused then
--         self:unpause()
--     end
-- 
-- end

function TouchScreen:draw()
    local r, g, b, a = love.graphics.getColor()

    if not self.is_loaded() then
        return
    end

    -- btn
    for i, btn in ipairs(buttons) do
        if (not btn.active) or (btn.active and btn.active()) then
            if is_key_pressed(btn.key) then
                love.graphics.setColor(color_press)
            else
                love.graphics.setColor(color_bg)
            end

            love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.w, 10)
            
            love.graphics.setColor(color_text)

            local label = btn.label
            local font = love.graphics.getFont()
            local textW = font:getWidth(btn.label)
            local textH = font:getHeight(btn.label)
            love.graphics.print(btn.label, btn.x + (btn.w - textW)/2, btn.y + (btn.h - textH)/2)
        end
    end

    -- Joystick
    if joystick_id and joystick_pos.x and joystick_pos.y then
        love.graphics.setColor(color_bg)
        love.graphics.circle("fill", joystick_pos.x, joystick_pos.y, 5, 10)
        love.graphics.circle("line", joystick_pos.x, joystick_pos.y, joystick_radius, 100)
        if joystick_pos.dx and joystick_pos.dy then
            love.graphics.setColor(color_press)
            love.graphics.circle("fill", joystick_pos.x + joystick_pos.dx, joystick_pos.y + joystick_pos.dy, 20, 10)
        end
    end
    
    love.graphics.setColor(r, g, b, a)
end

local function isInside(x, y, btn)
    return x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h
end


local function appendToPresses(id, key)
    presses[id] = presses[id] or {}
    table.insert(presses[id], key)
end

local function removeFromPresses(id, key)
    -- 1. Si la table parente ou l'ID n'existent pas, on ne peut rien supprimer
    if not presses or not presses[id] then 
        return false 
    end

    local subTable = presses[id]
    local removed = false

    -- 2. On cherche l'élément dans la liste
    -- On parcourt à l'envers si on veut supprimer plusieurs occurrences, 
    -- mais ici on s'arrête à la première trouvée pour plus d'efficacité.
    for i, value in ipairs(presses[id]) do
        if value == key then
            table.remove(presses[id], i)
            removed = true
        end
    end

    -- 3. Si on n'a rien trouvé, on return false
    if not removed then 
        return false 
    end

    -- 4. Si la liste est devenue vide (# est l'opérateur de longueur), on supprime l'ID
    if #subTable == 0 then
        presses[id] = nil
    end

    return true
end

function is_position_on_left_screen(x)
    return x < math.floor(WINDOW_WIDTH/2.1)
end

function TouchScreen:touchpressed(id, x, y)
    global_screen_pressed = true

    if (is_position_on_left_screen(x) and not joystick_id) and (_active_is_in_game()) then
        -- Joystick
        joystick_id = id
        joystick_pos.x = x
        joystick_pos.y = y
        joystick_pos.dx = 0
        joystick_pos.dy = 0

        joystick_key_pressed = {}
    else
        -- Boutons
        for i, btn in ipairs(buttons) do
            if isInside(x, y, btn) and ((not btn.active) or (btn.active and btn.active())) then
                appendToPresses(id, btn.key)
            end
        end
    end
end

function TouchScreen:touchreleased(id, x, y)
    global_screen_pressed = false

    -- Joystick
    if id == joystick_id then
        joystick_id = nil
        -- joystick_pos = reset postition
    end

    -- Boutons
    for i, btn in ipairs(buttons) do
        removeFromPresses(id, btn.key)
    end
end

function TouchScreen:touchmoved(id, x, y, _, _, pressure)
    if not (is_position_on_left_screen(x) and joystick_id == id) then
        if not is_position_on_left_screen(x) then
            joystick_id = nil
        end
        return nil
    end
    -- print_debug(id, x,y,dy, dy)
    local dx = x - joystick_pos.x
    local dy = y - joystick_pos.y

    local distance_sq = dx * dx + dy * dy
    local radius_sq = joystick_radius * joystick_radius

    if distance_sq > radius_sq then 
        local distance = math.sqrt(distance_sq)
    
        joystick_pos.dx = (dx / distance) * joystick_radius
        joystick_pos.dy = (dy / distance) * joystick_radius
    else
        joystick_pos.dx = dx
        joystick_pos.dy = dy
    end
    
    joystick_key_pressed = joystick_direction(x,y)
end

function TouchScreen:is_touch_down(button)
    local touch = button.type .. "_" .. button.key_name
    return is_key_pressed(touch) or is_joystick_pressed(touch)
end

function TouchScreen:is_screen_pressed()
    screen_pressed = global_screen_pressed
    global_screen_pressed = false
    return screen_pressed
end

function TouchScreen:load()
    is_loaded = true
end

function TouchScreen:unload()
    if not self:is_loaded() then
        return nil
    end
    is_loaded = false
end

function TouchScreen:is_loaded()
    return is_loaded
end

return TouchScreen