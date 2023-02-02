extends KinematicBody2D

export var bullet_speed : float = 5
export var damage: int = 10
export var additional_damage: int = 0
var player = null
var lock_on = false
var direction_to_player = Vector2()
var velocity = Vector2.ZERO
var visible_really = false
var should_slow_down = false
var bullet_sprite = "Default"

func _ready():
	player = Global.player
	damage = Global.stats["enemy_damage"]
	if rotation_degrees < 90 and rotation_degrees >= 0:
		$Skull.scale.y = -1
	else:
		$Skull.scale.y = 1
	get_node(bullet_sprite).show()

func _physics_process(delta):
	if !visible_really:
		queue_free()
	damage = Global.stats["enemy_damage"] + additional_damage
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
			if should_slow_down:
				info.collider.apply_speed_down()


func _on_VisibilityNotifier2D_screen_exited():
#	queue_free()ier2D_screen_exited():
	visible_really = false


func _on_VisibilityNotifier2D_screen_entered():
	visible_really = true
