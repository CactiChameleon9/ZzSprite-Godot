# ZzSprite - Tiny Sprite Generator - Frank Force 2020 - MIT License
extends Node2D

var shapes = [[Rect2(0, 0, 0, 0),"#000"]]
var random_seed : int
var color = "#000"

const ZzSpriteLibs = preload("ZzSpriteLibs.cs") # Relative path
onready var zz_libs = ZzSpriteLibs.new()


func _draw():
	for shape in shapes:
		draw_rect(shape[0], shape[1])

func _ready() -> void:
	randomize()
	var used_seed = int(rand_range(0, 999999999))
	ZzSprite(0, 0, used_seed, 16, 0, 0, 0)

func _random(num_max=1, num_min=0):

	random_seed = zz_libs.generate_seed(random_seed)
	
	return (fmod(abs(random_seed), 1e9) / 1e9)*(num_max-num_min) + num_min
	

func ZzSprite(x=0, y=0, mseed=1, size=16, mode=0, mutate_seed=0, color_seed=0):
	
	# random chance to flip drawing axis
	random_seed = mseed
	var flix_axis = _random() < .5
	var w = size-3 if  flix_axis else size/2 - 1 |0
	var h = size-3 if !flix_axis else size/2 - 1 |0
	
	# apply mutations
	random_seed = zz_libs.add_int32(random_seed, mutate_seed, 1e8)
	var spriteSize = size * _random(.9, .6)
	var density = _random(1, .9)
	var double_center = _random() < .5
	var y_bias = _random(.1, -.1)
	var colorRand = (.08 if mode==1 else .04)
	
	# recenter
	x += size/2 | 0
	y += 2 | 0
	
	# outline then fill
	if (mode != 3):
		_draw_sprite_internal(x, y, 1, mode, w, h, flix_axis, color_seed, colorRand, density, spriteSize, y_bias, double_center, mseed)
		yield(get_tree().create_timer(0.1), "timeout")
	_draw_sprite_internal(x, y, null, mode, w, h, flix_axis, color_seed, colorRand, density, spriteSize, y_bias, double_center, mseed)


func _draw_sprite_internal(x, y, outline, mode, w, h, flix_axis, color_seed, colorRand, density, spriteSize, y_bias, double_center, mseed):
	# draw each pixel"."
	random_seed = mseed
	var passCount = 3 if mode == 3 else 1
	for mpass in range(0, passCount):
		for k in range(0, w*h):
			var i = k/w|0 if  flix_axis else k%w
			var j = k/w|0 if !flix_axis else k%w

			# pick new _random color using color seed
			var saveSeed = random_seed
			random_seed = zz_libs.add_int32(random_seed, color_seed, 1e9)
			var r = int(_random(360))|0
			#var newColor = `hsl(${ r },${ _random(200,0)|0 }%,${ _random(100,20)|0 }%)`
			#var newColor = `hsl(${ r },${ _random(200,0)|0 }%,${ _random(100,20)|0 }%)`
			var newColor = Color.from_hsv(r / 360.0, _random(200,40)/200.0, _random(100,40)/100.0)
			if (outline || mode == 3):
				newColor = '#000'
			elif (mode == 1):
				newColor = '#444' if r%3==1 else '#999' if r%3 else '#fff'
			elif (mode == 2):
				newColor = '#fff'
			if (!k || _random() < colorRand):
				color = newColor
				#context.fillStyle = newColor
			random_seed = saveSeed
			
			# check if pixel should be drawn
			var is_hole = _random() > density
			if (pow(_random(spriteSize/2), 2) > i*i + pow((j-(1-2*y_bias)*h/2), 2) && !is_hole):
				var o = 1 if !!outline else 0
				var dc = 1 if double_center else 0
				#context.fillRect(x+i-o-double_center, y+j-o, 1+2*o, 1+2*o)
				#context.fillRect(x-i-o, y+j-o, 1+2*o, 1+2*o)
				shapes.append([Rect2(x+i-o-dc, y+j-o, 1+2*o, 1+2*o), color])
				update()
				
				shapes.append([Rect2(x-i-o, y+j-o, 1+2*o, 1+2*o), color])
				update()
				#yield(get_tree().create_timer(.05), "timeout")
