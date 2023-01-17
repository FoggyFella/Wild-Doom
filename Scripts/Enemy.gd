extends KinematicBody2D

var speed : float = 50
export var damage : int = 10
export var health : int = 100
export var more_health : int = 0
export var min_money : int = 1
export var max_money : int = 3
export var min_ruby : int = 1
export var max_ruby : int = 2
export var ruby_chance: float = 0.86
export var min_speed : int = 50
export var max_speed : int = 85
export var how_much_slower: int = 10
export var min_wait : float = 2
export var max_wait : float = 4
export var bite_damage : int = 5
export var should_shoot = true
export var should_rotate = false
export var should_walk = true
export var should_knockback = true
export var should_stay_away:bool = false
export var should_dash:bool = false
export var dash_speed:float = 30
export var should_have_fritcion:bool = false
export var acceleration:float = 0.0
export var friction:float = 0.0
export var should_fully_stop:bool = false

var should_run = false
var previous_speed = speed
var previous_damage = damage
var previous_direction = Vector2.ZERO
var burning = false
var money_reward = 0
var stun = false
var can_shoot = true
var direction_to_player = Vector2()
var player = null
var is_visisble = false
var velocity = Vector2.ZERO
var should_change_speed = true
var can_dash = false

var max_health = 0
var dash_ghost = preload("res://Scenes/DashGhost.tscn")
var bullet = preload("res://Scenes/enemy_bullet.tscn")
var blood = preload("res://Scenes/BloodParticles.tscn")
var damage_popup = preload("res://Scenes/NumberPopup.tscn")
var ashes = preload("res://Scenes/BloodParticlesButAshes.tscn")
var can_bite = true
var sprite_size_x = null
var normal_speed = 0

onready var time_to_catch_on_fire = $time_to_catch_on_fire

var total_damage_got = 0
var should_get_damaged_by_flames = true
var ruby_percentages = [1.0,0.0]

func _ready():
	randomize()
	money_reward = int(rand_range(min_money,max_money))
	sprite_size_x = $Sprite.scale.x
	health = Global.stats["enemy_health"] + more_health
	max_health = health
	$TextureProgress.max_value = health
	$TextureProgress.value = health
	scale.x = rand_range(0.8,1)
	scale.y = scale.x
	ruby_percentages = [1.0-ruby_chance,ruby_chance]
	if should_walk:
		speed = Global.stats["enemy_speed"] + rand_range(min_speed,max_speed)
		normal_speed = speed
	else:
		speed = 0
	player = Global.player
	if should_dash:
		$timebetweendashes.start(rand_range(6,8))
	
func _physics_process(delta):
	var overlapping_bodies = $Hitbox.get_overlapping_bodies()
	for i in overlapping_bodies:
		if i.is_in_group("player_bullets"):
			if stun == false:
				i.health -= 1
				if i.health <= 0:
					i.call_deferred("queue_free")
				else:
					i.call_deferred("become_ghost")
				if i.critical:
					take_damage(i.damage,true,i.should_knockback,i.should_show_total_dmg)
				elif !i.critical:
					if stun == false:
						take_damage(i.damage,false,i.should_knockback,i.should_show_total_dmg)
#			elif i.is_flamethrower:
#				burn(5,1,5)
	if player == null:
		queue_free()
	if player != null and stun == false:
		if !should_run and !should_have_fritcion:
			direction_to_player = Vector2(player.global_position - global_position)
			velocity = direction_to_player.normalized() * speed if !is_dashing() else previous_direction * dash_speed
			move_and_slide(velocity,Vector2.UP)
		elif should_run and !Global.player.velocity == Vector2.ZERO and !should_have_fritcion:
			direction_to_player = Vector2(player.global_position - global_position)
			velocity = velocity.linear_interpolate(-direction_to_player.normalized() * speed,0.1)
			move_and_slide(velocity,Vector2.UP)
		elif should_have_fritcion:
			direction_to_player = Vector2(player.global_position - global_position)
			var desired_velocity = direction_to_player.normalized() * speed if !is_dashing() else previous_direction * dash_speed
			var steering = (desired_velocity - velocity) * delta if !is_dashing() else (desired_velocity - velocity) * delta * 10.0
			velocity += steering
			move_and_slide(velocity,Vector2.UP)
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision != null:
				if collision.get_collider().name == "Player":
					if collision.get_collider().has_method("take_damage"):
						if can_bite:
							can_bite = false
							$bite_timer.start()
							collision.get_collider().take_damage(bite_damage)
		if direction_to_player.x < 0:
			if should_rotate:
				$Sprite.rotation_degrees = lerp($Sprite.rotation_degrees,-8.9,0.05)
			if !is_dashing():
				$Sprite.scale.x = lerp($Sprite.scale.x,-sprite_size_x,0.27)
		else:
			if should_rotate:
				$Sprite.rotation_degrees = lerp($Sprite.rotation_degrees,8.9,0.05)
			if !is_dashing():
				$Sprite.scale.x = lerp($Sprite.scale.x,sprite_size_x,0.27)
		if can_shoot and is_visisble:
			if should_shoot:
				shoot()
		if can_dash and should_dash:
			start_dash()
func shoot():
	if $timer2.is_stopped():
		previous_speed = speed
		if !should_fully_stop:
			speed -= 40
		else:
			speed = 0
		$AnimationPlayer.play("new_shoot")
		$timer2.start()
#	$shoot.pitch_scale = rand_range(0.7,0.9)
#	$shoot.play()
#	can_shoot = false
#	$reload.start(rand_range(min_wait,max_wait))
#	var bullet_inst = bullet.instance()
#	bullet_inst.global_position = $Position2D.global_position
#	get_tree().root.add_child(bullet_inst)
#	bullet_inst.player = player
#	bullet_inst.damage = damage
#	bullet_inst.direction_to_player = direction_to_player
#	bullet_inst.lock_on = true
	#bullet_inst.look_at(player.global_position)

func take_damage(how_much,critical,knockback=true,show_total=false):
	total_damage_got += how_much
	#if $damage.is_stopped():
	if $TextureProgress.visible == false:
		show_health_bar()
	update_health_bar(how_much)
	randomize()
	if show_total:
		$damage.start()
	elif show_total == false:
		var num_popup = damage_popup.instance()
		num_popup.position = self.position
		num_popup.amount = "-" + str(how_much)
		if critical:
			num_popup.type = "Critical"
		else:
			num_popup.type = "White"
		get_tree().current_scene.call_deferred("add_child",num_popup)
	if knockback:
		stun = true
	if should_knockback and knockback:
		velocity = -velocity * 10
		move_and_slide(velocity,Vector2.UP)
	health -= how_much
	can_shoot = false
	var tween = create_tween()
	tween.tween_property($Sprite.get_material(),"shader_param/flash_modifier",1.0,0.05)
	tween.tween_property($Sprite.get_material(),"shader_param/flash_modifier",0.0,0.05)
	if health > 0:
		$hurt.pitch_scale = rand_range(0.8,1)
		$hurt.play()
		#health -= how_much
		if health <=0:
			var blood_inst = blood.instance() if !burning else ashes.instance()
			blood_inst.global_position = global_position
			blood_inst.rotation = global_position.angle_to_point(player.global_position)
			get_tree().current_scene.add_child(blood_inst)
			$death.pitch_scale = rand_range(0.8,1)
			$death.play()
			yield(tween,"finished")
			queue_free()
			Global.emit_signal("money_picked_up",money_reward)
			grant_ruby_with_a_chance()
			Global.enemies_killed += 1
	elif health <= 0:
		var blood_inst = blood.instance() if !burning else ashes.instance()
		blood_inst.global_position = global_position
		blood_inst.rotation = global_position.angle_to_point(player.global_position)
		get_tree().current_scene.add_child(blood_inst)
		health = 0
		$death.pitch_scale = rand_range(0.8,1)
		$death.play()
		yield(tween,"finished")
		queue_free()
		Global.emit_signal("money_picked_up",money_reward)
		grant_ruby_with_a_chance()
		Global.enemies_killed += 1
	yield(tween,"finished")
	stun = false
	if player != null:
		direction_to_player = Vector2(player.global_position - global_position)
		velocity = direction_to_player.normalized() * speed
	$reload.start(rand_range(min_wait - 1,max_wait - 1))

func _on_reload_timeout():
	can_shoot = true


func _on_VisibilityNotifier2D_screen_exited():
	is_visisble = false


func _on_VisibilityNotifier2D_screen_entered():
	is_visisble = true


func _on_timer2_timeout():
	speed = previous_speed
	$AnimationPlayer.play("idle")
	$shoot.pitch_scale = rand_range(0.7,0.9)
	$shoot.play()
	can_shoot = false
	$reload.start(rand_range(min_wait,max_wait))
	if player != null:
		var bullet_inst = bullet.instance()
		bullet_inst.global_position = $Position2D.global_position
		bullet_inst.rotation = global_position.angle_to_point(player.global_position)
		bullet_inst.player = player
		bullet_inst.damage = damage
		bullet_inst.scale = $Position2D.scale
		bullet_inst.direction_to_player = direction_to_player
		bullet_inst.lock_on = true
		get_tree().current_scene.get_node("Enemies").add_child(bullet_inst)
	
func show_health_bar():
	$TextureProgress.visible = true

func update_health_bar(damagey):
	$TextureProgress.value = health - damagey


func _on_bite_timer_timeout():
	can_bite = true


func _on_Hitbox_body_entered(body):
	if is_dashing():
		if body.name == "Player":
			body.take_damage(20)


func _on_Hitbox_body_exited(body):
	if body.is_in_group("player_bullets"):
		if body.ghost:
			body.remove_ghost()

func burn(time,tick,damage_per_tick):
	if should_change_speed:
		should_change_speed = false
		previous_speed = speed
		speed = normal_speed - normal_speed * 0.6
	$burn_timer.start(time)
	if $burn_tick.is_stopped():
		$burn_tick.start(tick)
	burning = true
	$FlameParticles.emitting = true
	modulate = Color("dedede")
	
func _on_burn_timer_timeout():
	speed = normal_speed
	should_change_speed = true
	burning = false
	$FlameParticles.emitting = false
	modulate = Color("ffffff")


func _on_burn_tick_timeout():
	if burning:
		var damage = round(float(max_health)*0.05)
		if damage > 75:
			damage = 75
		take_damage(damage,false,false)
	else:
		$burn_tick.stop()

func _on_time_to_catch_on_fire_timeout():
	burn(5,1,5)


func _on_Hitbox_area_exited(area):
	if area.name == "FlameAffection":
		area.call_deferred("set_monitorable",true)
		area.call_deferred("set_monitoring",true)

func _on_Hitbox_area_entered(area):
	if area.name == "FlameAffection":
		area.call_deferred("set_monitorable",false)
		area.call_deferred("set_monitoring",false)
		if should_get_damaged_by_flames:
			take_damage(area.get_parent().damage,false,false)
			burn(5,1,5)
			should_get_damaged_by_flames = false
			if $flames_shield.is_stopped():
				$flames_shield.start(Global.stats["flames_shield"])


func _on_damage_timeout():
	var num_popup = damage_popup.instance()
	num_popup.position = self.position
	num_popup.amount = "-" + str(total_damage_got)
	num_popup.type = "White"
	get_tree().current_scene.call_deferred("add_child",num_popup)
	total_damage_got = 0
	

func _on_flames_shield_timeout():
	should_get_damaged_by_flames = true


func _on_FleeArea_body_entered(body):
	if should_stay_away:
		should_run = true

func _on_FleeArea_body_exited(body):
	if should_stay_away:
		should_run = false

func instance_ghost():
	var ghost_inst = dash_ghost.instance()
	ghost_inst.global_position = self.global_position
	ghost_inst.frames = $Sprite.frames
	ghost_inst.frame = $Sprite.frame
	ghost_inst.scale = $Sprite.scale
	ghost_inst.material = null
	ghost_inst.flip_h = $Sprite.flip_h
	get_tree().current_scene.add_child(ghost_inst)

func is_dashing():
	if get_node_or_null("dash_timer") != null:
		return !$dash_timer.is_stopped()


func _on_ghost_tick_timeout():
	instance_ghost()


func _on_dash_timer_timeout():
	$CollisionShape2D.disabled = false
	velocity = Vector2.ZERO
	#set_collision_mask_bit(1, true)
	#set_collision_mask_bit(4, true)
	instance_ghost()
	$ghost_tick.stop()
	$AnimationPlayer.play("Walk")
	speed = previous_speed


func _on_time_until_dash_timeout():
	$CollisionShape2D.disabled = true
	previous_direction = direction_to_player.normalized()
	$ghost_tick.start()
	#set_collision_mask_bit(1, false)
	#set_collision_mask_bit(4, false)
	$dash_timer.start()
	$timebetweendashes.wait_time = rand_range(5,7)
	$timebetweendashes.start()
	instance_ghost()

func start_dash():
	if can_dash:
		previous_speed = speed
		speed = 0
		can_dash = false
		$time_until_dash.start()
		$AnimationPlayer.play("Dash")

func _on_timebetweendashes_timeout():
	can_dash = true

func grant_ruby_with_a_chance():
	randomize()
	var chance = rand_range(0, 100)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	if chance <= ruby_chance:
			var ruby_amount = rng.randi_range(min_ruby,max_ruby)
			Global.settings["rubys"] += ruby_amount
			Global.emit_signal("ruby_collected",ruby_amount)
#	var rng = RandomNumberGenerator.new()
#	rng.randomize()
#	var num = randf()
#	var total = 0.0
#	var count = 0
#	var _rand_number = int(rand_range(0,5))
#	for per in ruby_percentages:
#		if num >= total and num <= total + per:
#			var ruby_amount = rng.randi_range(min_ruby,max_ruby)
#			Global.settings["rubys"] += ruby_amount
#			Global.emit_signal("ruby_collected",ruby_amount)
#			break
#		total += per
#		count += 1
