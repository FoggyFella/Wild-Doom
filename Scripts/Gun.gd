extends AnimatedSprite

onready var camera_2d = $"../../Camera2D"
onready var player = get_parent().get_parent()
onready var gun_timeout = $"../../gun timeout"

var can_fire = true
var bullet = preload("res://Scenes/Bullet.tscn")
var flame = preload("res://Scenes/Flamethrower_bullet.tscn")
var rots = [0]
var look_vec = null
var firerate = 0.66
var sprite_size = 0
var move_vec = Vector2.ZERO
var rs_look = Vector2(0,0)
var deadzone = 1.0

export var bullet_delay:float = 0.0
export var should_show_total_dmg:bool = false
export var should_screenshake:bool = true
export var is_a_flamethrower:bool = false
export var bullet_sprite:String = "Pistol"
export var should_have_knockback:bool = true
export var bullet_health:int = 1
export var starting_damage:int = 50
export var bullet_speed:int = 50
export var bullet_dissapear_after:float = 3
export var starting_critchance:float = 0.1
export var bullets_rotations:Array = [0]
export var bullets_rotations_rand:Array
export var recoil_min:float = 2
export var recoil_max:float = 10
export var starting_firerate:float = 0.66
export var max_firerate:float = 0.5

func _ready():
	Global.stats["player_crit_chance"] = starting_critchance
	Global.stats["player_damage"] = starting_damage
	Global.stats["player_bullets"] = bullets_rotations
	Global.stats["player_firerate"] = starting_firerate
	Global.max_fire_rate = max_firerate
	sprite_size = self.scale.x
	deadzone = Global.settings["deadzone"]
	gun_timeout.connect("timeout",self,"_on_gun_timeout_timeout")
	firerate = Global.stats["player_firerate"]
	Global.connect("pick_up_collected",self,"update_self_stats")
	Global.connect("frenzy_start",self,"update_self_stats")
	Global.emit_signal("pick_up_collected")

func _physics_process(delta):
#	look_vec = get_global_mouse_position() - global_position
#	rotation = atan2(look_vec.y,look_vec.x)
	rslook()
	if abs(rotation_degrees) > 88:
		scale.y = lerp(scale.y,-sprite_size,0.1)
		#scale.y = -1
	else:
		scale.y = lerp(scale.y,sprite_size,0.1)
	
	if Input.is_action_pressed("fire"):
		fire()
		
func fire():
	var rotation_my = 0
	if !is_a_flamethrower:
		rots = Global.stats["player_bullets"]
	if is_a_flamethrower:
		rots = [0,0,0,0,0,0,0,0,0,0,0]
	if can_fire:
		var counta = 0
		if is_a_flamethrower:
			bullet = flame
		can_fire = false
		randomize()
		if should_screenshake:
			player.camera.RANDOM_SHAKE_STRENGTH = 2.5
			player.camera.apply_random_shake()
		var bullet_keep = rots
		var random_bullet_pattern = null
		if !bullets_rotations_rand.empty():
			random_bullet_pattern = bullets_rotations_rand[int(rand_range(0,bullets_rotations_rand.size()))]
			for bullet_rot in random_bullet_pattern:
				var new_bullet_rot = rand_range(-0.3,0.3)
				#print("Rots: " + str(rots)+ "\n" +"Bullet_rot: " + str(bullet_rot))
				random_bullet_pattern.erase(bullet_rot)
				random_bullet_pattern.append(new_bullet_rot)
			bullet_keep = random_bullet_pattern
		if scale.y < 0:
			rotation_my = rand_range(recoil_min,recoil_max)
		else:
			rotation_my = rand_range(-recoil_min,-recoil_max)
		$AnimationPlayer.play("shoot")
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(get_parent(),"rotation_degrees",rotation_my,0.05)
		tween.tween_property($Position2D/Light2D2,"energy",2.0,0.1)
		if !is_a_flamethrower:
			tween.tween_interval(0.05)
			tween.parallel().tween_property($Position2D/Light2D2,"energy",0.0,0.1)
			tween.tween_property(get_parent(),"rotation_degrees",0.0,0.2)
		randomize()
		var random_numbah = int(rand_range(1,2))
		get_node("shoot" + str(random_numbah)).pitch_scale = rand_range(0.85,1.3)
		get_node("shoot" + str(random_numbah)).play()
		if is_a_flamethrower:
			gun_timeout.start(firerate)
		for i in range(bullet_keep.size()):
			counta += 1
			var bullet_instance = bullet.instance()
			bullet_instance.global_rotation = global_rotation + bullet_keep[i]
			bullet_instance.global_position = $Position2D.global_position
			bullet_instance.health = bullet_health
			bullet_instance.is_flamethrower = is_a_flamethrower
			bullet_instance.bullet_speed = bullet_speed
			bullet_instance.should_knockback = should_have_knockback
			bullet_instance.bullet_sprite = bullet_sprite
			if bullet_sprite == "Sniper":
				bullet_instance.health = Global.stats["sniper_health"]
			bullet_instance.should_show_total_dmg = should_show_total_dmg
			bullet_instance.time_to_be_gone = bullet_dissapear_after
			get_tree().current_scene.get_node("Player_Bullets").add_child(bullet_instance)
			if is_a_flamethrower and counta == 1:
				bullet_instance.queue_free()
			if bullet_delay != 0.0:
				yield(get_tree().create_timer(bullet_delay),"timeout")
			if is_a_flamethrower:
				yield(get_tree().create_timer(0.05),"timeout")
		if !is_a_flamethrower:
			gun_timeout.start(firerate)
		if is_a_flamethrower:
			var tween2 = create_tween()
			tween2.parallel().tween_property($Position2D/Light2D2,"energy",0.0,0.1)
			tween2.tween_property(get_parent(),"rotation_degrees",0.0,0.2)

func update_self_stats():
	#bullets_rotations = Global.stats["player_bullets"]
	firerate = Global.stats["player_firerate"]

func _on_gun_timeout_timeout():
	can_fire = true

func _input(event):
#	if event is InputEventJoypadMotion:
#		var deadzone = 0.9
#		var controllerangle = Vector2.ZERO
#		var xAxisRL = Input.get_joy_axis(0, JOY_AXIS_0)
#		var yAxisUD = Input.get_joy_axis(0 ,JOY_AXIS_1)
#
#		if abs(xAxisRL) > deadzone || abs(yAxisUD) > deadzone:
#			controllerangle = Vector2(xAxisRL, yAxisUD).angle()
#			rotation = controllerangle
		#rotation = atan2(rotate_with_controller().y,rotate_with_controller().x)
	if event is InputEventMouseMotion:
		look_vec = get_global_mouse_position() - global_position
		rotation = atan2(look_vec.y,look_vec.x)

func rotate_with_controller():
	var vec = Vector2.ZERO
	vec.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	vec.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	if vec != Vector2.ZERO:
		move_vec = vec# * 3
	return move_vec

func rslook():
	rs_look.y = Input.get_joy_axis(0, JOY_AXIS_3)
	rs_look.x = Input.get_joy_axis(0, JOY_AXIS_2)
	if rs_look.length() >= deadzone and rs_look != Vector2.ZERO:
		rotation = rs_look.angle()
