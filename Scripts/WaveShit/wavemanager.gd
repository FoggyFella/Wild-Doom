extends Node

export var should_walk_to_the_point = false
export var next_part = ""
export var should_upgrade = false

var list_of_enemies = {
	"Walker" : preload("res://Scenes/Walker Enemy.tscn"),
	"Shooting" : preload("res://Scenes/ShootingNewEnemy.tscn"),
	"ShootingOld" : preload("res://Scenes/ShootingEnemy.tscn"),
	"Fucker" : preload("res://Scenes/Fucker.tscn"),
	"Gorilla" : preload("res://Scenes/Boss Guy.tscn"),
	"Dog" : preload("res://Scenes/Dog.tscn"),
	"AxeGuy" : preload("res://Scenes/AxeGuy.tscn"),
	"Executioner" : preload("res://Scenes/Big Axe Guy.tscn")
}

var enemy_spawn_effect = preload("res://Scenes/Enemy_spawn_effecty.tscn")
var waiting = false
var current_wave = Global.selected_wave - 1
var spawn_time = 3.0
var min_spawn_time = 2.0
var minus_time = 0.2

onready var ui = $"../UI"

func _ready():
	ui.change_to_waiting()

func _process(delta):
	if waiting:
		if get_parent().get_node("Enemies").get_child_count() == 0:
			waiting = false
			get_parent().get_node("TimeUntilNewWave").start()
			ui.change_to_waiting()
			Global.waves_passed += 1
			if should_upgrade:
				Global.stats["enemy_health"] += get_percentage(Global.stats["enemy_health"],25)
				Global.stats["enemy_damage"] += get_percentage(Global.stats["enemy_damage"],10)
				Global.stats["enemy_speed"] += get_percentage(Global.stats["enemy_speed"],1)
			ui.after_wave_upgrade()

func _on_TimeUntilNewWave_timeout():
	current_wave += 1
	ui.change_wave_text(current_wave)
	run_wave(current_wave)

func run_wave(number):
	randomize()
	if has_node("Wave"+str(number)):
		var wave_holder = get_child(number-1)
		var wave_enemies = wave_holder.get_children()
		wave_enemies.shuffle()
		for enemy in wave_enemies:
			var spawn_path = null
			if enemy.get_children() != null:
				var enemy_children = enemy.get_children()
				enemy_children.shuffle()
				for enemy_child in enemy_children:
					match enemy_child.name.rstrip("0123456789"):
						"Walker" : spawn_path = get_parent().get_node("WalkersSpawn")
						"Dog" : spawn_path = get_parent().get_node("WalkersSpawn")
						"Shooting" : spawn_path = get_parent().get_node("WalkersSpawn")
					if enemy_child.name.rstrip("0123456789") != "Gorilla":
						spawn_enemy(enemy,spawn_path)
					else:
						get_parent().spawn_boss("Demon Tank")
			match enemy.name.rstrip("0123456789"):
				"Walker" : spawn_path = get_parent().get_node("WalkersSpawn")
				"Dog" : spawn_path = get_parent().get_node("WalkersSpawn")
				"Shooting" : spawn_path = get_parent().get_node("WalkersSpawn")
			if enemy.name.rstrip("0123456789") != "Gorilla" and enemy.name.rstrip("0123456789") != "ShootingOld" and enemy.name.rstrip("0123456789") != "AxeGuy" and enemy.name.rstrip("0123456789") != "Executioner":
				spawn_enemy(enemy,spawn_path)
			elif enemy.name.rstrip("0123456789") == "Gorilla" or enemy.name.rstrip("0123456789") == "Executioner":
				if enemy.name.rstrip("0123456789") == "Gorilla":
					get_parent().spawn_boss("Demon Tank","Gorilla")
				elif enemy.name.rstrip("0123456789") == "Executioner":
					get_parent().spawn_boss("Executioner Acranus","Executioner")
			elif enemy.name.rstrip("0123456789") == "ShootingOld" or enemy.name.rstrip("0123456789") == "AxeGuy":
				spawn_enemy(enemy,get_parent().get_node("RangerSpawn"),false)
			get_parent().get_node("WaveSpawnerTimer").start(spawn_time)
			yield(get_parent().get_node("WaveSpawnerTimer"),"timeout")
		waiting = true
		waiting = true
		if spawn_time > min_spawn_time:
			spawn_time -= minus_time
	else:
		if next_part != "":
			Global.stats["player_bullets"] = [0]
			Global.next_part_reset()
			Transition.test(next_part)
			#Transition.white_transition(next_part)
		else:
			Global.stats["player_bullets"] = [0]
			get_parent().get_node("UI").show_death_screen(true)

func spawn_enemy(enemy,path,should_walk_to_the=true):
	var enemy_spawn = enemy_spawn_effect.instance()
	enemy_spawn.enemy = list_of_enemies[enemy.name.rstrip("0123456789")]
	var point_i = int(rand_range(0,path.get_curve().get_point_count()))
	var point_position = path.get_curve().get_point_position(point_i)
	enemy_spawn.position = point_position
	if should_walk_to_the_point:
		enemy_spawn.should_walk_to_the_point = should_walk_to_the
	get_parent().get_node("Enemy_Spawners").add_child(enemy_spawn)

func get_random_kid(parent):
	var kiddo = parent.get_child(randi() % parent.get_child_count())
	return kiddo

func get_percentage(from,perc,should_round = true):
	if should_round:
		return round(float(perc)/100.0 * from)
	else:
		return float(perc)/100.0 * from
