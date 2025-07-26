require "scripts.util"
local Class          = require "scripts.meta.class"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local images         = require "data.images"
local Timer          = require "scripts.timer"

local TvPresentation = Class:inherit()

function TvPresentation:init(x, y)
    self.x = x
    self.y = y
    
    self.canvas_w = 55
    self.canvas_h = 31

    self.default_slide_duration = 5.0

    local slides = {
        ["slide_001"] = { images.tv_slideshow_001, 0 },      -- Powerpoint stats         by Sslime7 
        ["slide_002"] = { images.tv_slideshow_002, 0 },      -- Hot dogs                 by Alexis Belmonte
        ["slide_003"] = { images.tv_slideshow_003, 0.04 },   -- Mio rotate               by Corentin Vaillant 
        ["slide_004"] = { images.tv_slideshow_004, 0 },      -- Bug with Guns            by Yolwoocle
        ["slide_005"] = { images.tv_slideshow_005, 0 },      -- "Love, obey"             by ellraiser
        ["slide_006"] = { images.tv_slideshow_006, 0.07 },   -- "Need your duck taped?"  by Joseph
        ["slide_007"] = { images.tv_slideshow_007, 0.11 },   -- Starbugs green tea       by Goyome
        ["slide_008"] = { images.tv_slideshow_008, 0.1 },    -- Binarion                 by hector_misc (Nextop Games)
        ["slide_009"] = { images.tv_slideshow_009, 0.3 },    -- "No quuen?"              by behck
        ["slide_010"] = { images.tv_slideshow_010, 0 },      -- "injured? good"          by hector_misc (Nextop Games) 
        ["slide_011"] = { images.tv_slideshow_011, 0.035 },  -- Splat commercial         by Sarcose
        ["slide_012"] = { images.tv_slideshow_012, 0.03 },   -- End toastal abuse        by clem 
        ["slide_013"] = { images.tv_slideshow_013, 0.03 },   -- A salt rifle             by clem 
        ["slide_014"] = { images.tv_slideshow_014, 0.08 },   -- Beatleblock              by Dimitri Sophinos (DPS2004)
        ["slide_015"] = { images.tv_slideshow_015, 0.3 },    -- bugscrapers arent enough by pkhead / chromosoze
        ["slide_016"] = { images.tv_slideshow_016, 0 },      -- optic studio             by pkhead / chromosoze
        ["slide_017"] = { images.tv_slideshow_017, 0.08 },   -- Soon(tm)                 by pixelbath
        ["slide_018"] = { images.tv_slideshow_018, 0.04 },   -- Mio explode              by Corentin Vaillant
        ["slide_019"] = { images.tv_slideshow_019, 0.04 },   -- Mio explode              by hector_misc (Nextop Games)

        ["bluescreen"] = { images.tv_bluescreen, math.huge } -- By hector_misc (Nextop Games)
    }
    self.slide_names = {}
    for name, slide_info in pairs(slides) do
        if name ~= "bluescreen" then
            table.insert(self.slide_names, name)
        end

        slides[name][3] = math.floor(slides[name][1]:getWidth() / self.canvas_w)
        slides[name][4] = math.floor(slides[name][1]:getHeight() / self.canvas_h)
    end
    shuffle_table(self.slide_names)

    
    self.bluescreen_probability = TV_BLUESCREEN_PROBABILITY
    self.is_bluescreened = (random_range(0, 1) < self.bluescreen_probability)
    if self.is_bluescreened then
        self.slide_names = {"bluescreen"}
    end

    self.transitions = {
        { -- fade
            draw = function(trans, old_slide, old_frame, new_image, new_frame, alpha)
                self:draw_frame(old_slide, old_frame, 0, 0, { 1, 1, 1, 1 - alpha })
                self:draw_frame(new_image, new_frame, 0, 0, { 1, 1, 1, alpha })
            end,
        },
        { -- push vertical
            draw = function(trans, old_slide, old_frame, new_image, new_frame, alpha)
                self:draw_frame(old_slide, old_frame, 0, self.canvas_h * alpha)
                self:draw_frame(new_image, new_frame, 0, self.canvas_h * (alpha - 1))
            end,
        },
        { -- push horizontal
            draw = function(trans, old_slide, old_frame, new_image, new_frame, alpha)
                self:draw_frame(old_slide, old_frame, self.canvas_w * alpha, 0)
                self:draw_frame(new_image, new_frame, self.canvas_w * (alpha - 1), 0)
            end,
        },
        { -- cover
            draw = function(trans, old_slide, old_frame, new_slide, new_frame, alpha)
                self:draw_frame(old_slide, old_frame, 0, 0)
                self:draw_frame(new_slide, new_frame, self.canvas_w * (alpha - 1), 0)
            end,
        },
        { -- growing circle
            draw = function(trans, old_slide, old_frame, new_slide, new_frame, alpha)
                love.graphics.setStencilMode()
                self:draw_frame(old_slide, old_frame, 0, 0)

                love.graphics.setStencilState("replace", "always", 1)
    			love.graphics.setColorMask(false)
                love.graphics.circle("fill", self.canvas_w / 2, self.canvas_h / 2, alpha * self.canvas_w * 1.2)
                
                love.graphics.setStencilState("keep", "greater", 0)
			    love.graphics.setColorMask(true)
                self:draw_frame(new_slide, new_frame, 0, 0)
                
                love.graphics.setStencilMode()
            end,
        },
        { -- bunch of growing circles
            draw = function(trans, old_slide, old_frame, new_slide, new_frame, alpha)
                self:draw_frame(old_slide, old_frame, 0, 0)

                love.graphics.setStencilState("replace", "always", 1)
                for ix = 0, self.canvas_w, 10 do
                    for iy = 0, self.canvas_h, 10 do
                        love.graphics.circle("fill", ix, iy, alpha * 15)
                    end
                end
                
                love.graphics.setStencilState("keep", "greater", 0)
                self:draw_frame(new_slide, new_frame, 0, 0)

                love.graphics.setStencilMode()
            end,
        },
        { -- "curtains" (idk how to call it)
            draw = function(trans, old_slide, old_frame, new_slide, new_frame, alpha)
                self:draw_frame(old_slide, old_frame, 0, 0)
                
                love.graphics.setStencilState("replace", "always", 1)
                love.graphics.rectangle("fill", 0, 0, self.canvas_w / 2 * alpha, self.canvas_h)
                love.graphics.rectangle("fill", self.canvas_w - self.canvas_w / 2 * alpha, 0, self.canvas_w, self.canvas_h)
                
                love.graphics.setStencilState("keep", "greater", 0)
                self:draw_frame(new_slide, new_frame, 0, 0)

                love.graphics.setStencilMode()
            end,
        },
    }
    self.current_transition = nil
    self.transition_t = 0.0
    self.transition_timer = Timer:new(0.5)
    
    self.slideshow_timer = Timer:new(self.default_slide_duration):start()
    
    self.canvas = love.graphics.newCanvas(self.canvas_w, self.canvas_h)
    self.buffer_canvas = love.graphics.newCanvas(self.canvas_w, self.canvas_h)
    
    self.current_slide_number = random_range_int(1, #self.slide_names)
    self.old_slide_frame_i = random_range_int(1, #self.slide_names)
    self.old_slide = self.slide_names[self.current_slide_number]
    self.current_slide = self.slide_names[self.current_slide_number]

    self.spr = AnimatedSprite:new(slides, self.current_slide, SPRITE_ANCHOR_LEFT_TOP)
end

function TvPresentation:update(dt)
    if self.is_bluescreened then
        self.spr:update(dt)
        return
    end

    -- Slide end
    if self.slideshow_timer:update(dt) then
        self.transition_timer:start()
        self.current_transition = random_sample(self.transitions)

        self.old_slide = self.current_slide
        self.old_slide_frame_i = self.spr.frame_i
        self:set_current_slide(mod_plus_1(self.current_slide_number + 1, #self.slide_names))
    end

    -- Transition end
    if self.transition_timer:update(dt) then
        self.slideshow_timer:start(math.max(self.default_slide_duration, self.spr.animations[self.current_slide].duration - 1/60))
        self.current_transition = nil
    end
    
    self.spr:update(dt)
end


function TvPresentation:set_current_slide(slide_index)
    self.current_slide_number = slide_index
    self.current_slide = self.slide_names[self.current_slide_number]
end


function TvPresentation:draw_frame(slide, frame, x, y, color)
    color = color or COL_WHITE
    self.spr:set_color(color)
    self.spr:set_animation(slide)
    self.spr:set_frame_index(frame)
    self.spr:draw(x, y)
    self.spr:set_color(COL_WHITE)
end

function TvPresentation:draw()
    exec_on_canvas({ self.canvas, stencil = true }, function()
        game.camera:push_origin()
        
        love.graphics.clear()
        if self.current_transition then
            self.current_transition:draw(self.old_slide, self.old_slide_frame_i, self.current_slide, 1,
            1 - (self.transition_timer.time / self.transition_timer.duration))
        else
            self.spr:draw(0, 0)
        end

        game.camera:pop()
    end)

    love.graphics.draw(self.canvas, self.x, self.y)
end

return TvPresentation
