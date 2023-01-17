extends KinematicBody2D

var max_health = 11750
var health = 11750
var stun = false

onready var attack_path = get_node("Path1")

var rock = preload("res://Scenes/BossRock.tscn")
var bullet = preload("res://Scenes/BossProjectile.tscn")
var damage_popup = preload("res://Scenes/NumberPopup.tscn")
var crack_texture = preload("res://Assets/Boss/Crack_.png")
var ashes = preload("res://Scenes/BloodParticlesButAshes.tscn")
var player = null
var ui = null

var killed_before = false
var money_reward = 100
var previous_attack = "Attack1"
var velocity = Vector2()
var speed = 50
var sprite_size_x = 0
var should_change_speed = true
var total_damage_got = 0
var should_get_damaged_by_flames = true
var burning = false
var previous_speed = speed
var previous_player_spot = null
var phase_2_entered = false
var previous_speed_2 = speed

enum State{
	IDLE,
	WALKING,
	ATTACKING,
	READING_UP,
	FLYING,
	SMASH_ATTACK,
	BOULDER_THROW,
	ATTACKING_PURPLE,
}

var current_state = State.IDLE
var bullet_rots = [-0.2,-0.1,0,0.1,0.2]

func _ready():
	killed_before = Global.settings["beat_gorilla"]
	sprite_size_x = $Sprite.scale.x
	player = Global.player
	ui = player.ui
	max_health = health

func _physics_process(delta):
	var direction_to_player = Vector2(player.global_position - global_position)
	rotate_to_face_player(direction_to_player)
	var distance = global_position.distance_to(player.global_position)
	match current_state:
		State.IDLE:
			$Sprite.speed_scale = 1
			velocity = Vector2.ZERO
			$Sprite.play("Idle")
			if $TimerTillWalk.is_stopped():
					$TimerTillWalk.start()
		State.WALKING:
			$Sprite.speed_scale = float(speed)/50.0
			if player != null:
				if $TimerTillAttack.is_stopped():
					$TimerTillAttack.start(rand_range(4,5))
				$Sprite.play("Walk")
				velocity = direction_to_player.normalized() * speed
		State.ATTACKING:
			$Sprite.speed_scale = 1
			velocity = Vector2.ZERO
			previous_attack = "Attack1"
			if $AttackTimer.is_stopped():
				$AttackTimer.start()
			$Sprite.play("Attack1")
		State.ATTACKING_PURPLE:
			$Sprite.speed_scale = 1
			velocity = Vector2.ZERO
			previous_attack = "Attack3"
			if $AttackTimer2.is_stopped():
				$AttackTimer2.start()
			$Sprite.play("Attack3")
		State.READING_UP:
			$Sprite.speed_scale = 1
			velocity = Vector2.ZERO
			if $ReadingUp.is_stopped():
				$ReadingUp.start()
			$Sprite.play("BeforeJump")
		State.SMASH_ATTACK:
			$Sprite.speed_scale = 1
			velocity = Vector2.ZERO
			previous_attack = "SlamAttack"
			$Sprite.play("Attack2")
		State.FLYING:
			$Sprite.speed_scale = 1
			if previous_player_spot.x > 0:
				$Sprite.scale.x = -0.299
			else:
				$Sprite.scale.x = 0.299
			velocity = Vector2(previous_player_spot - global_position).normalized() * 200
			velocity.y -= 50
			$Sprite.play("Jump")
		State.BOULDER_THROW:
			$Sprite.speed_scale = 1
			velocity = Vector2.ZERO
			if $boulder_throw.is_stopped():
				$boulder_throw.start()
			$Sprite.play("BoulderThrow")
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

func rotate_to_face_player(dir):
	if dir.x > 0:
		$Sprite.scale.x = lerp($Sprite.scale.x,-sprite_size_x,0.27)
	else:
		$Sprite.scale.x = lerp($Sprite.scale.x,sprite_size_x,0.27)

func change_state(next_state):
	current_state = next_state

func _on_TimerTillAttack_timeout():
	var rng = RandomNumberGenerator.new()
	if health <= 11750.0 * 0.75 and health > 11750.0 * 0.50:
		print("attack 1,2")
		rng.randomize()
		var number = rng.randi_range(1,2)
		print(number)
		if number == 1:
			previous_attack = "Attack1"
			change_state(State.ATTACKING)
		elif number == 2:
			previous_attack = "Attack2"
			change_state(State.ATTACKING_PURPLE)
	elif health <= 11750.0 * 0.50:
		print("attack 1,2,3")
		rng.randomize()
		var number = rng.randi_range(1,3)
		attack_path = get_node("Path2")
		if number == 1:
			previous_attack = "Attack1"
			change_state(State.ATTACKING)
		elif number == 2:
			previous_attack = "Attack2"
			change_state(State.BOULDER_THROW)
		elif number == 3:
			previous_attack = "Attack3"
			change_state(State.ATTACKING_PURPLE)
	elif health > 11750.0 * 0.75:
		print("attack 1")
		previous_attack = "Attack1"
		change_state(State.ATTACKING)

func _on_AttackTimer_timeout():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var sound = rng.randi_range(1,2)
	get_node("hit" + str(sound)).pitch_scale = rng.randf_range(0.95,1.1)
	get_node("hit" + str(sound)).play()
	player.get_node("Camera2D").apply_noise_shake()
	var tween = create_tween()
	var sprite = Sprite.new()
	sprite.scale = Vector2(0.7,0.7)
	sprite.z_index = 1
	sprite.position = $Sprite/crackpoint.global_position
	sprite.texture = crack_texture
	for rot in bullet_rots:
		var bullet_inst = bullet.instance()
		bullet_inst.rotation = get_angle_to(player.position) + rot
		bullet_inst.position = $Sprite/BulletSpawnPoint.global_position
		get_tree().current_scene.get_node("Enemies").add_child(bullet_inst)
	change_state(State.WALKING)
	get_tree().current_scene.add_child(sprite)
	tween.tween_interval(2)
	tween.tween_property(sprite,"modulate",Color(1,1,1,0),1)
	yield(tween,"finished")
	sprite.queue_free()

func _on_TimerTillWalk_timeout():
	change_state(State.WALKING)

func _on_burn_timer_timeout():
	#speed = previous_speed
	should_change_speed = true
	burning = false
	$FlameParticles.emitting = false

func _on_burn_tick_timeout():
	if burning:
		var damage = round(float(max_health)*0.004)
		if damage > 75:
			damage = 75
		take_damage(damage,false,false)
	else:
		$burn_tick.stop()

func _on_time_to_catch_on_fire_timeout():
	burn(5,1,5)

func _on_flames_shield_timeout():
	should_get_damaged_by_flames = true

func _on_damage_timeout():
	var number = 100.0 - ((11750.0-float(total_damage_got))/11750.0)*100.0#100.0 - ((11750.0-float(total_damage_got))/11750.0)*100.0
	ui.update_boss_health(number)
	var num_popup = damage_popup.instance()
	num_popup.position = self.position
	num_popup.amount = "-" + str(total_damage_got)
	num_popup.type = "White"
	get_tree().current_scene.call_deferred("add_child",num_popup)
	total_damage_got = 0

func take_damage(how_much,critical,knockback=true):
	total_damage_got += how_much
	$damage.start()
	randomize()
	health -= how_much
	if health <= 11750.0 * 0.50 and phase_2_entered == false:
		phase_2_entered = true
		var tween_1 = create_tween()
		tween_1.tween_property(self,"modulate",Color("ffa5a5"),0.2)
		speed = speed + (speed*0.5)
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
			ui.boss_dead()
			Global.settings["beat_gorilla"] = true
			yield(tween,"finished")
			queue_free()
			Global.emit_signal("money_picked_up",money_reward)
			Global.enemies_killed += 1
			grant_ruby()
	elif health <= 0:
		health = 0
		$death.pitch_scale = rand_range(0.8,1)
		$death.play()
		ui.boss_dead()
		Global.settings["beat_gorilla"] = true
		yield(tween,"finished")
		queue_free()
		Global.emit_signal("money_picked_up",money_reward)
		Global.enemies_killed += 1
		grant_ruby()
	yield(tween,"finished")
	stun = false
	if health < max_health * 0.75:
		bullet_rots = [-0.3,-0.2,-0.1,0,0.1,0.2,0.3]
	if health < max_health * 0.50:
		bullet_rots = [-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4]
	if health < max_health * 0.20:
		bullet_rots = [-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5]
	
func burn(time,tick,damage_per_tick):
	#if should_change_speed:
		#should_change_speed = false
		#previous_speed = speed
		#speed = speed - speed * 0.6
	$burn_timer.start(time)
	if $burn_tick.is_stopped():
		$burn_tick.start(tick)
	burning = true
	$FlameParticles.emitting = true

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


func _on_Hitbox_body_exited(body):
	pass
#	if body.is_in_group("player_bullets"):
#		if body.ghost:
#			body.remove_ghost()

func _on_ReadingUp_timeout():
	change_state(State.FLYING)
	previous_player_spot = player.global_position

func _on_boulder_throw_timeout():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var sound = rng.randi_range(1,2)
	get_node("hit" + str(sound)).pitch_scale = rng.randf_range(0.95,1.1)
	get_node("hit" + str(sound)).play()
	var boulder_inst = rock.instance()
	boulder_inst.position = $Sprite/BulletSpawnPoint.global_position
	get_tree().current_scene.get_node("Enemies").add_child(boulder_inst)
	change_state(State.WALKING)

func _on_AttackTimer2_timeout():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var sound = rng.randi_range(1,2)
	get_node("hit" + str(sound)).pitch_scale = rng.randf_range(0.95,1.1)
	get_node("hit" + str(sound)).play()
	player.get_node("Camera2D").apply_noise_shake()
	var tween = create_tween()
	var sprite = Sprite.new()
	sprite.scale = Vector2(0.188,0.168)
	sprite.z_index = 1
	sprite.position = $Sprite/crackpoint.global_position
	sprite.texture = crack_texture
	for point in attack_path.get_curve().get_point_count():
		var bullet_inst = bullet.instance()
		bullet_inst.get_node("AnimatedSprite").hide()
		bullet_inst.get_node("AnimatedSprite2").show()
		bullet_inst.global_position = attack_path.get_curve().get_point_position(point) + position
		bullet_inst.rotation = (attack_path.get_curve().get_point_position(point) + position).angle_to_point(position)
		get_tree().current_scene.call_deferred("add_child",bullet_inst)
	change_state(State.WALKING)
	get_tree().current_scene.add_child(sprite)
	tween.tween_interval(2)
	tween.tween_property(sprite,"modulate",Color(1,1,1,0),1)
	yield(tween,"finished")
	sprite.queue_free()

func grant_ruby():
	if !killed_before:
		Global.settings["rubys"] += 30
		Global.emit_signal("ruby_collected",30)
	elif killed_before:
		Global.settings["rubys"] += 3
		Global.emit_signal("ruby_collected",3)
