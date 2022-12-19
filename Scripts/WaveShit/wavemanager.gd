extends Node

var list_of_enemies = {
	"Walker" : preload("res://Scenes/Walker Enemy.tscn"),
	"Shooting" : preload("res://Scenes/ShootingEnemy.tscn"),
	"Fucker" : preload("res://Scenes/Fucker.tscn"),
	"Gorilla" : preload("res://Scenes/Boss Guy.tscn")
}

var enemy_spawn_effect = preload("res://Scenes/Enemy_spawn_effecty.tscn")
var waiting = false
var current_wave = 0
var spawn_time = 4.0
var min_spawn_time = 2.40
var minus_time = 0.02

onready var ui = $"../UI"

func _ready():
	ui.change_to_waiting()

func _process(delta):
	if waiting:
		if get_parent().get_node("Enemies").get_child_count() == 0:
			waiting = false
			get_parent().get_node("TimeUntilNewWave").start()
			ui.change_to_waiting()

func _on_TimeUntilNewWave_timeout():
	current_wave += 1
	ui.change_wave_text(current_wave)
	run_wave(current_wave)

func run_wave(number):
	randomize()
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
					"Shooting" : spawn_path = get_parent().get_node("RangerSpawn")
				spawn_enemy(enemy,spawn_path)
		match enemy.name.rstrip("0123456789"):
			"Walker" : spawn_path = get_parent().get_node("WalkersSpawn")
			"Shooting" : spawn_path = get_parent().get_node("RangerSpawn")
		spawn_enemy(enemy,spawn_path)
		yield(get_tree().create_timer(spawn_time),"timeout")
	waiting = true
	if spawn_time > min_spawn_time:
		spawn_time -= minus_time

func spawn_enemy(enemy,path):
	var enemy_spawn = enemy_spawn_effect.instance()
	enemy_spawn.enemy = list_of_enemies[enemy.name.rstrip("0123456789")]
	var point_i = int(rand_range(0,path.get_curve().get_point_count()))
	var point_position = path.get_curve().get_point_position(point_i)
	enemy_spawn.position = point_position
	get_parent().get_node("Enemy_Spawners").add_child(enemy_spawn)

func get_random_kid(parent):
	var kiddo = parent.get_child(randi() % parent.get_child_count())
	return kiddo
