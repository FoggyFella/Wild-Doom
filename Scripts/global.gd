extends Node

var player = null
var pick_ups = 0
var enemies_killed = 0
var waves_passed = 0
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
"player_crit_chance" : 0.1,
"flames_shield" : 0.75,
"flames_speed" : 300,
"shotty_bullet_upgrades": 0,
"sniper_health": 3,
"flames_size": 1,
"enemy_bite_damage": 10,
"boss_proj_dmg": 40,
"defense": 1,
"activated_boosts": [],
"player_healing": 1,
"player_earnings": 1}

signal frenzy_start
signal weapon_equipped
signal money_picked_up
signal ruby_collected
signal pick_up_collected
signal activate_stalkers
signal activate_fuckers
signal activate_boss
signal activate_boost

var settings = {
	"fullscreen" : false,
	"sfx_volume" : 0,
	"music_volume" : 0,
	"deadzone" : 0.5,
	"beat_gorilla" : false,
	"saw_intro" : false,
	"unlocked_chapters" : [1],
	"rubys" : 0,
	"bought_items" : {},
	"unlocked_chapter_parts" : [1.1]
}

var min_shield_time = 0.25
var max_flame_speed = 435
var max_fire_rate = 0
var bought_weapons = ["Pistol"]
var equipped_weapon = "Pistol"
var activated_fuckers = false
var activated_stalkers = false
var activated_boss = false
var frenzy_on = false

var selected_wave = 1
#var selected_wave = 1

var money = 0
var time = 0
var timer_on = false
var time_text = null

var fullscreen = false
var sfx_volume = 0
var music_volume = 0

onready var music_bus = AudioServer.get_bus_index("MusicBus")
onready var sfx_bus = AudioServer.get_bus_index("SoundEffects")
onready var dash_bus = AudioServer.get_bus_index("DashBus")

func _ready():
	load_game()
	get_tree().set_auto_accept_quit(false)
	configure_wolf()
	if settings["fullscreen"] == true:
		OS.set_window_fullscreen(true)
	else:
		OS.set_window_fullscreen(false)
	AudioServer.set_bus_volume_db(music_bus,settings["music_volume"])
	AudioServer.set_bus_volume_db(sfx_bus,settings["sfx_volume"])
	AudioServer.set_bus_volume_db(dash_bus,settings["sfx_volume"])
	print("Bought weapons: " + str(bought_weapons))
	print("Equipped weapons: " + str(equipped_weapon))
	print("High score: " + str(high_score))
	print("Money: " + str(money))

func reset_stats():
	#WHEN YOU UPDATE THIS UPDATE ALSO THE ONES LOWER
	pick_ups = 0
	enemies_killed = 0
	waves_passed = 0
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
	stats["flames_shield"] = 0.75
	stats["flames_speed"] = 300
	stats["shotty_bullet_upgrades"] = 0
	stats["sniper_health"] = 3
	stats["flames_size"] = 1
	stats["enemy_bite_damage"] = 10
	stats["boss_proj_dmg"] = 40
	stats["defense"] = 1
	stats["activated_boosts"] = []
	stats["player_healing"] = 1
	stats["player_earnings"] = 1
	player_max_health = 100
	activated_fuckers = false
	activated_stalkers = false
	activated_boss = false
	score = 0
	max_fire_rate = 0
	frenzy_on = false
	#selected_wave = 1

func reset_enemy_stats():
	stats["enemy_speed"]=80
	stats["enemy_damage"]=10
	stats["enemy_health"]=100

func next_part_reset():
	spawn_time = 4
	stats["player_damage"]=50
	reset_enemy_stats()
	stats["player_health"]=100
	stats["player_speed"]=90
	stats["player_bullets"]=[0]
	stats["player_firerate"] = 0.66
	stats["player_crit_chance"] = 0.1
	stats["flames_shield"] = 0.75
	stats["flames_speed"] = 300
	stats["shotty_bullet_upgrades"] = 0
	stats["sniper_health"] = 3
	stats["flames_size"] = 1
	stats["defense"] = 1
	stats["activated_boosts"] = []
	stats["player_healing"] = 1
	stats["player_earnings"] = 1
	player_max_health = 100
	activated_fuckers = false
	activated_stalkers = false
	activated_boss = false
	max_fire_rate = 0
	frenzy_on = false
	selected_wave = 1

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
	if stats["flames_shield"] < min_shield_time:
		stats["flames_shield"] = min_shield_time
	if stats["flames_speed"] > max_flame_speed:
		stats["flames_speed"] = max_flame_speed
	
	if timer_on:
		time += delta
	
	var secs = fmod(time,60)
	var mins = fmod(time, 60*60) / 60
	
	var time_passed = "%02d : %02d" % [mins,secs]
	time_text = time_passed
	
#	if time_text == "10 : 00" and activated_stalkers == false:
#		activated_stalkers = true
#		emit_signal("activate_stalkers")
#
#	if time_text == "15 : 00" and activated_boss == false:
#		activated_boss = true
#		emit_signal("activate_boss")
#
#	if time_text == "12 : 45" and activated_fuckers == false:
#		activated_fuckers = true
#		emit_signal("activate_fuckers")

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
	f.store_var(settings)
	f.close()

func load_game():
	var f = File.new()
	if f.file_exists(score_file):
		f.open(score_file, File.READ)
		equipped_weapon = f.get_var()
		bought_weapons = f.get_var()
		high_score = f.get_var()
		money = f.get_var()
		settings = f.get_var()
		f.close()
	else:
		equipped_weapon = "Pistol"
		bought_weapons = ["Pistol"]
		money = 0
		high_score = 0
		settings["fullscreen"] = false
		settings["sfx_volume"] = 0
		settings["music_volume"] = 0
		settings["deadzone"] = 0.5
		settings["beat_gorilla"] = false
		settings["saw_intro"] = false
		settings["unlocked_chapters"] = [1]
		settings["rubys"] = 0
		settings["bought_items"] = {}

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().paused = true
		save_game()
		yield(get_tree().create_timer(1),"timeout")
		get_tree().quit()

func configure_wolf():
	SilentWolf.configure({
		"api_key": "l9LNd7SqxqaTnbftLhYTjaIj8iQYotNva2dkCJAf",
		"game_id": "demonblast",
		"game_version": "1.0",
		"log_level": 0
	})
