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

    self.slides = {
        { frames = images.tv_slideshow_001, frame_duration = 0 },
        { frames = images.tv_slideshow_002, frame_duration = 0 },
        { frames = images.tv_slideshow_003, frame_duration = 0.04 }, --mio rotate
        { frames = images.tv_slideshow_004, frame_duration = 0 },
        { frames = images.tv_slideshow_005, frame_duration = 0 },
        { frames = images.tv_slideshow_006, frame_duration = 0.07 },
        { frames = images.tv_slideshow_007, frame_duration = 0.11 }, -- Starbugs green tea
        { frames = images.tv_slideshow_008, frame_duration = 0.1 },
        { frames = images.tv_slideshow_009, frame_duration = 0.3 },
        { frames = images.tv_slideshow_010, frame_duration = 0 },
        { frames = images.tv_slideshow_011, frame_duration = 0.035 },
        { frames = images.tv_slideshow_012, frame_duration = 0.03 },
        { frames = images.tv_slideshow_013, frame_duration = 0.03 },
        { frames = images.tv_slideshow_014, frame_duration = 0.08 },
        { frames = images.tv_slideshow_015, frame_duration = 0.3 },
        { frames = images.tv_slideshow_016, frame_duration = 0 },
        { frames = images.tv_slideshow_017, frame_duration = 0.08 },
        { frames = images.tv_slideshow_018, frame_duration = 0.04 }, -- Mio explode
        -- { frames = images.tv_slideshow_999, frame_duration = 0 }, -- UNCOMMENT if the website is ready
    }
    for i, slide in pairs(self.slides) do
        slide.frame_count = (slide.frames:getWidth() / self.canvas_w) * (slide.frames:getHeight() / self.canvas_h)
        slide.duration = slide.frame_count * slide.frame_duration
    end
    shuffle_table(self.slides, 1, #self.slides - 1)

    self.bluescreen_image = images.tv_bluescreen
    self.bluescreen_probability = TV_BLUESCREEN_PROBABILITY
    self.is_bluescreened = (random_range(0, 1) < self.bluescreen_probability)
    self.default_slide_duration = 5.0
    self.slideshow_timer = Timer:new(self.default_slide_duration):start()

    self.canvas = love.graphics.newCanvas(self.canvas_w, self.canvas_h)
    self.buffer_canvas = love.graphics.newCanvas(self.canvas_w, self.canvas_h)

    self.transitions = {
        { -- fade
            draw = function(trans, old_image, old_frame, new_image, new_frame, alpha)
                exec_color({ 1, 1, 1, 1 - alpha }, function() self:draw_frame(old_image, old_frame, 0, 0) end)
                exec_color({ 1, 1, 1, alpha }, function() self:draw_frame(new_image, new_frame, 0, 0) end)
            end,
        },
        { -- push vertical
            draw = function(trans, old_image, old_frame, new_image, new_frame, alpha)
                self:draw_frame(old_image, old_frame, 0, self.canvas_h * alpha)
                self:draw_frame(new_image, new_frame, 0, self.canvas_h * (alpha - 1))
            end,
        },
        { -- push horizontal
            draw = function(trans, old_image, old_frame, new_image, new_frame, alpha)
                self:draw_frame(old_image, old_frame, self.canvas_w * alpha, 0)
                self:draw_frame(new_image, new_frame, self.canvas_w * (alpha - 1), 0)
            end,
        },
        { -- cover
            draw = function(trans, old_image, old_frame, new_image, new_frame, alpha)
                self:draw_frame(old_image, old_frame, 0, 0)
                self:draw_frame(new_image, new_frame, self.canvas_w * (alpha - 1), 0)
            end,
        },
        { -- growing circle
            draw = function(trans, old_image, old_frame, new_image, new_frame, alpha)
                love.graphics.draw(old_image, -self.canvas_w * (old_frame - 1), 0)

                love.graphics.setStencilState("replace", "always", 1)
                love.graphics.circle("fill", self.canvas_w / 2, self.canvas_h / 2, alpha * self.canvas_w * 1.2)
                
                love.graphics.setStencilState("keep", "greater", 0)
                love.graphics.draw(new_image, -self.canvas_w * (new_frame - 1), 0)

                love.graphics.setStencilMode()
            end,
        },
        { -- bunch of growing circles
            draw = function(trans, old_image, old_frame, new_image, new_frame, alpha)
                love.graphics.draw(old_image, -self.canvas_w * (old_frame - 1), 0)

                love.graphics.setStencilState("replace", "always", 1)
                for ix = 0, self.canvas_w, 10 do
                    for iy = 0, self.canvas_h, 10 do
                        love.graphics.circle("fill", ix, iy, alpha * 15)
                    end
                end
                
                love.graphics.setStencilState("keep", "greater", 0)
                love.graphics.draw(new_image, -self.canvas_w * (new_frame - 1), 0)

                love.graphics.setStencilMode()
            end,
        },
        { -- "curtains" (idk how to call it)
            draw = function(trans, old_image, old_frame, new_image, new_frame, alpha)
                love.graphics.draw(old_image, -self.canvas_w * (old_frame - 1), 0)
                
                love.graphics.setStencilState("replace", "always", 1)
                love.graphics.rectangle("fill", 0, 0, self.canvas_w / 2 * alpha, self.canvas_h)
                love.graphics.rectangle("fill", self.canvas_w - self.canvas_w / 2 * alpha, 0, self.canvas_w, self.canvas_h)
                
                love.graphics.setStencilState("keep", "greater", 0)
                love.graphics.draw(new_image, -self.canvas_w * (new_frame - 1), 0)

                love.graphics.setStencilMode()
            end,
        },
    }
    self.current_transition = nil
    self.transition_t = 0.0
    self.transition_timer = Timer:new(0.5)

    self.current_slide_number = 1
    self.old_slide = self.slides[self.current_slide_number]
    self.current_slide = self.slides[self.current_slide_number]

    self.current_frame = 1
    self.old_frame = 1
    self.frame_timer = self.current_slide.frame_duration
end

function TvPresentation:update_slide(dt)
    if self.slideshow_timer:update(dt) then
        self:start_transition()
    end
end

function TvPresentation:start_transition()
    self.old_slide = self.current_slide

    self.current_slide_number = mod_plus_1(self.current_slide_number + 1, #self.slides)
    self.current_slide = self.slides[self.current_slide_number]

    local n = random_range_int(1, #self.transitions)
    self.current_transition = self.transitions[n]

    self.frame_timer = 0
    self.transition_timer:start()
    self.old_frame = self.current_frame
    self.current_frame = 1
end

function TvPresentation:update_frame(dt)
    self.frame_timer = self.frame_timer - dt
    if self.frame_timer < 0 then
        self.current_frame = mod_plus_1(self.current_frame + 1, self.current_slide.frame_count)
        self.frame_timer = self.frame_timer + self.current_slide.frame_duration
    end
end

function TvPresentation:update_transition(dt)
    self.transition_t = 1 - (self.transition_timer.time / self.transition_timer.duration)
    if self.current_transition and self.current_transition.update then
        self.current_transition:update(dt, self.transition_t)
    end

    if self.transition_timer:update(dt) then
        self:on_transition_end()
    end
end

function TvPresentation:on_transition_end()
    self.slideshow_timer:start(math.max(self.default_slide_duration, self.current_slide.duration))
    self.frame_timer = self.current_slide.frame_duration
    self.current_transition = nil
    self.current_frame = 1
end

function TvPresentation:update(dt)
    self:update_slide(dt)
    self:update_frame(dt)
    self:update_transition(dt)
end

local t = 0
function TvPresentation:draw_frame(spritesheet, frame, x, y)
    game.camera:reset_transform()

    local tile_count_x = (spritesheet:getWidth() / self.canvas_w)
    local frame_count = (spritesheet:getWidth() / self.canvas_w) * (spritesheet:getHeight() / self.canvas_h)
    local frame0 = (frame - 1)

    t = t + 1 / 60
    love.graphics.draw(spritesheet,
        love.graphics.newQuad(
            self.canvas_w * (frame0 % tile_count_x),
            self.canvas_h * math.floor(frame0 / tile_count_x),
            self.canvas_w, self.canvas_h, spritesheet:getDimensions()
        ), x, y
    )

    game.camera:apply_transform()
end

function TvPresentation:draw()
    if self.is_bluescreened then
        love.graphics.draw(self.bluescreen_image, self.x, self.y)
        return
    end

    exec_on_canvas({ self.canvas, stencil = true }, function()
        game.camera:reset_transform()
        love.graphics.clear()
        if self.current_transition then
            self.current_transition:draw(self.old_slide.frames, self.old_frame, self.current_slide.frames, 1,
                self.transition_t)
        else
            self:draw_frame(self.current_slide.frames, self.current_frame, 0, 0)
        end
        game.camera:apply_transform()
    end)

    love.graphics.draw(self.canvas, self.x, self.y)
end

return TvPresentation
