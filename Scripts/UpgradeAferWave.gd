extends Control

onready var player_weapon = Global.player.weapon

onready var upgrades = {
	1: ["player_bullets",0,"+1 bullet to your gun!",2,0],
	2: ["player_health",+get_percentage(Global.stats["player_health"],20),"+20% health for you!",5,0],
	3: ["player_damage",+get_percentage(Global.stats["player_damage"],25),"+25% damage to your gun!",5,0],
	4: ["player_firerate",-get_percentage(Global.stats["player_firerate"],7.5,false),"+7.5% firerate to your gun!",5,0],
	5: ["player_crit_chance",+0.075,"+7.5% for getting a crit!",5,0],
	6: ["player_speed",+get_percentage(Global.stats["player_speed"],20),"+20% speed for you!",5,0],
	7: ["sniper_health",+1,"your bullets can go through 1 more enemy!",3,3],
	8: ["flames_shield",-get_percentage(Global.stats["flames_shield"],15,false),"-15% for enemies flame resistance!",5,5],
	9: ["flames_speed",+get_percentage(Global.stats["flames_speed"],25,false),"+25% speed for your flames!",4,4],
	10: ["flames_size",+get_percentage(Global.stats["flames_size"],25,false),"+25% size for your flames!",5,5],
	11: ["defense",-get_percentage(Global.stats["defense"],12.5,false),"+12.5% defense for you!",3,0]
}
#WHEN YOU ADD A NEW UPGRADE UPDATE THE update_upgrades() SO THAT IT SAVES THE AMOUNT IT WAS USED
#ALSO IF THERE ISN'T ICON ASSOCIATED IT WILL JUST BE null
#YOU MADE THAT BTW
var upgrades_icons = {
	1: preload("res://Assets/Upgrades Icons/Untitled_01-12-2023_10-47-58_1_1.png"),
	2: preload("res://Assets/Upgrades Icons/Untitled_01-12-2023_10-47-58_5.png"),
	3: preload("res://Assets/Upgrades Icons/Untitled_01-12-2023_10-47-58.png"),
	4: preload("res://Assets/Upgrades Icons/Untitled_01-12-2023_10-47-58_1.png"),
	5: preload("res://Assets/Upgrades Icons/Untitled_01-12-2023_10-47-58_2.png"),
	6: preload("res://Assets/Upgrades Icons/Untitled_01-12-2023_10-47-58_3.png"),
	7: preload("res://Assets/Upgrades Icons/Untitled_01-12-2023_10-47-58_8.png"),
	8: preload("res://Assets/Upgrades Icons/Untitled_01-12-2023_10-47-58_6.png"),
	9: preload("res://Assets/Upgrades Icons/Untitled_01-12-2023_10-47-58_1_3.png"),
	10: preload("res://Assets/Upgrades Icons/Untitled_01-12-2023_10-47-58_1_2.png"),
	11: preload("res://Assets/Upgrades Icons/Untitled_01-12-2023_10-47-58_4.png")
}	

var selected_button = null
var selected_upgrades = []
onready var rng = RandomNumberGenerator.new()

func _ready():
	set_defaults()
	set_upgrades_correctly()
	update_upgrades()
	
func initiate_upgrade(upgrade):
	upgrades[upgrade][4] += 1
	if upgrade == 1:
		if Global.player.weapon != "Shotgun":
			if Global.stats["player_bullets"].size() == 1:
				Global.stats["player_bullets"].append(0.2)
			elif Global.stats["player_bullets"].size() == 2:
				Global.stats["player_bullets"].append(-0.2)
			elif Global.stats["player_bullets"].size() == 3:
				Global.stats["player_bullets"].append(0.2)
			elif Global.stats["player_bullets"].size() == 4:
				Global.stats["player_bullets"].append(-0.2)
		else:
			if Global.stats["shotty_bullet_upgrades"] < 3:
				Global.stats["shotty_bullet_upgrades"] += 1
				for thing in Global.player.get_node("GunRoot").get_node("Gun").bullets_rotations_rand:
					thing.append(0.0)
	else:
		if upgrade != 2:
			Global.stats[upgrades[upgrade][0]] += upgrades[upgrade][1]
			update_upgrades()
		else:
			Global.stats[upgrades[upgrade][0]] += upgrades[upgrade][1]
			Global.player_max_health += get_percentage(Global.player_max_health,20,false)
			update_upgrades()

func option_selected():
	for option in $Options.get_children():
		if option != selected_button:
			option.pressed = false

func roll_upgrades():
	selected_upgrades = []
	var number_of_active = 0
	var how_many_to_get = 3
	for upgrade in upgrades:
		if upgrades[upgrade][4] < upgrades[upgrade][3]:
			number_of_active += 1
	if number_of_active >= 3:
		how_many_to_get = 3
	elif number_of_active == 2:
		how_many_to_get = 2
	elif number_of_active == 1:
		how_many_to_get = 1
	elif number_of_active == 0:
		how_many_to_get = 0
	rng.randomize()
	if how_many_to_get != 0:
		while selected_upgrades.size() < how_many_to_get:
			var random_upgrade = rng.randi_range(1,upgrades.size())
			if upgrades[random_upgrade][4] < upgrades[random_upgrade][3]:
				if !selected_upgrades.has(random_upgrade):
					selected_upgrades.append(random_upgrade)
		display_upgrades()
	else:
		$Error.show()
		$Continue.disabled = false
		$Continue.show()

func display_upgrades():
	for upgrade in range(selected_upgrades.size()):
		var option = upgrade + 1
		get_node("Options/Option" + str(option)).show()
		get_node("Options/Option" + str(option)).get_node("Description").text = upgrades[selected_upgrades[upgrade]][2]
		get_node("Options/Option" + str(option)).get_node("Remaining").text = "REMAINING: " + str(upgrades[selected_upgrades[upgrade]][3] - upgrades[selected_upgrades[upgrade]][4])
		get_node("Options/Option" + str(option)).text = str(selected_upgrades[upgrade])
		if upgrades_icons.has(int(get_node("Options/Option" + str(option)).text)):
			get_node("Options/Option" + str(option)).get_node("Icon").get_node("IconTexture").texture = upgrades_icons[int(get_node("Options/Option" + str(option)).text)]
		else:
			get_node("Options/Option" + str(option)).get_node("Icon").get_node("IconTexture").texture = null
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property($Options,"rect_scale",Vector2(1,1),0.5)
	tween.parallel().tween_property($Options.get_material(),"shader_param/cutoff",0.0,0.9)
	yield(tween,"finished")
	$Continue.disabled = false
	$Continue.show()

func get_percentage(from,perc,should_round = true):
	if should_round:
		return round(float(perc)/100.0 * from)
	else:
		return float(perc)/100.0 * from

func set_upgrades_correctly():
	if player_weapon == "Flamethrower":
		upgrades[5][4] = 5
		upgrades[9][4] = 0
		upgrades[1][4] = 2
		upgrades[8][4] = 0
		upgrades[10][4] = 0
		upgrades[4][4] = 5
	if player_weapon == "Sniper":
		upgrades[7][4] = 0
		upgrades[1][4] = 2
	#if player_weapon == "Musket":
		#upgrades[1][4] = 2

func set_defaults():
	self.modulate = Color(1,1,1,0)
	$Options.rect_scale = Vector2(1,0)
	$Options.get_material().set("shader_param/cutoff",1.0)
	$Continue.hide()
	$Error.hide()
	for child in $Options.get_children():
		child.hide()
		child.get_node("Icon").get_node("IconTexture").texture = null

func _on_Continue_pressed():
	if selected_button != null:
		$Continue.disabled = true
		initiate_upgrade(int(selected_button.text))
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self,"modulate",Color(1,1,1,0),0.4)
		yield(tween,"finished")
		self.hide()
		get_tree().paused = false
		set_defaults()
		Global.emit_signal("pick_up_collected")
	elif $Error.visible:
		$Continue.disabled = true
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self,"modulate",Color(1,1,1,0),0.4)
		yield(tween,"finished")
		self.hide()
		get_tree().paused = false
		set_defaults()

func update_upgrades():
	#LOOK AT THE 4th ARGUMENT TO UNDERSTAND
	upgrades = {
		1: ["player_bullets",0,"+1 bullet to your gun!",2,upgrades[1][4]],
		2: ["player_health",+get_percentage(Global.stats["player_health"],20),"+20% health for you!",5,upgrades[2][4]],
		3: ["player_damage",+get_percentage(Global.stats["player_damage"],25),"+25% damage to your gun!",5,upgrades[3][4]],
		4: ["player_firerate",-get_percentage(Global.stats["player_firerate"],7.5,false),"+7.5% firerate to your gun!",5,upgrades[4][4]],
		5: ["player_crit_chance",+0.075,"+7.5% for getting a crit!",5,upgrades[5][4]],
		6: ["player_speed",+get_percentage(Global.stats["player_speed"],20),"+20% speed for you!",5,upgrades[6][4]],
		7: ["sniper_health",+1,"your bullets can go through 1 more enemy!",3,upgrades[7][4]],
		8: ["flames_shield",-get_percentage(Global.stats["flames_shield"],15,false),"-15% for enemies flame resistance!",5,upgrades[8][4]],
		9: ["flames_speed",+get_percentage(Global.stats["flames_speed"],25,false),"+25% speed for your flames!",4,upgrades[9][4]],
		10: ["flames_size",+get_percentage(Global.stats["flames_size"],25,false),"+25% size for your flames!",5,upgrades[10][4]],
		11: ["defense",-get_percentage(Global.stats["defense"],12.5,false),"+12.5% defense for you!",3,upgrades[11][4]]
	}
