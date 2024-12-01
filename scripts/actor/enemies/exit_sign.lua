require "scripts.util"
local images = require "data.images"
local ButtonSmall = require "scripts.actor.enemies.button_small"

local utf8 = require "utf8"

local ExitSign = ButtonSmall:inherit()

function ExitSign:init(x, y)
    ExitSign.super.init(self, x, y, nil, 30, 12)
    self.name = "roizoiezrjaorzezrenaciozcrorzcuorcaorczpuaporcua"

    self:set_image(images.machine_coffee)
    self.sprite_pressed = images.small_button_pressed

    self.stomp_height = 12
    self.disappear_after_press = false
    
    self.spring_active = false
    self.spring_stiffness = 3.0
    self.spring_friction = 0.94
    self.default_spring_ideal_length = 2
    self.retracted_spring_ideal_length = 40

    self.spring_vy = 0.0
    self.spring_y = self.default_spring_ideal_length
    self.spring_ideal_length = 0
    self.spring_retract_timer = 0.0

    self.is_in_smash_easter_egg = false
    self.smash_stars = {}
    self.old_camera_x, self.old_camera_y = 0, 0
    self.smash_x, self.smash_y = 0, 0
    self.pan_camera_to_default = false
    self.smash_unzoom_timer = 0.0

    self.loot = {}
end

function ExitSign:update(dt)
    self.spring_vy = self.spring_vy + (self.spring_ideal_length - self.spring_y) * self.spring_stiffness
    self.spring_vy = self.spring_vy * self.spring_friction
    self.spring_y = self.spring_y + self.spring_vy * dt
    
    if self.spring_retract_timer > 0 then
        self.spring_retract_timer = max(0.0, self.spring_retract_timer - dt)
    else
        self.spring_ideal_length = self.default_spring_ideal_length
        self.spring_active = false
        self:set_pressed(false)
    end

    self:update_smash_easter_egg(dt)

    ExitSign.super.update(self, dt)
end

function ExitSign:on_press(presser)
    if not presser.is_player then
        return
    end
    local player = presser

    if random_range(0, 1) < SMASH_EASTER_EGG_PROBABILITY then
        self:activate_smash_easter_egg(player)
    else
        game:leave_game(player.n)
        game:screenshake(4)
        Particles:ejected_player(player.skin.spr_dead, player.x, player.y)
        Audio:play("exit_sign_activate")
        
        self.spring_active = true
        self.spring_retract_timer = 2.0
        self.spring_ideal_length = self.retracted_spring_ideal_length
    end
end

function ExitSign:draw()
    self.spr:set_image(images.exit_sign)
    self:draw_enemy()

    if self.is_in_smash_easter_egg then
        self:draw_smash_easter_egg()
    end
    
    print_centered_outline(COL_LIGHT_GREEN, COL_BLACK_BLUE, Text:text("input.prompts.leave_game"), self.mid_x, self.y - 38)

    local final_spring_y = math.floor(self.y + self.h + 5 - self.spring_y)
    local max_spring_y = math.floor(self.y + self.h + 6) -- Value to clamp the y value to (to prevent intersection w/ floor)
    local spring_height = images.spring:getHeight()

    for iy = final_spring_y, max_spring_y - spring_height, spring_height do
        love.graphics.draw(images.spring, math.floor(self.mid_x - images.spring:getWidth()/2), iy)
    end
    if final_spring_y < max_spring_y then
        draw_centered(images.punching_glove, self.mid_x, final_spring_y)
    end

    self.spr:set_image(images.exit_sign_front)

    ExitSign.super.draw(self)
end

------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------


function ExitSign:draw_smash_easter_egg()
    local colors = {
        COL_BLACK_BLUE,
        COL_LIGHT_RED,
        COL_LIGHT_YELLOW,
        COL_LIGHT_RED,
        COL_BLACK_BLUE,
    }

    for i = 1, #self.smash_stars do
        local triangles = love.math.triangulate(self.smash_stars[i])
        local old_col = {love.graphics.getColor()}
        love.graphics.setColor(colors[i])
        for _, tri in pairs(triangles) do
            love.graphics.polygon("fill", tri)
        end
        love.graphics.setColor(old_col)
    end
    -- self:draw_star(self.mid_x, self.y)
end

function ExitSign:activate_smash_easter_egg(player)
    self.is_in_smash_easter_egg = true
    
    local impact_x = self.mid_x
    local impact_y = self.y + self.h - self.retracted_spring_ideal_length - 8
    self.smash_x, self.smash_y = impact_x, impact_y

    self.old_camera_x, self.old_camera_y = game:get_camera_position()
    self.smash_unzoom_timer = 0.9
    game:set_zoom(2)
    game:set_ui_visible(false)
    game.menu_manager:set_can_pause(false)
    game.camera:set_y_locked(false)

    self:update_star()

    game:leave_game(player.n)
    game:screenshake(14)
    Particles:smashed_player(player.skin.spr_dead, impact_x, impact_y)
    Audio:play("smash_easter_egg")
    
    self.spring_active = true
    self.spring_retract_timer = 2.0
    self.spring_ideal_length = self.retracted_spring_ideal_length
end

function ExitSign:update_star()
    self.smash_stars[1] = self:generate_star_points(self.smash_x, self.smash_y, 5)
    self.smash_stars[2] = self:generate_star_points(self.smash_x, self.smash_y, 4)
    self.smash_stars[3] = self:generate_star_points(self.smash_x, self.smash_y, 3)
    self.smash_stars[4] = self:generate_star_points(self.smash_x, self.smash_y, 2)
    self.smash_stars[5] = self:generate_star_points(self.smash_x, self.smash_y, 1)
end

function ExitSign:lerp_camera(x, y)
    local camx, camy = game:get_camera_position()
    camx = lerp(camx, x,  0.2)
    camy = lerp(camy, y, 0.2)
    game:set_camera_position(camx, camy)
end

function ExitSign:lerp_zoom(dest)
    local z = game:get_zoom()
    z = lerp(z, dest, 0.2)
    game:set_zoom(z)
end

function ExitSign:update_smash_easter_egg(dt) 
    self.smash_unzoom_timer = math.max(0, self.smash_unzoom_timer - dt)

    if self.is_in_smash_easter_egg then
        self.spring_y = self.retracted_spring_ideal_length
        self:lerp_camera(self.smash_x - CANVAS_WIDTH/4, self.smash_y - CANVAS_HEIGHT/4 + 128)
        
        self:update_star()

        for _, star in pairs(self.smash_stars) do
            for i = 1, #star-1, 2 do
                -- print_ debug(i_star, i, self.smash_stars[i_star][i], self.smash_stars[i_star][i] +1)
                -- star[i]   = star[i]   + random_neighbor(20) * dt
                -- star[i+1] = star[i+1] + random_neighbor(20) * dt
            end
        end
    end

    if self.smash_unzoom_timer <= 0 then 
        self:update_smash_effect_end(dt)
    end 
end

function ExitSign:update_smash_effect_end(dt)
    if self.is_in_smash_easter_egg then
        self.pan_camera_to_default = true
        self.is_in_smash_easter_egg = false

        game:set_ui_visible(true)
    end
    
    if self.pan_camera_to_default then
        self.old_camera_x, self.old_camera_y = 0,48
        self:lerp_camera(self.old_camera_x, self.old_camera_y)
        self:lerp_zoom(1)

        -- End smash effect
        if distsqr(0, 48, game:get_camera_position()) <= 0.1 then
            self.pan_camera_to_default = false
            game.camera:reset()
        	game:set_camera_position(0, 48)
            game:set_zoom(1)
            game.camera:set_y_locked(true)
            
            game.menu_manager:set_can_pause(true)
        end
    end
end

function ExitSign:generate_star_points(x, y, size)
    local points = {}
    local n = 5
    local big_r = 30
    local small_r = 10

    local function add_point(angle, rad)
        local px = x + math.cos(-angle) * rad * size
        local py = y + math.sin(-angle) * rad * size
        table.insert(points, px)
        table.insert(points, py)
    end

    local a = 0
    local r = small_r
    while a <= pi2 do
        add_point(a, random_range(r, r+10))
        
        a = a + random_range(0, 1/n)
        r = ternary(r == big_r, small_r, big_r)
    end

    return points
end



return ExitSign
