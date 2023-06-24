# Based on ZzSprite by Frank Force 2020 - MIT License
@tool
class_name ZzSprite
extends Node2D

# These are public because the original logic relied on them being
# modified globally
var _shapes: Array = [[Rect2(0, 0, 0, 0),"#000"]]
var _random_seed : int

@export var sprite_seed : int = 22085342:
	set(value): sprite_seed = value; redraw_sprite()

@export var mutating_seed : int = 0:
	set(value): mutating_seed = value; redraw_sprite()

@export var recolor_seed : int = 0:
	set(value): recolor_seed = value; redraw_sprite()

@export_enum("Full Color:0", "Four Colors:1", "Two Colors:2", "One Color:3")
var color_mode: int = 0:
	set(value): color_mode = value; redraw_sprite()

@export var sprite_bit_size: int = 16:
	set(value): sprite_bit_size = value; redraw_sprite()

@export var offset: Vector2i = Vector2i(-8, -8):
	set(value): offset = value; redraw_sprite()

@export
var draw_outline: bool = true:
	set(value): draw_outline = value; redraw_sprite()

@export_subgroup("Legacy Options")
@export var old_one_color_mode: bool = false:
	set(value): old_one_color_mode = value; redraw_sprite()


func redraw_sprite():
	_shapes = []
	# Color mode mode depends on a few things....
	var mode: int = color_mode
	# Legacy One-Color + One Color selected
	mode = 4 if old_one_color_mode and mode == 3 else mode
	# Outline enabled and no Legacy One-Color
	mode += 10 if draw_outline and mode != 4 else 0
	
	_zzsprite_main(offset.x, offset.y, sprite_seed, sprite_bit_size, mode, mutating_seed, recolor_seed)

func _ready():
	redraw_sprite()


func _draw():
	for shape in _shapes:
		draw_rect(shape[0], shape[1])



func _random(num_max: float = 1, num_min: float = 0) -> float:
	_random_seed = _bitwise_xor_int32(_random_seed, _bitwise_left_int32(_random_seed, 13))
	_random_seed = _bitwise_xor_int32(_random_seed, _bitwise_right_int32(_random_seed, 17))
	_random_seed = _bitwise_xor_int32(_random_seed, _bitwise_left_int32(_random_seed, 5))
	return (fmod(abs(_random_seed), 1e9) / 1e9) * (num_max-num_min) + num_min
	

func _zzsprite_main(x: int = 0, y: int = 0, mseed: int = 1, size: float = 16,
		mode: int = 0, mutate_seed: int = 0, color_seed: int = 0):
	
	_random_seed = mseed
	
	# Random chance to flip drawing axis
	var flix_axis: bool = _random() < .5
	var w: int = int(size-3) if  flix_axis else int(size/2.0) - 1
	var h: int = int(size-3) if !flix_axis else int(size/2.0) - 1
	
	# Apply mutations
	_random_seed += mutate_seed + int(1e8)
	var sprite_size = size * _random(.9, .6)
	var density: float = _random(1, .9)
	var double_center: bool  = _random() < .5
	var y_bias: float = _random(.1, -.1)
	var color_rand: float = (.08 if mode==1 else .04)
	
	# Recenter
	x += int(size/2.0)
	y += 2
	
	# Outline (if enabled)...
	if mode >= 10:
		mode -= 10
		_draw_sprite_internal(x, y, 1, mode, w, h, flix_axis, color_seed, color_rand, density, sprite_size, y_bias, double_center, mseed)
	# ...then fill
	_draw_sprite_internal(x, y, null, mode, w, h, flix_axis, color_seed, color_rand, density, sprite_size, y_bias, double_center, mseed)


func _draw_sprite_internal(x, y, outline, mode, w, h, flix_axis, color_seed, color_rand, density, sprite_size, y_bias, double_center, mseed):
	var color: Color = '#000'
	_random_seed = mseed
	
	var pass_count: int = 3 if mode == 4 else 1
	for _passes in range(0, pass_count):
		for k in range(0, w*h):
			var i: int = int(k/w) if  flix_axis else int(k % int(w))
			var j: int = int(k/w) if !flix_axis else int(k % int(w))

			# pick new _random color using color seed
			var save_seed: int = _random_seed
			_random_seed = _random_seed + color_seed + 1e9
			
			var r: int = int(_random(360))
			
			# JS => let newColor = `hsl(${ r },${ _random(200,0)|0 }%,${ _random(100,20)|0 }%)`
			var hsv: Vector3 = _convert_hsl_hsv(r / 360.0, _random(200,0)/100.0, _random(100,20)/100.0)
			var newColor: Color = Color.from_hsv(hsv.x, hsv.y, hsv.z)
			
			if (outline || mode >= 3):
				newColor = '#000'
			elif (mode == 1):
				newColor = '#444' if r%3==1 else '#999' if r%3 else '#fff'
			elif (mode == 2):
				newColor = '#fff'
			if (!k || _random() < color_rand):
				# JS => context.fillStyle = newColor
				color = newColor
			
			_random_seed = save_seed
			
			# Check if pixel should be drawn
			var is_hole: bool = _random() > density
			if (pow(_random(sprite_size/2.0), 2) > i*i + pow((j-(1-2*y_bias)*h/2.0), 2) && !is_hole):
				var o: int = 1 if !!outline else 0
				var dc: int = 1 if double_center else 0
				# JS => context.fillRect(x+i-o-double_center, y+j-o, 1+2*o, 1+2*o)
				_shapes.append([Rect2(x+i-o-dc, y+j-o, 1+2*o, 1+2*o), color])
				queue_redraw()
				
				# JS => context.fillRect(x-i-o, y+j-o, 1+2*o, 1+2*o)
				_shapes.append([Rect2(x-i-o, y+j-o, 1+2*o, 1+2*o), color])
				queue_redraw()


func _bitwise_left_int32(num: int, power: int) -> int:
	num <<= 32
	num <<= power
	num >>= 32
	return num


func _bitwise_right_int32(num: int, power: int) -> int:
	var s32: int = 1 << 31
	var mask: int = 0x7fffffff
	if num < 0: 
		num |= s32
		num &= mask | s32
		num >>= power
	else:
		num &= mask
		num >>= power
	return num


func _bitwise_xor_int32(num1: int, num2: int) -> int:
	num1 = (num1 << 32) >> 32
	num2 = (num2 << 32) >> 32
	num1 ^= num2
	return num1


func _convert_hsl_hsv(hh: float, ss: float, ll: float) -> Vector3:
	# https://ariya.io/2008/07/converting-between-hsl-and-hsv
	var h: float; var s: float; var v: float
	h = hh
	ll *= 2
	ss *= ll if (ll <= 1) else 2 - ll
	v = (ll + ss) / 2
	s = (2 * ss) / (ll + ss)
	return Vector3(h, s, v)
