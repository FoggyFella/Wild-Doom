extends KinematicBody2D

export var bullet_speed : float = 5
export var damage: int = 10
var player = null
var lock_on = false
var direction_to_player = Vector2()
var velocity = Vector2.ZERO
var visible_really = false

func _ready():
	player = Global.player
	damage = Global.stats["enemy_damage"]

func _physics_process(delta):
	$Sprite2.global_position = lerp($Sprite2.global_position,$Sprite.global_position,0.005)
	$Sprite3.global_position = lerp($Sprite3.global_position,$Sprite2.global_position,0.005)
	if !visible_really:
		queue_free()
	damage = Global.stats["enemy_damage"]
	if !lock_on:
		velocity += Vector2(bullet_speed,0).rotated(rotation)
	else:
		velocity = direction_to_player.normalized() * (bullet_speed)
	var info = move_and_collide(velocity)
#	for i in get_slide
#		var collision = get_slide_collision(i)
#		if collision.get_collider().has_method("take_damage"):
#			collision.get_collider().take_damage(damage)
	if info != null:
		if info.collider.has_method("take_damage"):
			queue_free()
			info.collider.take_damage(damage)


func _on_VisibilityNotifier2D_screen_exited():
#		queue_free()ier2D_screen_exited():
	visible_really = false


func _on_VisibilityNotifier2D_screen_entered():
	visible_really = true
