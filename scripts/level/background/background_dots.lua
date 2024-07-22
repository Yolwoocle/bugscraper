local Class = require "scripts.meta.class"
local Background = require "scripts.level.background.background"
local images     = require "data.images"

local BackgroundDots = Background:inherit()

function BackgroundDots:init(level)
	self:init_background(level)

	self.speed = 0
	self.def_speed = 10 --TODO

	self.bg_color_index = 1
	self.number_of_particles = 60
	
	self.show_bg_particles = true
	self.def_bg_col = COL_BLACK_BLUE
	self.clear_color = self.def_bg_col

	self.bg_particles = {}	
	self.bg_particle_col = {COL_VERY_DARK_GRAY, COL_DARK_GRAY}
	self.bg_particle_palettes = {
		{COL_BLACK_BLUE,  {COL_VERY_DARK_GRAY, COL_DARK_GRAY}},
		{COL_DARK_GREEN,  {COL_MID_DARK_GREEN, COL_MID_GREEN}},
		{COL_DARK_RED,    {COL_LIGHT_RED, COL_PINK}}, --l red + light pink
		{COL_LIGHT_BLUE,  {COL_MID_BLUE, COL_WHITE}},
		{COL_WHITE,       {color(0xc0cbdc), color(0x8b9bb4)}}, --gray & dgray
		{color(0xb55088), {color(0x68386c), color(0x9e2835)}}, --dpurple & dred
		{COL_BLACK_BLUE,  {COL_LIGHT_RED, COL_ORANGE, COL_LIGHT_YELLOW, color(0x63c74d), COL_LIGHT_BLUE, color(0xb55088)}}, --rainbow
		{color(0xfee761), {color(0xfeae34), COL_WHITE}}, --orange & white
		{color(0x743f39), {color(0x3f2832), COL_BLACK_BLUE}}, --orange & white
		{color(0xe8b796), {color(0xe4a672), color(0xb86f50)}} --midbeige & dbeige (~brown ish)
	}
	self.target_bg_palette = self.bg_particle_palettes[1]
	self.target_clear_color = self.target_bg_palette[1]
	self.bg_particle_col = self.target_bg_palette[2]

	self.bg_particles = {}	
	self:init_bg_particles()
end

function BackgroundDots:init_bg_particles()
	self.bg_particles = {}	
	for i=1,self.number_of_particles do
		local p = self:new_bg_particle()
		p.x = random_range(0, CANVAS_WIDTH)
		p.y = random_range(0, CANVAS_HEIGHT)
		table.insert(self.bg_particles, p)
	end
end
-----------------------------------------------------

function BackgroundDots:update(dt)
	self:update_background(dt)

	-- BG color gradient
	-- self.clear_color = move_toward_color(self.clear_color, self.target_clear_color, 0.06*dt)
	self.clear_color = lerp_color(self.clear_color, self.target_clear_color, 0.006)

	self:update_bg_particles(dt)
end

function BackgroundDots:set_speed(val)
	self.speed = val
end

function BackgroundDots:change_clear_color(force_palette)
	if force_palette then
		self.target_bg_palette = force_palette
		self.target_clear_color = force_palette[1]
		self.bg_particle_col =    force_palette[2]
	else
		local wave_n = max(1, self.level.floor + 1)
		if wave_n % 4 == 0 then
			self.bg_color_index = mod_plus_1( floor(wave_n / 4) + 1, #self.bg_particle_palettes)
			self.target_bg_palette = self.bg_particle_palettes[self.bg_color_index]
			self.target_clear_color = self.target_bg_palette[1]
			self.bg_particle_col = self.target_bg_palette[2]
		end
	end
	self.bg_color_progress = 0

end

function BackgroundDots:set_clear_color(palette)
	self.target_bg_palette = palette
	self.target_clear_color = palette[1]
	self.clear_color = palette[1]
	self.bg_particle_col = palette[2]

	self.bg_color_progress = 0

end

function BackgroundDots:new_bg_particle()
	local o = {}
	if false and random_range(0, 1) < 0.05 then --removeme remove "false and"
		o.type = "image"
		o.img = images["_test_bg_image_"..tostring(random_range_int(1, 2))]
		
		o.w = o.img:getWidth()
		o.h = o.img:getHeight()
	else
		o.type = "rect"

		o.w = love.math.random(2, 12)
		o.h = love.math.random(8, 64)
	end
	o.x = love.math.random(-o.w, CANVAS_WIDTH)
	
	if self.speed >= 0 then
		o.y = -o.h - love.math.random(0, CANVAS_HEIGHT)
	else
		o.y = CANVAS_HEIGHT + o.h + love.math.random(0, CANVAS_HEIGHT)
	end

	o.col = random_sample{COL_VERY_DARK_GRAY, COL_DARK_GRAY}
	if self.bg_particle_col then
		o.col = random_sample(self.bg_particle_col)
	end
	o.spd = random_range(0.5, 1.5)

	o.oy = 0
	o.oh = 1

	o.t = 0
	o.rnd_pi = random_neighbor(math.pi)
	return o
end

function BackgroundDots:update_bg_particles(dt)
	-- Background lines
	for i=1, #self.bg_particles do
		local o = self.bg_particles[i]
		o.y = o.y + dt*self.speed*o.spd
		
		local del_cond = (self.speed>=0 and o.y > CANVAS_HEIGHT + o.h) or (self.speed<0 and o.y - o.h < -CANVAS_HEIGHT) 
		if del_cond then
			local p = self:new_bg_particle()
			self.bg_particles[i] = p
		end

		-- Size corresponds to elevator speed
		o.oh = max(o.w/o.h, abs(self.speed) / self.def_speed)
		o.oy = .5 * o.h * o.oh
	end
end

function BackgroundDots:shift_to_red(speed_cap)
	local p = self.speed / speed_cap
	self.clear_color = lerp_color(self.bg_colors[#self.bg_colors], color(0xff7722), p)
	-- self.bg_particle_col = self.bg_particle_colors[#self.bg_particle_colors]
	local r = self.clear_color[1]
	local g = self.clear_color[2]
	local b = self.clear_color[3]
	self.bg_particle_col = { {r+0.1, g+0.1, b+0.1, 1},{r+0.2, g+0.2, b+0.2, 1} }
end

function BackgroundDots:on_exploding_elevator()
	self.clear_color = COL_BLACK_BLUE
	self.bg_particle_col = nil--{ {r+0.1, g+0.1, b+0.1, 1},{r+0.2, g+0.2, b+0.2, 1} }

	for _,p in pairs(self.bg_particles) do
		p.col = random_sample{COL_VERY_DARK_GRAY, COL_DARK_GRAY}
	end
end

-----------------------------------------------------

function BackgroundDots:draw()
	self:draw_background()

	for i,o in pairs(self.bg_particles) do
		self:draw_particle(o)
	end
end

function BackgroundDots:draw_particle(o)
	if o.type == "rect" then
		local y = o.y + o.oy
		local mult = 1 - clamp(abs(self.speed / 100), 0, 1)
		local sin_oy = mult * sin(game.t + o.rnd_pi) * o.oh * o.h 
		
		rect_color(o.col, "fill", o.x, o.y + o.oy + sin_oy, o.w, o.h * o.oh)
	elseif o.type == "image" then
		draw_centered(o.img, o.x, o.y)
	end
end

return BackgroundDots