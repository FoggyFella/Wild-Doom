extends Position2D

var type = ""
var amount = 0
var velocity = Vector2.ZERO
var random_rotation = 0

func _ready():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	$Label.text = amount
	if int(amount) == 0:
		queue_free()
	match type:
		"Red":
			$Label.set("custom_colors/font_color", Color("c71e85"))
			$Label.set("custom_colors/font_color_shadow", Color("800d53"))
		"White":
			$Label.set("custom_colors/font_color", Color("ffffff"))
			$Label.set("custom_colors/font_color_shadow", Color("8f898a"))
		"Critical":
			$Label.set("custom_colors/font_color", Color("c71e42"))
			$Label.set("custom_colors/font_color_shadow", Color("760b22"))
		"Green":
			$Label.set("custom_colors/font_color", Color("5aed17"))
			$Label.set("custom_colors/font_color_shadow", Color("327b09"))
	randomize()
	random_rotation = rand_range(-10,10)
	var side_mov = randi() % 81 - 40
	velocity = Vector2(side_mov,50)
	tween.tween_property($Label,"rect_scale",Vector2(1,1),0.3)
	tween.tween_interval(0.3)
	tween.tween_property($Label,"rect_scale",Vector2(0.1,0.1),0.5)
	tween.connect("finished",self,"on_tween_finished")

func on_tween_finished():
	self.queue_free()

func _process(delta):
	randomize()
	random_rotation = rand_range(-10,10)
	rotation_degrees = lerp(rotation_degrees,random_rotation,0.5)
	position -= velocity * delta


func _on_NumberArea_area_entered(area):
	if area.name == "NumberArea":
		amount += area.get_parent().amount
		area.get_parent().queue_free()
