require "scripts.util"
local Class = require "scripts.meta.class"

local TouchScreen = Class:inherit()

local color_bg = {0.2, 0.2, 0.2, 1} -- Fond du bouton
local color_text = {1, 1, 1, 1}                    -- Couleur du texte
local color_press = {0.4, 0.4, 0.4, 1} -- Couleur quand on appuie

local buttons = {
    { x=50,  y=200, w=30, h=30, label="Q",   key="t_left" },
    { x=80,  y=200, w=30, h=30, label="D",   key="t_right" },
    { x=110, y=200, w=30, h=30, label="Z",   key="t_up" },
    { x=140, y=200, w=30, h=30, label="S",   key="t_down" },
    { x=170, y=200, w=30, h=30, label="Jmp",   key="t_jump" },
    { x=200, y=200, w=30, h=30, label="Sho",   key="t_shoot" },
    { x=230, y=200, w=30, h=30, label="Int",   key="t_interact" },
    { x=540, y=200, w=30, h=30, label="Esc", key="t_escape" },
    -- Ajoute tes touches ici (A, Z, E, Espace, etc.)
}

local presses = {} -- Stocke les touches actuellement appuyées
local global_screen_pressed_to_join = false
local is_touch_screen_loaded = false

function TouchScreen:init(isActive)
    -- not used now
    self.isActive = isActive
end

function TouchScreen:draw()
    if is_touch_screen_loaded == false then return nil end
    local r, g, b, a = love.graphics.getColor()

    for i, btn in ipairs(buttons) do
        -- Change la couleur si pressé
        if presses[btn.key] then
            love.graphics.setColor(color_press)
        else
            love.graphics.setColor(color_bg)
        end
        
        -- Dessine le fond (Rectangle arrondi)
        love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.w, 10)
        
        -- Dessine le texte (label)
        love.graphics.setColor(color_text)
        local font = love.graphics.getFont()
        local textW = font:getWidth(btn.label)
        local textH = font:getHeight(btn.label)
        love.graphics.print(btn.label, btn.x + (btn.w - textW)/2, btn.y + (btn.h - textH)/2)
    end
    
    -- Restauration de la couleur
    love.graphics.setColor(r, g, b, a)
end

local function isInside(x, y, btn)
    return x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h
end

function TouchScreen:touchpressed(id, x, y)
    global_screen_pressed_to_join = true
    for i, btn in ipairs(buttons) do
        if isInside(x, y, btn) then
            presses[btn.key] = id 
            print_debug("pressed", btn.key, id, x, y)
            break -- On ne peut cliquer qu'un bouton à la fois par ID de touche
        end
    end
end

function TouchScreen:touchreleased(id, x, y)
    global_screen_pressed_to_join = false

    -- On libère tout ce qui est pressé pour cet ID
    for i, btn in ipairs(buttons) do
        if presses[btn.key] and presses[btn.key] == id then
            print_debug("relesed", btn.key, id, x, y)
            presses[btn.key] = nil
        end
    end
end

function TouchScreen:is_touch_down(button)
    return presses[button.type .. "_" .. button.key_name]
end

function TouchScreen:is_screen_pressed()
    if is_touch_screen_loaded then return nil end 
    return global_screen_pressed_to_join
end

function TouchScreen:is_now_loaded()
    is_touch_screen_loaded = true
end

return TouchScreen


-- local overlay = {}
-- 
-- -- === CONFIGURATION ===
-- overlay.visible = true
-- overlay.opacity = 0.6 -- Transparence (0 à 1)
-- 
-- -- Couleurs (RGBA)
-- local color_bg = {0.2, 0.2, 0.2, overlay.opacity} -- Fond du bouton
-- local color_text = {1, 1, 1, 1}                    -- Couleur du texte
-- local color_press = {0.4, 0.4, 0.4, overlay.opacity} -- Couleur quand on appuie
-- 
-- -- === DÉFINITION DES BOUTONS ===
-- -- Tu dois définir les zones tactiles ici.
-- -- x, y sont en coordonnes ÉCRAN, w, h sont largeur/hauteur.
-- -- key est la touche LÖVE que le bouton simule.
-- 
-- -- === VARIABLES INTERNES ===
-- local presses = {} -- Stocke les touches actuellement appuyées
-- 
-- -- === FONCTIONS PRIVÉES ===
-- local function isInside(x, y, btn)
--     return x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h
-- end
-- 
-- -- === FONCTIONS PUBLIQUES ===
-- 
-- function overlay.load()
--     -- On s'assure que le mode texte est bien coupé !
--     love.keyboard.setTextInput(false)
-- end
-- 
-- function overlay.draw()
--     if not overlay.visible then return end
-- 
--     -- Sauvegarde de la couleur précédente
--     local r, g, b, a = love.graphics.getColor()
--     
--     for i, btn in ipairs(buttons) do
--         -- Change la couleur si pressé
--         if presses[btn.key] then
--             love.graphics.setColor(color_press)
--         else
--             love.graphics.setColor(color_bg)
--         end
--         
--         -- Dessine le fond (Rectangle arrondi)
--         love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.w, 10)
--         
--         -- Dessine le texte (label)
--         love.graphics.setColor(color_text)
--         local font = love.graphics.getFont()
--         local textW = font:getWidth(btn.label)
--         local textH = font:getHeight(btn.label)
--         love.graphics.print(btn.label, btn.x + (btn.w - textW)/2, btn.y + (btn.h - textH)/2)
--     end
--     
--     -- Restauration de la couleur
--     love.graphics.setColor(r, g, b, a)
-- end
-- 
-- -- --- Gestion du Tactile / Souris ---
-- 
-- return overlay