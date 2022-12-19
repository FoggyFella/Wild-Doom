extends Path2D

#var enemy = preload("res://Scenes/ShootingEnemy.tscn")
export var enemy : PackedScene
export var should_spawn : bool
export var signal_to_connect: String
export var is_the_fucker : bool
export var additional_time: float
export var name_to_look_up : String = ""
export var max_amount_of_this_type : int = 200
var enemy_spawn_effect = preload("res://Scenes/Enemy_spawn_effecty.tscn")
var point_i = int(rand_range(0,get_curve().get_point_count()))

func _ready():
	if signal_to_connect != "":
		Global.connect(signal_to_connect,self,"activate_on_signal")
	if should_spawn:
		pass
		#$Timer.start(Global.spawn_time)


func _on_Timer_timeout():
	$additional.start(additional_time)
#	randomize()
#	point_i = int(rand_range(0,get_curve().get_point_count()))
#	var enemy_spawn = enemy_spawn_effect.instance()
#	enemy_spawn.position = get_curve().get_point_position(point_i)
#	enemy_spawn.enemy = enemy
#	if is_the_fucker:
#		print(get_curve().get_point_position(point_i).x)
#		if get_curve().get_point_position(point_i).x < 0:
#			enemy_spawn.velocity_of_the_fucker = 200
#		else:
#			enemy_spawn.velocity_of_the_fucker = -200
#		enemy_spawn.is_the_fucker = true
#	get_tree().root.add_child(enemy_spawn)
#	$Timer.start(Global.spawn_time)
#	print(Global.spawn_time)


func activate_on_signal():
	should_spawn = true
	$additional.start(additional_time)
	$Timer.start(Global.spawn_time)

func _on_additional_timeout():
	var amount_of_children_of_this_type = 0
	for child in get_tree().current_scene.get_node("Enemies").get_children():
		if name_to_look_up in child.name:
			amount_of_children_of_this_type += 1
			print(amount_of_children_of_this_type)
	if amount_of_children_of_this_type < max_amount_of_this_type:
		randomize()
		point_i = int(rand_range(0,get_curve().get_point_count()))
		var enemy_spawn = enemy_spawn_effect.instance()
		enemy_spawn.position = get_curve().get_point_position(point_i)
		enemy_spawn.enemy = enemy
		enemy_spawn.name_to_look_up = name_to_look_up
		enemy_spawn.max_amount_of_this_type = max_amount_of_this_type
		if is_the_fucker:
			print(get_curve().get_point_position(point_i).x)
			if get_curve().get_point_position(point_i).x < 0:
				enemy_spawn.velocity_of_the_fucker = 200
			else:
				enemy_spawn.velocity_of_the_fucker = -200
			enemy_spawn.is_the_fucker = true
		get_tree().current_scene.get_node("Enemy_Spawners").add_child(enemy_spawn)
		$Timer.start(Global.spawn_time)
		print(Global.spawn_time)
	else:
		return
