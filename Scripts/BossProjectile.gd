extends KinematicBody2D

var velocity = Vector2()
var speed = 300
var damage = 40

func _ready():
	pass
	#rotation += get_angle_to(Global.player.position)

func _process(delta):
	velocity = Vector2(speed*delta,0).rotated(rotation)
	var info = move_and_collide(velocity)
	if info != null:
		if info.collider.has_method("take_damage"):
			queue_free()
			info.collider.take_damage(damage)

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()
