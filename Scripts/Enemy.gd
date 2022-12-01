extends KinematicBody2D

var speed : float = 50
export var damage : int = 10
export var health : int = 100
export var more_health : int = 0
export var min_money : int = 1
export var max_money : int = 3
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

var previous_speed = speed
var burning = false
var money_reward = 0
var stun = false
var can_shoot = true
var direction_to_player = Vector2()
var player = null
var is_visisble = false
var velocity = Vector2.ZERO
var should_change_speed = true

var bullet = preload("res://Scenes/enemy_bullet.tscn")
var blood = preload("res://Scenes/BloodParticles.tscn")
var damage_popup = preload("res://Scenes/NumberPopup.tscn")
var can_bite = true
var sprite_size_x = null

onready var time_to_catch_on_fire = $time_to_catch_on_fire

func _ready():
	randomize()
	money_reward = int(rand_range(min_money,max_money))
	sprite_size_x = $Sprite.scale.x
	health = Global.stats["enemy_health"] + more_health
	$TextureProgress.max_value = health
	$TextureProgress.value = health
	scale.x = rand_range(0.8,1)
	scale.y = scale.x
	if should_walk:
		speed = Global.stats["enemy_speed"] + rand_range(min_speed,max_speed)
	else:
		speed = 0
	player = Global.player
	
func _physics_process(delta):
	var overlapping_bodies = $Hitbox.get_overlapping_bodies()
	for i in overlapping_bodies:
		if stun == false:
			i.health -= 1
			if i.health <= 0:
				i.call_deferred("queue_free")
			else:
				i.call_deferred("become_ghost")
			if i.critical and !i.is_flamethrower:
				take_damage(i.damage,true)
			elif !i.critical and !i.is_flamethrower:
				take_damage(i.damage,false)
#			elif i.is_flamethrower:
#				burn(5,1,5)
	if player == null:
		queue_free()
	if player != null and stun == false:
		direction_to_player = Vector2(player.global_position - global_position)
		velocity = direction_to_player.normalized() * speed
		move_and_slide(velocity,Vector2.UP)
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().has_method("take_damage") and collision.get_collider().name == "Player":
				if can_bite:
					can_bite = false
					$bite_timer.start()
					collision.get_collider().take_damage(bite_damage)
		if direction_to_player.x < 0:
			if should_rotate:
				$Sprite.rotation_degrees = lerp($Sprite.rotation_degrees,-8.9,0.05)
			$Sprite.scale.x = lerp($Sprite.scale.x,-sprite_size_x,0.27)
		else:
			if should_rotate:
				$Sprite.rotation_degrees = lerp($Sprite.rotation_degrees,8.9,0.05)
			$Sprite.scale.x = lerp($Sprite.scale.x,sprite_size_x,0.27)
		if can_shoot and is_visisble:
			if should_shoot:
				shoot()
func shoot():
	if $timer2.is_stopped():
		speed -= 40
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

func take_damage(how_much,critical,knockback=true):
	if $TextureProgress.visible == false:
		show_health_bar()
	update_health_bar(how_much)
	randomize()
	var num_popup = damage_popup.instance()
	num_popup.position = self.position
	num_popup.amount = "-" + str(how_much)
	if critical:
		num_popup.type = "Critical"
	else:
		num_popup.type = "White"
	get_tree().current_scene.add_child(num_popup)
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
			var blood_inst = blood.instance()
			blood_inst.global_position = global_position
			blood_inst.rotation = global_position.angle_to_point(player.global_position)
			get_tree().current_scene.add_child(blood_inst)
			$death.pitch_scale = rand_range(0.8,1)
			$death.play()
			yield(tween,"finished")
			queue_free()
			Global.emit_signal("money_picked_up",money_reward)
			Global.enemies_killed += 1
	elif health <= 0:
		var blood_inst = blood.instance()
		blood_inst.global_position = global_position
		blood_inst.rotation = global_position.angle_to_point(player.global_position)
		get_tree().current_scene.add_child(blood_inst)
		health = 0
		$death.pitch_scale = rand_range(0.8,1)
		$death.play()
		yield(tween,"finished")
		queue_free()
		Global.emit_signal("money_picked_up",money_reward)
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
	speed += 40
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
	pass
#	if self.stun != true:
#		take_damage(body.damage)
#		body.queue_free()


func _on_Hitbox_body_exited(body):
	if body.is_in_group("player_bullets"):
		if body.ghost:
			body.remove_ghost()

func burn(time,tick,damage_per_tick):
	if should_change_speed:
		should_change_speed = false
		previous_speed = speed
		speed = speed - speed * 0.6
	$burn_timer.start(time)
	if $burn_tick.is_stopped():
		$burn_tick.start(tick)
	burning = true
	$Sprite.material.set("shader_param/min_line_width",2)
	$Sprite.material.set("shader_param/max_line_width",7)

func _on_burn_timer_timeout():
	speed = previous_speed
	should_change_speed = true
	burning = false
	$Sprite.material.set("shader_param/min_line_width",0)
	$Sprite.material.set("shader_param/max_line_width",0)


func _on_burn_tick_timeout():
	if burning:
		take_damage(5,false,false)
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
		take_damage(area.get_parent().damage,false,false)
		burn(5,1,5)
