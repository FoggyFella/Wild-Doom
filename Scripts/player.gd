extends KinematicBody2D

var weapons = {
	"Shotgun" : preload("res://Scenes/Shotgun.tscn"),
	"Revolver" : preload("res://Scenes/Revolver.tscn"),
	"Pistol" : preload("res://Scenes/Pistol.tscn"),
	"Sniper" : preload("res://Scenes/Sniper.tscn"),
	"Flamethrower" : preload("res://Scenes/Flamethrower.tscn"),
	"P90" : preload("res://Scenes/Petuh.tscn"),
	"Musket" : preload("res://Scenes/Musket.tscn"),
	"Foog" : preload("res://Scenes/FoogGun.tscn")
}

export var speed : float = 50.0
export var health : int = 100
export var can_be_hurt : bool = true

onready var ui = $"../UI"
onready var hurt = $hurt
onready var camera = $Camera2D

#var look_thing_vec = Vector2.ZERO
var can_move = true
var weapon = null
var dash_timeout = 3
var can_dash = true
var dash_speed = 300
var dash_duration = 0.35
var player_regen = 1
var max_regen = 5
var regen_time = 2.5
var min_regen = 0.25
var should_regen = false
var should_actually_regen = true
var dash_ghost = preload("res://Scenes/DashGhost.tscn")
var number_of_damage = preload("res://Scenes/NumberPopup.tscn")
var should_move_camera = true
var fire_before_frenzy = 0
var movement = Vector2.ZERO
var velocity = Vector2.ZERO
var should_show_arrow = false
var speed_downs = 0

func _ready():
	weapon = Global.equipped_weapon
	#weapon = "Shotgun"
	var weapon_inst = weapons[weapon].instance()
	get_node("GunRoot").add_child(weapon_inst)
	Global.player = self
	Global.connect("frenzy_start",self,"on_frenzy_started")
	Global.connect("activate_boost",self,"on_boost_activated")
	set_deadzone()

func _exit_tree():
	Global.player = null

func _process(delta):
	if should_show_arrow:
		if $arrow.global_position.distance_to(get_tree().current_scene.get_node("PickUps").get_child(0).global_position) > 100:
			$arrow.show()
		else:
			$arrow.hide()
		$arrow.look_at(get_tree().current_scene.get_node("PickUps").get_child(0).global_position)
	else:
		$arrow.hide()
	if Global.stats["player_health"] > Global.player_max_health:
		Global.player_max_health = Global.stats["player_health"]
	if should_regen and should_actually_regen:
		Global.stats["player_health"] += Global.stats["player_healing"]
		should_actually_regen = false
		if Global.stats["player_health"] >= Global.player_max_health:
			Global.stats["player_health"] = Global.player_max_health
			should_regen = false
		yield(get_tree().create_timer(regen_time),"timeout")
		if should_regen:
#			if player_regen < max_regen:
#				player_regen += 1
			if regen_time > min_regen:
				regen_time -= 0.25
			should_actually_regen = true
	$Label.text = str(regen_time)
	
func _physics_process(delta):
	if speed_downs <= 0:
		speed = Global.stats["player_speed"]
	health = Global.stats["player_health"]
	if can_move:
		var movement_vector = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		)
		movement = movement_vector.normalized()
		
		if movement.x != 0:
			if movement.x > 0:
				$Sprite.flip_h = false
			else:
				$Sprite.flip_h = true
		if get_node_or_null("GunRoot/Gun") != null:
			if $GunRoot/Gun.scale.y < 0:
				if $Sprite.flip_h == false:
					$Sprite.flip_h = true
			else:
				if $Sprite.flip_h == true:
					$Sprite.flip_h = false
		
		if movement == Vector2.ZERO:
			$AnimationPlayer.playback_speed = 1
			$AnimationPlayer.play("guy idle")
		else:
			$AnimationPlayer.playback_speed = speed/90
			$AnimationPlayer.play("guy walk")
		if Input.is_action_just_pressed("dash"):
			start_dash(dash_duration,dash_timeout)
		velocity = movement * dash_speed if is_dashing() else movement * speed
		move_and_slide(velocity,Vector2.UP)
#	if Input.is_action_just_pressed("ui_up"):
#		take_damage(1000)
#	if Input.is_action_just_pressed("ui_down"):
#		Global.stats["player_bullets"] = [-0.2,0.0,0.2]

func take_damage(amount):
	if can_be_hurt:
		can_be_hurt = false
		$Invincibility.start()
		var tween_1 = create_tween()
		tween_1.tween_property(self,"modulate",Color("8da7ff"),0.1)
		player_regen = 1
		should_regen = false
		$RegenerationTimer.start()
		ui.get_damaged()
		randomize()
		var numb_inst = number_of_damage.instance()
		numb_inst.amount = "-" + str(round(amount * Global.stats["defense"]))
		numb_inst.type = "White"
		numb_inst.position = self.position
		get_tree().current_scene.call_deferred("add_child",numb_inst)
		$Camera2D.NOISE_SHAKE_STRENGTH = rand_range(7,15)
		$Camera2D.apply_noise_shake()
		$hurt.play()
		var tween = create_tween()
		tween.tween_property(self.get_material(),"shader_param/flash_modifier",1.0,0.1)
		tween.tween_property(self.get_material(),"shader_param/flash_modifier",0.0,0.1)
		if Global.stats["player_health"] > 0 and Global.stats["player_health"]:
			Global.stats["player_health"] -= round(amount * Global.stats["defense"])
			if Global.stats["player_health"] <= 0:
				Global.stats["player_health"] = 0
				yield(get_tree().create_timer(0.1),"timeout")
				Global.player = null
				ui.show_death_screen()
		elif Global.stats["player_health"] <= 0:
			Global.stats["player_health"] = 0
			yield(get_tree().create_timer(0.1),"timeout")
			Global.player = null
			ui.show_death_screen()


func _on_RegenerationTimer_timeout():
	should_regen = true
	should_actually_regen = true
	regen_time = 2.5

func start_dash(time,timeout):
	if can_dash:
		can_dash = false
		$ghost_instancing.start()
		ui.update_dash_charge(timeout)
		$dash.pitch_scale = rand_range(0.85,1)
		$dash.play()
		set_collision_mask_bit(3, false)
		set_collision_mask_bit(4, false)
		$DashTimer.wait_time = time
		$DashTimer.start()
		$DashTimeout.wait_time = timeout
		$DashTimeout.start()
		$dash_charging.play()
		instance_ghost()

func is_dashing():
	return !$DashTimer.is_stopped()

func _on_DashTimer_timeout():
	set_collision_mask_bit(3, true)
	set_collision_mask_bit(4, true)
	instance_ghost()
	$ghost_instancing.stop()


func _on_DashTimeout_timeout():
	$dash_charged.pitch_scale = rand_range(0.9,1.15)
	$dash_charged.play()
	can_dash = true

func instance_ghost():
	var ghost_inst = dash_ghost.instance()
	ghost_inst.global_position = self.global_position
	ghost_inst.frames = $Sprite.frames
	ghost_inst.frame = $Sprite.frame
	ghost_inst.scale = $Sprite.scale
	ghost_inst.material = null
	ghost_inst.flip_h = $Sprite.flip_h
	get_tree().current_scene.add_child(ghost_inst)


func _on_ghost_instancing_timeout():
	instance_ghost()

func on_frenzy_started():
	fire_before_frenzy = Global.stats["player_firerate"]
	Global.stats["player_firerate"] = $GunRoot.get_node("Gun").max_firerate - (0.25 * $GunRoot.get_node("Gun").max_firerate)
	var tween = create_tween()
	tween.tween_property(camera,"zoom",Vector2(0.7,0.7),1)
	$FRENZY.start()
	ui.frenzy_start()
	Global.frenzy_on = true

func _on_FRENZY_timeout():
	ui.frenzy_end()
	Global.frenzy_on = false
	Global.stats["player_firerate"] = fire_before_frenzy
	$GunRoot.get_node("Gun").update_self_stats()
	var tween = create_tween()
	tween.tween_property(camera,"zoom",Vector2(0.55,0.55),1)

func _on_Invincibility_timeout():
	can_be_hurt = true
	var tween = create_tween()
	tween.tween_property(self,"modulate",Color("ffffff"),0.1)

func set_deadzone():
	InputMap.action_set_deadzone("move_left",Global.settings["deadzone"])
	InputMap.action_set_deadzone("move_up",Global.settings["deadzone"])
	InputMap.action_set_deadzone("move_down",Global.settings["deadzone"])
	InputMap.action_set_deadzone("move_right",Global.settings["deadzone"])

func apply_speed_down():
	if speed_downs < 3:
		speed_downs += 1
		$SpeedDown.start()
		speed -= get_percentage(speed,10)

func on_speed_down_timeout():
	speed_downs -= 1
	speed = Global.stats["player_speed"]

func get_percentage(from,perc,should_round = true):
	if should_round:
		return round(float(perc)/100.0 * from)
	else:
		return float(perc)/100.0 * from

func on_boost_activated(stat,how_much,time):
	#var boost_timer = get_tree().create_timer(time,PAUSE_MODE_STOP)
	#boost_timer.connect("timeout",self,"on_boost_timer_timeout",[stat,how_much])
	var boost_timer = Timer.new()
	get_tree().current_scene.add_child(boost_timer)
	boost_timer.connect("timeout",self,"on_boost_timer_timeout",[stat,how_much,boost_timer])
	boost_timer.one_shot = true
	boost_timer.start(time)
	print("some boost activated")
	Global.stats[stat] += how_much

func on_boost_timer_timeout(stat,how_much,the_timer):
	Global.stats[stat] -= how_much
	Global.stats["activated_boosts"].erase(stat)
	the_timer.queue_free()
	print("some boost finished")
