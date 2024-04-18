local Class = require "scripts.meta.class"
local Background = require "scripts.level.background.background"

local BackgroundDots = Background:inherit()

function BackgroundDots:init(level)
	self:init_background(level)

	self.speed = 0
	self.def_speed = 10 --TODO

	self.bg_color_progress = 0
	self.bg_color_index = 1
	
	self.show_bg_particles = true
	self.def_bg_col = COL_BLACK_BLUE
	self.clear_color = self.def_bg_col

	self.bg_particles = {}	
	self.bg_particle_col = {COL_VERY_DARK_GRAY, COL_DARK_GRAY}
	self.bg_colors = {
		COL_BLACK_BLUE,
		COL_DARK_GREEN,
		COL_DARK_RED,
		COL_LIGHT_BLUE,
		COL_WHITE,
		color(0xb55088), -- purple
		COL_BLACK_BLUE,
		color(0xfee761), -- lyellow
		color(0x743f39), -- mid brown
		color(0xe8b796) --beige
	}
	self.bg_particle_colors = {
		{COL_VERY_DARK_GRAY, COL_DARK_GRAY},
		{COL_MID_DARK_GREEN, color(0x3e8948)},
		{COL_LIGHT_RED, color(0xf6757a)}, --l red + light pink
		{COL_MID_BLUE, COL_WHITE},
		{color(0xc0cbdc), color(0x8b9bb4)}, --gray & dgray
		{color(0x68386c), color(0x9e2835)}, --dpurple & dred
		{COL_LIGHT_RED, COL_ORANGE, COL_LIGHT_YELLOW, color(0x63c74d), COL_LIGHT_BLUE, color(0xb55088)}, --rainbow
		{color(0xfeae34), COL_WHITE}, --orange & white
		{color(0x3f2832), COL_BLACK_BLUE}, --orange & white
		{color(0xe4a672), color(0xb86f50)} --midbeige & dbeige (~brown ish)
	}
	for i=1,60 do
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
	if not self.level.is_on_win_screen then
		self.bg_color_progress = self.bg_color_progress + dt*0.2
		local i_prev = mod_plus_1(self.bg_color_index-1, #self.bg_colors)
		if self.level.floor <= 1 then
			i_prev = 1
		end

		local i_target = mod_plus_1(self.bg_color_index, #self.bg_colors)
		local prog = clamp(self.bg_color_progress, 0, 1)
		self.clear_color = lerp_color(self.bg_colors[i_prev], self.bg_colors[i_target], prog)
		self.bg_particle_col = self.bg_particle_colors[i_target]
	end

	self:update_bg_particles(dt)
end

function BackgroundDots:set_speed(val)
	self.speed = val
end

function BackgroundDots:change_bg_color(wave_n)
	-- if wave_n == floor((self.bg_color_index) * (#waves / 4)) then
	local real_wave_n = max(1, self.level.floor + 1)
	if wave_n % 4 == 0 then
		-- self.bg_color_index = self.bg_color_index + 1
		self.bg_color_index = mod_plus_1( floor(real_wave_n / 4) + 1, #self.bg_colors)
		self.bg_color_progress = 0
	end
end

function BackgroundDots:new_bg_particle()
	local o = {}
	o.x = love.math.random(0, CANVAS_WIDTH)
	o.w = love.math.random(2, 12)
	o.h = love.math.random(8, 64)
	
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
	for i,o in pairs(self.bg_particles) do
		o.y = o.y + dt*self.speed*o.spd
		
		local del_cond = (self.speed>=0 and o.y > CANVAS_HEIGHT) or (self.speed<0 and o.y < -CANVAS_HEIGHT) 
		if del_cond then
			local p = self:new_bg_particle()
			-- o = p
			-- ^^^^^ WHY DOES THIS NOT. WORK. I'm going crazy
			o.x = p.x
			o.y = p.y
			o.w = p.w
			o.h = p.h
			o.col = p.col
			o.spd = p.spd
			o.oy = p.oy
			o.oh = p.oh
			o.rnd_pi = p.rnd_pi
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
	-- if not self.show_bg_particles then
	-- 	return 
	-- end

	for i,o in pairs(self.bg_particles) do
		local y = o.y + o.oy
		local mult = 1 - clamp(abs(self.speed / 100), 0, 1)
		local sin_oy = mult * sin(game.t + o.rnd_pi) * o.oh * o.h 
		
		rect_color(o.col, "fill", o.x, o.y + o.oy + sin_oy, o.w, o.h * o.oh)
	end
end

return BackgroundDots