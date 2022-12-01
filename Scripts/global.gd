extends Node

var player = null
var pick_ups = 0
var enemies_killed = 0
var spawn_time = 4
var player_damage = 50
var enemy_damage = 20
var player_max_health = 100

var score = 0
var high_score = 0
var score_file = "user://game_savefile.save"

var stats = {"player_damage":50,
"enemy_damage": 10,
"enemy_health": 100,
"player_health": 100,
"player_speed": 90,
"enemy_speed": 80,
"player_bullets": [0],
"player_firerate" : 0.66,
"player_crit_chance" : 0.1}

signal frenzy_start
signal weapon_equipped
signal money_picked_up
signal pick_up_collected
signal activate_stalkers
signal activate_fuckers

var max_fire_rate = 0
var bought_weapons = ["Pistol"]
var equipped_weapon = "Pistol"
var activated_fuckers = false
var activated_stalkers = false
var frenzy_on = false

var money = 0
var time = 0
var timer_on = false
var time_text = null

func _ready():
	load_game()
	get_tree().set_auto_accept_quit(false)
	configure_wolf()
	print("Bought weapons: " + str(bought_weapons))
	print("Equipped weapons: " + str(equipped_weapon))
	print("High score: " + str(high_score))
	print("Money: " + str(money))

func reset_stats():
	pick_ups = 0
	enemies_killed = 0
	spawn_time = 4
	stats["player_damage"]=50
	stats["enemy_damage"]=10
	stats["enemy_health"]=100
	stats["player_health"]=100
	stats["player_speed"]=90
	stats["enemy_speed"]=80
	stats["player_bullets"]=[0]
	stats["player_firerate"] = 0.66
	stats["player_crit_chance"] = 0.1
	player_max_health = 100
	activated_fuckers = false
	activated_stalkers = false
	score = 0
	max_fire_rate = 0
	frenzy_on = false
	print(stats)

func _process(delta):
	if stats["enemy_damage"] < 10:
		stats["enemy_damage"] = 10
	if stats["enemy_speed"] < 40:
		stats["enemy_speed"] = 40
	if stats["enemy_health"] < 20:
		stats["enemy_health"] = 20
	if stats["player_firerate"] < max_fire_rate:
		stats["player_firerate"] = max_fire_rate
	if stats["player_crit_chance"] > 0.5:
		stats["player_crit_chance"] = 0.5
	
	if timer_on:
		time += delta
	
	var secs = fmod(time,60)
	var mins = fmod(time, 60*60) / 60
	
	var time_passed = "%02d : %02d" % [mins,secs]
	time_text = time_passed
	
	if time_text == "01 : 30" and activated_stalkers == false:
		activated_stalkers = true
		emit_signal("activate_stalkers")
	
	if time_text == "02 : 45" and activated_fuckers == false:
		activated_fuckers = true
		emit_signal("activate_fuckers")

func reset_timer():
	time = 0
func start_timer():
	timer_on = true
func stop_timer():
	timer_on = false

func save_game():
	var f = File.new()
	f.open(score_file, File.WRITE)
	f.store_var(equipped_weapon,true)
	f.store_var(bought_weapons,true)
	f.store_var(high_score)
	f.store_var(money)
	f.close()

func load_game():
	var f = File.new()
	if f.file_exists(score_file):
		f.open(score_file, File.READ)
		equipped_weapon = f.get_var()
		bought_weapons = f.get_var()
		high_score = f.get_var()
		money = f.get_var()
		f.close()
	else:
		equipped_weapon = "Pistol"
		bought_weapons = ["Pistol"]
		money = 0
		high_score = 0

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().paused = true
		save_game()
		yield(get_tree().create_timer(1),"timeout")
		get_tree().quit()
		print("done")

func configure_wolf():
	SilentWolf.configure({
		"api_key": "l9LNd7SqxqaTnbftLhYTjaIj8iQYotNva2dkCJAf",
		"game_id": "heckinschmeckin",
		"game_version": "1.0",
		"log_level": 0
	})
