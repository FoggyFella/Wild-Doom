extends Node2D

var pick_up = preload("res://Scenes/pick_up.tscn")
var enemy_spawn_effect = preload("res://Scenes/Enemy_spawn_effecty.tscn")

var bosses = {
	"Gorilla" : preload("res://Scenes/Boss Guy.tscn"),
	"Executioner" : preload("res://Scenes/Big Axe Guy.tscn")
}

func _ready():
	Global.timer_on = true
	Global.connect("activate_boss",self,"on_boss_activate")
	if Music.get_node("Chapter1").playing == false and Music.get_node("Chapter1").volume_db == -60 and Music.current_music != "Chapter1":
		Music.get_node("Chapter1").playing = true
		Music.get_node("Chapter1").volume_db = -15
		Music.current_music = "Chapter1"
	#start_from_wave(Global.selected_wave)
	$UI.print_bullet_status("On Ready")
	#Transition.test("res://Scenes/World.tscn")

func _on_PickupTimer_timeout():
	randomize()
#	var position_x = rand_range(-450,575)
#	var position_y = rand_range(-275,335)
#	var pick_inst = pick_up.instance()
#	pick_inst.message_label = $UI
#	pick_inst.position = Vector2(position_x,position_y)
#	get_node("PickUps").add_child(pick_inst)
	var point_i = int(rand_range(0,$PickUpSpawnLine.get_point_count()))
	var pick_inst = pick_up.instance()
	pick_inst.message_label = $UI
	pick_inst.global_position = $PickUpSpawnLine.get_point_position(point_i)
	get_node("PickUps").add_child(pick_inst)

func spawn_boss(boss_name,boss_preloaded_name):
	$BossCamera.position = $Player.position
	$BossCamera.current = true
	var tween = create_tween()
	var enemy_spawn = enemy_spawn_effect.instance()
	enemy_spawn.enemy = bosses[boss_preloaded_name]
	enemy_spawn.scale = Vector2(1.5,1.5)
	for enemy in get_node("Enemies").get_children():
		enemy.queue_free()
	for spawner in get_node("Enemy_Spawners").get_children():
		spawner.queue_free()
	$WalkersSpawn.get_node("Timer").stop()
	$RangerSpawn.get_node("Timer").stop()
	$Player/FuckerSpawn.get_node("Timer").stop()
	Music.fade_in("Boss",1,-10,"Chapter1",3)
	get_node("Enemies").add_child(enemy_spawn)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($BossCamera,"position",Vector2(0,0),2)
	tween.tween_interval(1)
	yield(tween,"finished")
	$UI.enable_boss_health(boss_name)
	$BossCamera.current = false
	$Player/Camera2D.current = true

func start_from_wave(selected_wave):
	for wave in $WaveManager.get_children():
		if int(wave.name) < selected_wave:
			wave.queue_free() 
