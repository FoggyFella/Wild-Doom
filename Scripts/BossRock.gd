extends KinematicBody2D

var marker = preload("res://Scenes/marker.tscn")
var bullet = preload("res://Scenes/BossProjectile.tscn")
var ghost = preload("res://Scenes/DashGhost.tscn")
var velocity = Vector2.ZERO
var player_pos = Vector2.ZERO


func _ready():
	player_pos = Global.player.position
	var marker_inst = marker.instance()
	marker_inst.position = player_pos
	get_tree().current_scene.call_deferred("add_child",marker_inst)
	
func _physics_process(delta):
	if position.distance_to(player_pos) <= 2.0:
		explode()
	if player_pos != Vector2.ZERO:
		if player_pos.x > 0:
			$Sprite.rotation_degrees += 3
		else:
			$Sprite.rotation_degrees -= 3
		var direction = Vector2(player_pos - position).normalized()
		velocity = direction * 150
		velocity = move_and_slide(velocity,Vector2.UP)


func _on_Hitbox_body_entered(body):
	if body.name == "Player":
		explode()

func explode():
	for point in $Path2D.get_curve().get_point_count():
		var bullet_inst = bullet.instance()
		bullet_inst.global_position = $Path2D.get_curve().get_point_position(point) + self.position
		bullet_inst.rotation = $Path2D.get_curve().get_point_position(point).angle()
		get_tree().current_scene.call_deferred("add_child",bullet_inst)
	queue_free()


func _on_Hitbox_area_entered(area):
	if area.name == "MarkerArea":
		area.get_parent().queue_free()

func instance_ghost():
	var ghost_inst = ghost.instance()
	ghost_inst.global_position = self.global_position
	ghost_inst.frames = $Sprite.frames
	ghost_inst.frame = $Sprite.frame
	ghost_inst.rotation = $Sprite.rotation
	ghost_inst.material = null
	ghost_inst.scale = $Sprite.scale
	ghost_inst.flip_h = $Sprite.flip_h
	get_tree().current_scene.add_child(ghost_inst)

func _on_ghost_tick_timeout():
	instance_ghost()
