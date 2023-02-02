extends KinematicBody2D

var stun = false
var total_damage_got = 0
var sprite_size_x = 0
var should_get_damaged_by_flames = true
var should_change_speed = true
var burning = false
var velocity = Vector2()
var killed_before = false

var crack = preload("res://Scenes/Crack.tscn")
var bullet = preload("res://Scenes/BigAxeGuyProjectile.tscn")
var bullet_2 = preload("res://Scenes/BigAxeGuyProjectile2.tscn")
var damage_popup = preload("res://Scenes/NumberPopup.tscn")

var max_health = 50000
var health = 50000
var speed = 50
var money_reward = 300
var damage_recieved_multiplier = 1.0

var number_of_slashes = 0
var player = null
var ui = null

var unlocked_attacks = [
	State.TRIPLE_AXE
]

enum State{
	IDLE,
	WALKING,
	TRIPLE_AXE,
	NULL,
	SCYTHE_ATTACK,
	SKULL_SUMMON,
}
var current_state = State.IDLE
var num_of_attacks = 0

func _ready():
	max_health = health
	player = Global.player
	ui = player.ui
	sprite_size_x = $Sprite.scale.x
	killed_before = Global.settings["unlocked_chapter_parts"].has(1.4)
	
func _physics_process(delta):
	randomize()
	var direction_to_player = Vector2(player.global_position - global_position)
	rotate_to_face_player(direction_to_player)
	var distance = global_position.distance_to(player.global_position)
	match current_state:
		State.IDLE:
			$Sprite.speed_scale = 1
			num_of_attacks = 0
			damage_recieved_multiplier = 1.0
			velocity = Vector2.ZERO
			#WHEN YOU ADD ANIMATION CHANGE
			$Sprite.play("Idle")
			if $TimerTillWalk.is_stopped():
					$TimerTillWalk.start()
		State.WALKING:
			$Sprite.speed_scale = float(speed)/50.0
			num_of_attacks = 0
			damage_recieved_multiplier = 1.0
			if player != null:
				if $TimerTillAttack.is_stopped():
					$TimerTillAttack.start(rand_range(4,5))
				#WHEN YOU ADD ANIMATION CHANGE
				$Sprite.play("Walk")
				velocity = direction_to_player.normalized() * speed
		State.TRIPLE_AXE:
			damage_recieved_multiplier = 1.0
			$Sprite.speed_scale = 1
			velocity = Vector2.ZERO
			if $BetweenAttacks.is_stopped():
				$BetweenAttacks.start(get_random_time())
		State.NULL:
			damage_recieved_multiplier = 1.0
			$Sprite.speed_scale = 1
			velocity = Vector2.ZERO
		State.SCYTHE_ATTACK:
			damage_recieved_multiplier = 1.0
			$Sprite.speed_scale = 1
			velocity = Vector2.ZERO
			if $TimerTillScythes.is_stopped() and $Sprite.animation != "AxeAttack":
				$Sprite.play("AxeAttack")
				$TimerTillScythes.start()
			if $TimerTillSkulls.is_stopped():
				$TimerTillSkulls.start(get_random_time_skulls())
		State.SKULL_SUMMON:
			damage_recieved_multiplier = 0.4
			$Sprite.speed_scale = 1
			velocity = Vector2.ZERO
			if $SkullSummonningPeriod.is_stopped() and $Sprite.animation != "SkullSummon":
				$Sprite.play("SkullSummon")
				$TimerTillSkulls.start()
				$OneSkullSummon.start(get_random_time_one_skull())
				$SkullSummonningPeriod.start()
				show_portal()
	move_and_slide(velocity,Vector2.UP)
	var overlapping_bodies = $Hitbox.get_overlapping_bodies()
	for i in overlapping_bodies:
		if stun == false:
			i.health -= 1
			i.queue_free()
			if i.critical:
				take_damage(i.damage,true,true)
			elif !i.critical:
				if stun == false:
					take_damage(i.damage,false,true)

func take_damage(how_much,critical,knockback=true):
	how_much = round(float(how_much) * damage_recieved_multiplier)
	total_damage_got += how_much
	$damage.start()
	randomize()
	health -= how_much
	check_hp_and_possibly_add_attack()
	var tween = create_tween()
	tween.tween_property($Sprite.get_material(),"shader_param/flash_modifier",1.0,0.05)
	tween.tween_property($Sprite.get_material(),"shader_param/flash_modifier",0.0,0.05)
	if health > 0:
		$hurt.pitch_scale = rand_range(0.8,1)
		$hurt.play()
		if health <=0:
			health = 0
			$death.pitch_scale = rand_range(0.8,1)
			$death.play()
			ui.boss_dead([1.4])
			append_unlocked([1.4])
			yield(tween,"finished")
			queue_free()
			Global.emit_signal("money_picked_up",round(money_reward * Global.stats["player_earnings"]))
			Global.enemies_killed += 1
			grant_ruby()
	elif health <= 0:
		health = 0
		$death.pitch_scale = rand_range(0.8,1)
		$death.play()
		ui.boss_dead([1.4])
		append_unlocked([1.4])
		yield(tween,"finished")
		queue_free()
		Global.emit_signal("money_picked_up",round(money_reward * Global.stats["player_earnings"]))
		Global.enemies_killed += 1
		grant_ruby()
	yield(tween,"finished")
	stun = false

func append_unlocked(which_parts_to_add = null):
	if which_parts_to_add != null:
		for part in which_parts_to_add:
			if !part in Global.settings["unlocked_chapter_parts"]:
				Global.settings["unlocked_chapter_parts"].append(part)

func grant_ruby():
	if !killed_before:
		Global.settings["rubys"] += 30
		Global.emit_signal("ruby_collected",30)
	elif killed_before:
		Global.settings["rubys"] += 3
		Global.emit_signal("ruby_collected",3)

func rotate_to_face_player(dir):
	if dir.x > 0:
		$Sprite.scale.x = lerp($Sprite.scale.x,-sprite_size_x,0.27)
	else:
		$Sprite.scale.x = lerp($Sprite.scale.x,sprite_size_x,0.27)

func change_state(next_state):
	current_state = next_state
	if next_state == State.TRIPLE_AXE:
		$Sprite.play("Idle")

func burn(time,tick,damage_per_tick):
	$burn_timer.start(time)
	if $burn_tick.is_stopped():
		$burn_tick.start(tick)
	burning = true
	$FlameParticles.emitting = true

func _on_TimerTillWalk_timeout():
	change_state(State.WALKING)


func _on_damage_timeout():
	var number = 100.0 - ((max_health-float(total_damage_got))/max_health)*100.0#100.0 - ((11750.0-float(total_damage_got))/11750.0)*100.0
	ui.update_boss_health(number)
	var num_popup = damage_popup.instance()
	num_popup.position = self.position
	num_popup.amount = "-" + str(total_damage_got)
	num_popup.type = "White"
	get_tree().current_scene.call_deferred("add_child",num_popup)
	total_damage_got = 0


func _on_flames_shield_timeout():
	should_get_damaged_by_flames = true

func _on_time_to_catch_on_fire_timeout():
	burn(5,1,5)

func _on_burn_tick_timeout():
	if burning:
		var damage = round(float(max_health)*0.004)
		if damage > 75:
			damage = 75
		take_damage(damage,false,false)
	else:
		$burn_tick.stop()

func _on_burn_timer_timeout():
	should_change_speed = true
	burning = false
	$FlameParticles.emitting = false


func _on_Hitbox_area_entered(area):
	if area.name == "FlameAffection":
		area.call_deferred("set_monitorable",false)
		area.call_deferred("set_monitoring",false)
		if should_get_damaged_by_flames:
			take_damage(area.get_parent().damage,false,false)
			burn(5,1,5)
			should_get_damaged_by_flames = false
			if $flames_shield.is_stopped():
				$flames_shield.start(Global.stats["flames_shield"]/2)


func _on_Hitbox_area_exited(area):
	if area.name == "FlameAffection":
		area.call_deferred("set_monitorable",true)
		area.call_deferred("set_monitoring",true)

func instance_bullets():
	randomize()
	spawn_crack()
	var chance = randf()*100
	var rots = []
	if chance < 50.0:
		rots = [-0.4,-0.2,0.0,0.2,0.4]
	else:
		rots = [-0.2,0.0,0.2]
	for rot in rots:
		var bullet_inst = bullet.instance()
		bullet_inst.rotation = get_angle_to(player.position) + rot
		bullet_inst.position = $Sprite/BulletSpawnPoint.global_position
		get_tree().current_scene.get_node("Enemies").add_child(bullet_inst)

func instance_scythes():
	randomize()
	spawn_crack()
	var rots = [-0.9,-0.6,-0.3,0.0,0.3,0.6,0.9]
	for rot in rots:
		var bullet_inst = bullet_2.instance()
		bullet_inst.rotation = get_angle_to(player.position) + rot
		bullet_inst.position = $Sprite/ScythesSpawnPoint.global_position
		get_tree().current_scene.get_node("Enemies").add_child(bullet_inst)

func _on_TimerTillAttack_timeout():
	var RNG = RandomNumberGenerator.new()
	RNG.randomize()
	var attack = unlocked_attacks[RNG.randi_range(0,unlocked_attacks.size()-1)]
	change_state(attack)

func _on_BetweenAttacks_timeout():
	#WHEN YOU ADD ANIMATION CHANGE
	if num_of_attacks < 3:
		$TimerTillBullets.start()
		$Sprite.play("Idle")
		$Sprite.play("AxeAttack")
		#instance_bullets()
		num_of_attacks += 1
		print("attacking")
		#$BetweenAttacks.start(get_random_time())
	else:
		change_state(State.WALKING)
		num_of_attacks = 0
		$BetweenAttacks.stop()
		$TimerTillBullets.stop()

func get_random_time():
	var chance = randf()*100
	var time = 0
	if chance > 75.0:
		time = 1.5
	elif chance < 75.0 and chance > 20.0:
		time = 1.35
	elif chance < 20.0:
		time = 1.2
	return time

func _on_Sprite_animation_finished():
	if $Sprite.animation == "AxeAttack":
		if current_state == State.TRIPLE_AXE:
			$BetweenAttacks.start(get_random_time())
		else:
			change_state(State.WALKING)

func _on_TimerTillBullets_timeout():
	instance_bullets()

func spawn_crack():
	var crack_inst = crack.instance()
	crack_inst.global_position = $Sprite/BulletSpawnPoint.global_position
	crack_inst.scale.x = rand_range(0.8,0.95)
	crack_inst.scale.y = crack_inst.scale.x
	crack_inst.rotation_degrees = rand_range(-360,360)
	get_tree().current_scene.add_child(crack_inst)

func add_attack(attack):
	if !attack in unlocked_attacks:
		print("adding at attack")
		unlocked_attacks.append(attack)

func check_hp_and_possibly_add_attack():
	if health < int(float(max_health) * 0.9):
		add_attack(State.SCYTHE_ATTACK)
	if health < int(float(max_health) * 0.5):
		add_attack(State.SKULL_SUMMON)

func _on_TimerTillScythes_timeout():
	instance_scythes()

func instance_skulls():
	randomize()
	var chance = randf()*100
	var the_path = null
	if chance > 25.0:
		the_path = $SkullsPath
	elif chance < 25.0 and chance > 10.0:
		the_path = $SkullsPath2
	elif chance < 10.0:
		the_path = $SkullsPath3
	for point in the_path.curve.get_point_count():
		var bullet_inst = bullet.instance()
		var position_of_point = the_path.curve.get_point_position(point)
		bullet_inst.sprite = "Skull"
		bullet_inst.damage = 40
		bullet_inst.rotation = position_of_point.angle()
		bullet_inst.global_position = position_of_point + the_path.global_position
		get_tree().current_scene.get_node("Enemies").add_child(bullet_inst)

func get_random_time_skulls():
	var chance = randf()*100
	var time = 0
	if chance > 25.0:
		time = 1
	elif chance <= 25.0:
		time = 0.8
	return time

func get_random_time_one_skull():
	var chance = randf()*100
	var time = 0
	if chance > 25.0:
		time = 0.33
	elif chance <= 25.0 and chance > 10.0:
		time = 0.25
	elif chance <=10.0:
		time = 0.2
	return time

func _on_SkullSummonningPeriod_timeout():
	change_state(State.WALKING)
	show_portal()

func _on_TimerTillSkulls_timeout():
	if current_state == State.SKULL_SUMMON:
		instance_skulls()
		$TimerTillSkulls.start(get_random_time_skulls())

func show_portal():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	if $ThePortal.modulate == Color(1,1,1,0):
		tween.tween_property($ThePortal,"modulate",Color(1,1,1,1),0.4)
		$ThePortalParticles.emitting = true
	elif $ThePortal.modulate == Color(1,1,1,1):
		tween.tween_property($ThePortal,"modulate",Color(1,1,1,0),0.4)
		$ThePortalParticles.emitting = false

func instance_one_skull():
	var bullet_inst = bullet.instance()
	bullet_inst.damage = 45
	bullet_inst.sprite = "Skull"
	bullet_inst.modulate = Color("ff9a9a")
	get_tree().current_scene.get_node("Enemies").add_child(bullet_inst)
	bullet_inst.position = $SkullsPath.global_position
	bullet_inst.look_at(player.global_position)
	bullet_inst.set_stuff()

func _on_OneSkullSummon_timeout():
	if current_state == State.SKULL_SUMMON:
		$OneSkullSummon.start(get_random_time_one_skull())
		instance_one_skull()
