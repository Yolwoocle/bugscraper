local utf8 = require "utf8"
require "scripts.constants"
local shaders = require "scripts.shaders"

abs = math.abs
exp = math.exp
max = math.max
min = math.min
floor = math.floor
ceil = math.ceil
cos = math.cos
sin = math.sin
tan = math.tan
atan2 = math.atan2
sqrt = math.sqrt

gfx = love.graphics

pi = math.pi
pi2 = 2*math.pi
inf = math.huge

function mod_plus_1(val, mod)
	-- i hate lua
	return ((val-1) % mod)+1
end

function normalize_vect(x, y)
	if x==0 and y==0 then  return 1,0  end
	local d = sqrt(x*x + y*y)
	return x/d, y/d
	-- local a = math.atan2(y, x)
	-- return math.cos(a), math.sin(a)
end
normalise_vect = normalize_vect

function color(hex)
	if not hex then  return white  end
	if type(hex) ~= "number" then  return white  end

	local b = hex % 256;  hex = (hex - b) / 256
	local g = hex % 256;  hex = (hex - b) / 256
	local r = hex % 256
	return {r/255, g/255, b/255}
end

function round(num, num_dec)
	-- http://lua-users.org/wiki/SimpleRound
	local mult = 10^(num_dec or 0)
	return math.floor(num * mult + 0.5) / mult
end


function round_if_near_zero(val, thr)
	thr = thr or 0.1
	if math.abs(val) < thr then
		return 0
	end
	return thr
end

-- function copy_table(tab)
-- 	local newtab = {}
-- 	for k,v in pairs(tab) do
-- 		newtab[k] = v
-- 	end
-- 	return newtab
-- end

function copy_table(orig)
	-- http://lua-users.org/wiki/CopyTable
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[copy_table(orig_key)] = copy_table(orig_value)
        end
        setmetatable(copy, copy_table(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function duplicate_table(tab, n)
	local ntab = {}
	-- assert(type(n) == "number", "duplicate_table argument 'n' must be a number, not "..type(n))

	for i=1, n do
		table.insert(ntab, tab)
	end
	return ntab
end	

function is_in_table(tab, val)
	for _,v in pairs(tab) do
		if val == v then
			return true
		end
	end
	return false
end

function append_table(tab1,tab2)
	for i,v in pairs(tab2) do
		table.insert(tab1,v)
	end
	return tab1
end

function table.clone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function shuffle_table(t, rng)
	--Fisher–Yates shuffle: https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
	for i=#t, 1, -1 do
		local j 
		if rng then
			j = rng:random(i)
		else
			j = love.math.random(i)
		end
		t[j], t[i] = t[i], t[j]
	end
end


function is_between(v, a, b)
	return a <= v and v <= b
end

function lighten_color(col, v)
	local ncol = {}
	for i,ch in pairs(col) do
		table.insert(ncol, ch+v)
	end
	return ncol
end

function rgb(r,g,b)
	return {r/255, g/255, b/255, 1}
end

function ternary(cond, t, f)
	if cond then return t end
	return f
end

-- function draw_centered(spr, x, y, r, sx, sy, ox, oy, color)
-- 	local w = spr:getWidth() or 0
-- 	local h = spr:getHeight() or 0
-- 	local col = color or {1,1,1}
-- 	if spr == nil then spr = spr_missing end 

-- 	if (camera.x-w < x) and (x < camera.x+window_w+w) 
-- 	and (camera.y-h < y) and (y < camera.y+window_h+h) then
-- 		x = floor(x)
-- 		y = floor(y)
-- 		r = r or 0
-- 		sx = sx or PIXEL_SCALE
-- 		sy = sy or sx
-- 		ox = ox or 0
-- 		oy = oy or 0

-- 		ox = floor(ox + spr:getWidth()/2)
-- 		oy = floor(oy + spr:getHeight()/2)
-- 		love.graphics.setColor(col)
-- 		love.graphics.draw(spr, x, y, r, sx, sy, ox, oy)
-- 		love.graphics.setColor(1,1,1)
-- 	end
-- end

function rect_color_centered(col, mode, x, y, w, h)
	rect_color(col, mode, x - w/2, y - h/2, w, h)
end

function draw_with_selected_outline(spr, x, y, r, sx, sy)
	love.graphics.setShader(shaders.draw_in_highlight_color)
	local offset = 1

	love.graphics.draw(spr, x, y, r, sx, sy, offset , 0)
	love.graphics.draw(spr, x, y, r, sx, sy, -offset, 0)
	love.graphics.draw(spr, x, y, r, sx, sy, 0,       offset)
	love.graphics.draw(spr, x, y, r, sx, sy, 0,      -offset)

	love.graphics.draw(spr, x, y, r, sx, sy, offset , offset)
	love.graphics.draw(spr, x, y, r, sx, sy,-offset , offset)
	love.graphics.draw(spr, x, y, r, sx, sy, offset ,-offset)
	love.graphics.draw(spr, x, y, r, sx, sy,-offset ,-offset)
	
	love.graphics.setShader()
	love.graphics.draw(spr, x, y, r, sx, sy)

end

function draw_centered_text(text, rect_x, rect_y, rect_w, rect_h, rot, sx, sy, font)
	rot = rot or 0
	sx = sx or 1
	sy = sy or sx
	local deffont = love.graphics.getFont()
	local font   = font or love.graphics.getFont()
	local text_w = font:getWidth(text)
	local text_h = font:getHeight(text)
	local x = math.floor(rect_x+rect_w/2)
	local y = math.floor(rect_y+rect_h/2)

	love.graphics.setFont(font)
	love.graphics.print(text, x, y, rot, sx, sy, math.floor(text_w/2), math.floor(text_h/2))
	love.graphics.setFont(deffont)
end

function draw_stretched_spr(x1,y1,x2,y2,spr,scale)
	-- Draws a sprite from (x1, y1) to (x2, y2)
	xmidd = x2-x1
	ymidd = y2-y1
	local rota = math.atan2(ymidd,xmidd)
	local dist = dist(x1,y1,x2,y2)
	love.graphics.draw(spr, x1,y1 , rota-pi/2 , scale , dist , spr:getWidth()/2)
end

function print_centered(text, x, y, rot, sx, sy, ...)
	rot = rot or 0
	sx = sx or 1
	sy = sy or sx
	local font   = love.graphics.getFont()
	local text_w = font:getWidth(text)
	local text_h = font:getHeight()
	love.graphics.print(text, x-text_w/2, y-text_h/2, rot, sx, sy, ...)
end

function print_ycentered(text, x, y, rot, sx, sy, ...)
	rot = rot or 0
	sx = sx or 1
	sy = sy or sx
	local font   = love.graphics.getFont()
	local text_h = font:getHeight()
	love.graphics.print(text, x, y-text_h/2, rot, sx, sy, ...)
end

-- Thanks to steVeRoll: https://www.reddit.com/r/love2d/comments/h84gwo/how_to_make_a_colored_sprite_white/
local white_shader = love.graphics.newShader[[
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		return vec4(1, 1, 1, Texel(texture, textureCoords).a) * color;
	}
]]
function draw_white(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
	-- drawable, x, y, r, sx, sy, ox, oy, kx, ky
	love.graphics.setShader(white_shader)
	love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
	love.graphics.setShader()
end

function draw_using_shader(drawable, shader, x, y, r, sx, sy, ox, oy, kx, ky)
	-- drawable, x, y, r, sx, sy, ox, oy, kx, ky
	love.graphics.setShader(shader)
	love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
	love.graphics.setShader()
end

function print_centered_outline(col_in, col_out, text, x, y, thick, rot, sx, sy, ...)
	rot = rot or 0
	sx = sx or 1
	sy = sy or sx
	local font   = love.graphics.getFont()
	local text_w = font:getWidth(text)
	local text_h = font:getHeight()
	print_outline(col_in, col_out, text, x-text_w/2, y-text_h/2, thick, rot, sx, sy, ...)
end

function print_ycentered_outline(col_in, col_out, text, x, y, thick, rot, sx, sy, ...)
	rot = rot or 0
	sx = sx or 1
	sy = sy or sx
	local font   = love.graphics.getFont()
	local text_h = font:getHeight()
	print_outline(col_in, col_out, text, x, y-text_h/2, thick, rot, sx, sy, ...)
end

function get_text_width(text, font)
	local text = text or ' '
	local font = font or love.graphics.getFont()
	return font:getWidth(text)
end

function get_text_height(text, font)
	local font = font or love.graphics.getFont()
	return font:getHeight(text)
end

function print_justify_right(text, x, y)
	local w = get_text_width(text)
	love.graphics.print(text, x-w, y)
	return x-w, y
end

function concat(...)
	local args = {...}
	local s = ""
	for _,v in pairs(args) do
		local seg = tostring(v)
		if v == nil then  seg = "nil"  end
		if type(v) == table then   seg = table_to_str(v)   end
		s = s..seg
	end
	return s
end

function concatsep(tab, sep)
	sep = sep or " "
	local s = tostring(tab[1])
	for i=2,#tab do
		s = s..sep..tostring(tab[i])
	end
	return s
end

function concat_keys(tab, sep)
	sep = sep or " "
	local s = ""
	for k,v in pairs(tab) do
		s = s..sep..tostring(k)
	end
	return utf8.sub(s, 2, -1)
end

function bool_to_int(b)
	if b then
		return 1
	end
	return 0
end

function bool_to_dir(b)
	if type(b) ~= "boolean" then   return b   end
	if b then    return 1    end
	return -1
end

function clamp(val, lower, upper)
	assert(val and lower and upper, "One of the clamp values is not defined")
	if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
	return math.max(lower, math.min(upper, val))
end

function sign(n)
	if n < 0 then
		return -1
	end
	return 1
end

function sign0(n)
	if n < 0 then
		return -1
	elseif n == 0 then
		return 0
	end
	return 1
end

function smooth_circle(type, x, y, r, col)
	love.graphics.setColor(col)
	love.graphics.setPointSize(r)
	love.graphics.setPointStyle("smooth")
	love.graphics.points(x,y)
	love.graphics.setColor(1,1,1)
end

function get_rank_color(rank, defcol)
	if rank == 1 then
		return rgb(255,206,33)
	elseif rank == 2 then
		return rgb(120,163,193)
	elseif rank == 3 then
		return rgb(218,75,29)
	else
		return defcol
	end
end

function split_str(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function print_debug(...)
	print(concat("[DEBUG] ", concatsep({...}, " ")))
end

function table_to_str(tab)
	if type(tab) ~= "table" then
		return tostring(tab)
	end
	
	local s = ""
	for k,v in pairs(tab) do
		if type(k) == "number" then
			s = s..table_to_str(v)..", "
		else
			s = s..tostring(k).." = "..table_to_str(v)..", "
		end
	end
	s = string.sub(s, 1, #s-2)
	s = "{"..s.."}"
	return s
end

function print_table(node)
	if node == nil then
		print("[nil]")
		return
	end
	if type(node) ~= "table" then
		print("[print_table: not a table]")
		return
	end

	-- https://www.grepper.com/answers/167958/print+table+lua?ucard=1
	local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    print(output_str)
end

function table_2d(w,h,val)
	local t = {}
	for i=1,h do
		t[i] = {}
		for j=1,w do
			t[i][j] = val
		end
	end
	return t
end

function table_2d_0(w,h,val)
	local t = {}
	for i=0,h-1 do
		t[i] = {}
		for j=0,w-1 do
			t[i][j] = val
		end
	end
	return t
end


function draw_rank_medal(rank, defcol, x, y)
	--- Circle
	local rank_col = get_rank_color(rank, defcol)
	love.graphics.setColor(rank_col)
	love.graphics.draw(img.circle, x, y)
	--- Text
	love.graphics.setColor(1,1,1)
	print_centered(rank, x+16, y+16)
	--- 1"er", 2"e"...
	local e = rank==1 and "er" or "e"
	print_centered(e, x+32, y+12, 0, .75)
end

function strtobool(str)
	return str ~= "false" -- Anything other than "false" returns as true
end

function random_neighbor(n)
	return love.math.random()*2*n - n
end

function random_range(a,b)
	return love.math.random()*(b-a) + a
end

function random_sample(t)
	return t[love.math.random(1,#t)]
end

function random_str(a, b)
	return tostring(love.math.random(a,b))
end

function random_weighted(li, rng)
	local sum_w = 0
	for _,e in pairs(li) do
		sum_w = sum_w + e[2]
	end

	local rnd 
	if rng then 
		rnd = rng:random(0, sum_w-1)
	else 
		rnd = love.math.random(0, sum_w-1)
	end
	
	for i=1, #li do
		if rnd < li[i][2] then
			return li[i][1], li[i]
		end
		rnd = rnd - li[i][2]
	end
	assert("Random_weighted out of range // Something has gone wrong and your code definitely sucks!")
end

function random_polar(rad)
	local rnd_ang = love.math.random() * pi2
	local rnd_rad = love.math.random() * rad
	local x = math.cos(rnd_ang) * rnd_rad
	local y = math.sin(rnd_ang) * rnd_rad
	return x, y
end

--[[
function utf8.sub(str, i, j)
	local offseti = utf8.offset(str, i or 1)
	local offsetj = utf8.offset(str, j+1 or 0)-1
	if offseti and (offsetj or not j) then
		return str:sub(offseti, j and offsetj)
	end
	return str
end
function utf8.sub(str, i, j)
	if utf8.len(str) == 0 then  return ""  end
  local ii = utf8.offset(str, i)
  local jj = utf8.offset(str, j)-1
	return string.sub(str, ii, jj)
end

function utf8.sub(str, i, j)
	str = str or ""
	str = tostring(str)
	i = i or 1
	j = j or 1
	--if i < 0 then   i = uft8.len(str)-i+1   end
	--if j < 0 then   j = uft8.len(str)-j+1   end
	local len = utf8.len(str)
	if i > len then   i = len   end
	if j > len then   j = len   end
	if utf8.len(str) == 0 then  return ""  end
	print(str,i, j, len)
	local ii = utf8.offset(str, i)
  local jj = utf8.offset(str, j)+1
	return string.sub(ii, jj)
end
--]]

-- Thanks to "index five" on Discord
local utf8pos, utf8len = utf8.offset, utf8.len
local sub = string.sub
local max, min = math.max, math.min

function posrelat(pos, len)
	if pos >= 0 then return pos end
	if -pos > len then return 0 end
	return pos + len + 1
end

function utf8.sub(str, i, j)
	local len = utf8len(str)
	i, j = max(posrelat(i, len), 1), j and min(posrelat(j, len), len) or len
	if i <= j  then
		return sub(str, utf8pos(str, i), utf8pos(str, j + 1) - 1)
	end
	return ""
end



function print_color(col, text, x, y)
	col = col or {1,1,1,1}
	love.graphics.setColor(col)
	love.graphics.print(text, x, y)
	love.graphics.setColor(1,1,1,1)
end

function print_outline(col_in, col_out, text, x, y, r)
	r=r or 1
	for ix=-r, r do
		for iy=-r, r do
			if not (ix == 0 and iy == 0) then 
				print_color(col_out, text, x+ix, y+iy)
			end
		end
	end
	print_color(col_in, text, x, y)
end

function print_label(text, x, y, col_txt, col_label)
	col_txt, col_label = COL_WHITE or col_txt, {0,0,0,0.5} or col_label 
	local w = get_text_width(text)
	local h = get_text_height(text)
	rect_color(col_label, "fill", x, y, w, h)
	print_color(col_txt, text, x, y)
end

function exec_color(col, func, ...)
	col = col or {1,1,1,1}
	love.graphics.setColor(col)
	func(...)
	love.graphics.setColor(1,1,1,1)
end

function rect_color(col, mode, x, y, w, h, ...)
	assert(col, "color not defined")
	assert(mode, "rect mode not defined ('line' or 'fill')")
	assert(x, "rect x not defined")
	assert(y, "rect y not defined")
	assert(w, "rect width not defined")
	assert(h, "rect height not defined")
	col = col or {1,1,1,1}
	love.graphics.setColor(col)
	love.graphics.rectangle(mode, floor(x)+0.5, floor(y)+0.5, floor(w), floor(h), ...)
	love.graphics.setColor(1,1,1,1)
end

function circle_color(col, mode, x, y, r)
	col = col or {1,1,1,1}
	love.graphics.setColor(col)
	love.graphics.circle(mode, floor(x)+0.5, floor(y)+0.5, r)
	love.graphics.setColor(1,1,1,1)
end

function line_color(col, ax, ay, bx, by, ...)
	col = col or {1,1,1,1}
	love.graphics.setColor(col)
	love.graphics.line(floor(ax), floor(ay), floor(bx), floor(by), ...)
	love.graphics.setColor(1,1,1,1)
end

function noise(...)
	local v = love.math.noise(...)
	return v*2 - 1
end

function noise01(...)
	local v = love.math.noise(...)
	return v
end

function sqr(a)
	return a*a
end

function distsqr(ax, ay, bx, by)
	bx = bx or 0
	by = by or 0
	return sqr(bx - ax) + sqr(by - ay)
end

function dist(...)
	return sqrt(distsqr(...))
end

function cerp(a,b,t)
	-- "constant" interpolation?
	if abs(a-b) <= t then    return b    end
	return a + sign0(b-a)*t
end

function lerp(a,b,f)
	return a + (b - a) * f
end

function lerp_dt(a, b, f, dt)
	return lerp(a, b, 1 - f ^ dt)
end

function lerp_color(a,b,t)
	local c = {
		lerp(a[1], b[1], t),
		lerp(a[2], b[2], t),
		lerp(a[3], b[3], t),
		lerp(a[4] or 1, b[4] or 1, t),
	}
	return c
end

function move_toward(from, to, delta)
	-- https://github.com/godotengine/godot/blob/f2045ba822bff7d34964901393581a3117c394a9/core/math/math_funcs.h#L464
	if math.abs(to - from) <= delta then
		return to
	else
		return from + sign(to - from) * delta
	end
end

function wrap_to_pi(a)
	return (a + math.pi) % (math.pi*2) - math.pi
end

function shortest_angle_dist(a, b)
	local max = 2*math.pi
	local diff = (b - a) % max
	return (2*diff) % max - diff
end

function lerp_angle(a, b, t)
	local epsilon = 0.01
	if abs(b - a) > epsilon then
		a = a % (math.pi*2)
		return a + shortest_angle_dist(a, b)*t
	else
		return b
	end
end

function get_left_vec(x, y)
	return y, -x
end

function get_right_vec(x, y)
	return -y, x
end

function get_orthogonal(x, y, dir)
	if dir < 0 then
		return get_left_vec(x,y)
	else
		return get_right_vec(x,y)
	end
end

function create_actor_centered(actor, x, y, ...)
	local a = actor:new(x, y, ...)
	local nx = floor(a.x - a.w/2)
	local ny = floor(a.y - a.h)
	a:set_pos(nx, ny)
	return a
end

function not_nil(x)
	return x ~= nil
end	

function range_table(a, b)
	local t = {}
	for i=a, b do
		table.insert(t, i)
	end
	return t
end


function time_to_string(time)
	local secs = round(time%60, 1)
	local mins = floor(time/60) % 60
	local hours = floor(time/3600)
	
	if secs == floor(secs) then
		secs = tostring(secs)..".0"	
	end
	local ss = utf8.sub( "00"..tostring(secs), -4, -1 )
	local mm = utf8.sub( "00"..tostring(mins), -2, -1 )
	local hh = utf8.sub( "00"..tostring(hours), -max(#tostring(hours), 2), -1 )
	
	if hours > 0 then 
		return concat(hh,":",mm,":",ss)
	end
	return concat(mm,":",ss)
end


function get_left_vec(x, y)
	return y, -x
end

function get_right_vec(x, y)
	return -y, x
end

function get_orthogonal(x, y, dir)
	if dir < 0 then
		return get_left_vec(x,y)
	else
		return get_right_vec(x,y)
	end
end