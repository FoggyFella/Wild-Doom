extends KinematicBody2D

export var min_money : int = 1
export var max_money : int = 1

var speed = 100
var velocity = Vector2.ZERO
var damage = 30
var health = 30
var speed_limit = 200

var player = null
var blood = preload("res://Scenes/BloodParticles.tscn")
var damage_popup = preload("res://Scenes/NumberPopup.tscn")
var money_reward = 0

func _ready():
	randomize()
	money_reward = int(rand_range(min_money,max_money))
	damage = 25 + int(Global.stats["enemy_damage"]/2)
	speed_limit = speed_limit * rand_range(0.8,1.3)
	if speed > 0:
		$Sprite.scale.x = 0.305
	else:
		$Sprite.scale.x = -0.305
	player = Global.player

func _physics_process(delta):
#	var overlapping_bodies = $Hitbox.get_overlapping_bodies()
#	for i in overlapping_bodies:
#		if i.is_in_group("player_bullets"):
#				take_damage(i.damage)
#				i.queue_free()
#		elif i == player:
#			i.health -= damage
	velocity.x += speed*delta
	velocity = Vector2(velocity.x,0)
	if velocity.x > speed_limit:
		velocity.x = speed_limit
	elif velocity.x < -speed_limit:
		velocity.x = -speed_limit
	move_and_slide(velocity,Vector2.UP)

func take_damage(how_much,critical):
	randomize()
	var num_popup = damage_popup.instance()
	num_popup.position = self.position
	num_popup.amount = "-" + str(how_much)
	if critical:
		num_popup.type = "Critical"
	else:
		num_popup.type = "White"
	get_tree().root.add_child(num_popup)
	health -= how_much
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
			get_tree().root.add_child(blood_inst)
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
		get_tree().root.add_child(blood_inst)
		health = 0
		$death.pitch_scale = rand_range(0.8,1)
		$death.play()
		yield(tween,"finished")
		queue_free()
		Global.emit_signal("money_picked_up",money_reward)
		Global.enemies_killed += 1


func _on_Hitbox_body_entered(body):
	if body.is_in_group("player_bullets"):
			body.health -= 1
			if body.critical:
				take_damage(body.damage,true)
			else:
				take_damage(body.damage,false)
			if body.health <= 0:
				body.queue_free()
			else:
				body.call_deferred("become_ghost")
	elif body == player:
		body.take_damage(damage)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Hitbox_body_exited(body):
	if body.is_in_group("player_bullets"):
		if body.ghost:
			body.remove_ghost()
