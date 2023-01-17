extends Area2D

var message_label = null
var key = 0
var color = null
var shadow_color = null
var pick_ups = {
#PLAYER PLAYER PLAYER PLAYER PLAYER

#player bullet amount
1: ["player_bullets",0,"+1 bullet to your gun!","green",true],
2: ["player_bullets",0,"+1 bullet to your gun!","green",true],
3: ["player_bullets",0,"+1 bullet to your gun!","green",true],
4: ["player_bullets",0,"+1 bullet to your gun!","green",true],
#FRENZY
5: ["start_frenzy",0,"FRENZY! FRENZY! FRENZY!","green",true],
#player health
6: ["player_health",+15,"+15 health for you!","green",true],
7: ["player_health",+20,"+20 health for you!","green",true],
8: ["player_health",+25,"+25 health for you!","green",true], 
9: ["player_health",+30,"+30 health for you!","green",true],
#player damage
10: ["player_damage",+get_percentage(Global.stats["player_damage"],10),"+ " + str(get_percentage(Global.stats["player_damage"],10)) + " damage to your gun!","green",true],
11: ["player_damage",+get_percentage(Global.stats["player_damage"],15),"+ " + str(get_percentage(Global.stats["player_damage"],15)) + " damage to your gun!","green",true],
12: ["player_damage",+get_percentage(Global.stats["player_damage"],20),"+ " + str(get_percentage(Global.stats["player_damage"],20)) + " damage to your gun!","green",true],
#player speed
13: ["player_speed",+get_percentage(Global.stats["player_speed"],5),"+ " + str(get_percentage(Global.stats["player_speed"],5)) + " speed for you!","green",true],
14: ["player_speed",+get_percentage(Global.stats["player_speed"],7.5),"+ " + str(get_percentage(Global.stats["player_speed"],7.5)) + " speed for you!","green",true],
15: ["player_speed",+get_percentage(Global.stats["player_speed"],10),"+ " + str(get_percentage(Global.stats["player_speed"],10)) + " speed for you!","green",true], 
#player firerate
16: ["player_firerate",-get_percentage(Global.stats["player_firerate"],10,false),"+ " + str(get_percentage(Global.stats["player_firerate"],10,false)) + " firerate for your gun!","green",true],
#player crit chance
17: ["player_crit_chance",+0.05,"bigger % of a critical for you!","green",true],
#flamethrower updates
18: ["flames_shield",-get_percentage(Global.stats["flames_shield"],5,false),"-5% for enemies flame invincibility!","green",true],
19: ["flames_shield",-get_percentage(Global.stats["flames_shield"],7.5,false),"-7.5% for enemies flame invincibility!","green",true],
20: ["flames_shield",-get_percentage(Global.stats["flames_shield"],10,false),"-10% for enemies flame invincibility!","green",true],
21: ["flames_speed",+get_percentage(Global.stats["flames_speed"],15,false),"+ " + str(get_percentage(Global.stats["flames_speed"],15,false)) + " speed for your flames!","green",true],
#sniper upgrade
22: ["sniper_health",+1,"Bullets can go through 1 more enemy!","green",false],
#ENEMIES ENEMIES ENEMIES ENEMIES ENEMIES

#enemy health
23:["enemy_health",+get_percentage(Global.stats["enemy_health"],15),"+ " + str(get_percentage(Global.stats["enemy_health"],15)) + " health for your enemies!","red",true],
24:["enemy_health",+get_percentage(Global.stats["enemy_health"],20),"+ " + str(get_percentage(Global.stats["enemy_health"],20)) + " health for your enemies!","red",true],
25:["enemy_health",+get_percentage(Global.stats["enemy_health"],25),"+ " + str(get_percentage(Global.stats["enemy_health"],25)) + " health for your enemies!","red",true],
#enemy damage
26:["enemy_damage",+get_percentage(Global.stats["enemy_damage"],5),"+ " + str(get_percentage(Global.stats["enemy_damage"],5)) + " damage for your enemies!","red",true],
27:["enemy_damage",+get_percentage(Global.stats["enemy_damage"],10),"+ " + str(get_percentage(Global.stats["enemy_damage"],10)) + " damage for your enemies!","red",true],
#enemy speed
28:["enemy_speed",+get_percentage(Global.stats["enemy_speed"],5),"+ " + str(get_percentage(Global.stats["enemy_speed"],5)) + " speed for your enemies!","red",true],
29:["enemy_speed",+get_percentage(Global.stats["enemy_speed"],10),"+ " + str(get_percentage(Global.stats["enemy_speed"],10)) + " speed for your enemies!","red",true],
}

var special_keys = [1,2,3,4,5]

func _ready():
	Global.player.should_show_arrow = true
	check_for_disabled()
	randomize()
	var key_check = int(rand_range(1,29))
	if pick_ups[key_check][4] == true:
		key = key_check
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self,"scale",Vector2(0.8,0.8),0.3)
	else:
		_ready()

func _on_Pickup_body_entered(body):
	Global.player.should_show_arrow = false
	set_deferred("monitoring",false)
	Global.pick_ups += 1
	randomize()
#	if Global.stats["player_bullets"].size() < 3:
#		key = int(rand_range(1,28))
#	else:
#		key = int(rand_range(5,28))
	
	get_the_color_and_set(key)
	if !key in special_keys:
		Global.stats[pick_ups[key][0]] += pick_ups[key][1]
	elif key == 1 or key == 2 or key == 3 or key == 4:
		if Global.player.weapon != "Shotgun":
			if Global.stats["player_bullets"].size() == 1:
				Global.stats["player_bullets"].append(0.2)
			elif Global.stats["player_bullets"].size() == 2:
				Global.stats["player_bullets"].append(-0.2)
		else:
			if Global.stats["shotty_bullet_upgrades"] < 3:
				Global.stats["shotty_bullet_upgrades"] += 1
				for thing in Global.player.get_node("GunRoot").get_node("Gun").bullets_rotations_rand:
					thing.append(0.0)
	elif key == 5:
		Global.emit_signal("frenzy_start")
	Global.emit_signal("pick_up_collected")
	if message_label != null:
		message_label.message_popup(pick_ups[key][2],color,shadow_color)
	$picked_up.play()
	yield($picked_up,"finished")
	queue_free()


func _on_diss_timeout():
	#Global.player.should_show_arrow = false
	$CollisionShape2D.disabled = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"scale",Vector2(0,0),0.3)
	yield(tween,"finished")
	queue_free()

func get_the_color_and_set(the_key):
	if "red" in pick_ups[the_key][3]:
		color = Color("e6143b")
		shadow_color = Color("670b2b")
	else:
		color = Color("51e614")
		shadow_color = Color("2b5412")

func check_for_disabled():
	if Global.stats["player_bullets"].size() >= 3 or Global.player.weapon == "Flamethrower" or Global.stats["shotty_bullet_upgrades"] >= 3 or Global.player.weapon == "Sniper":
		pick_ups[1][4] = false
		pick_ups[2][4] = false
		pick_ups[3][4] = false
		pick_ups[4][4] = false
	if Global.stats["player_crit_chance"] >= 0.5 or Global.player.weapon == "Flamethrower":
		pick_ups[17][4] = false
	if Global.stats["player_firerate"] <= Global.max_fire_rate or Global.frenzy_on:
		pick_ups[16][4] = false
	if Global.frenzy_on:
		pick_ups[5][4] = false
	if Global.player.weapon != "Flamethrower":
		pick_ups[18][4] = false
		pick_ups[19][4] = false
		pick_ups[20][4] = false
		pick_ups[21][4] = false
	if Global.player.weapon == "Flamethrower":
		if Global.stats["flames_shield"] <= Global.min_shield_time:
			pick_ups[18][4]=false
			pick_ups[19][4]=false
			pick_ups[20][4]=false
		if Global.stats["flames_speed"] >= Global.max_flame_speed:
			pick_ups[21][4]=false
	if Global.player.weapon == "Sniper":
		pick_ups[22][4]=true
func get_percentage(from,perc,should_round = true):
	if should_round:
		return round(float(perc)/100.0 * from)
	else:
		return float(perc)/100.0 * from
