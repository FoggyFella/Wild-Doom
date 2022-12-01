extends KinematicBody2D

export var damage : int = 50
export var bullet_speed : float = 50
onready var timer_to_dissapear = $timer_to_dissapear
onready var ghost_timer = $ghost_timer
var is_flamethrower = false
var bullet_sprite = "Pistol"
var ghost = false
var health = 1
var lock_on = false
var velocity = Vector2.ZERO
var damage_multiplier = [1,2]
var percentages = [0.9,0.1]
var critical = false
var starting_damage = null
var time_to_be_gone = 3

func _ready():
	if !is_flamethrower:
		get_node(bullet_sprite+"Bullet").visible = true
	percentages[0] = 1.0 - Global.stats["player_crit_chance"]
	percentages[1] = Global.stats["player_crit_chance"]
	#print(percentages)
	starting_damage = Global.stats["player_damage"]
	damage = Global.stats["player_damage"]
	randomize()
	var num = randf()
	var total = 0.0
	var count = 0
	var _rand_number = int(rand_range(0,5))
	for per in percentages:
		if num >= total and num <= total + per:
			damage = damage * damage_multiplier[count]
			if damage == starting_damage * 2:
				critical = true
			break
		total += per
		count += 1
	$timer_to_dissapear.start(time_to_be_gone)

func _physics_process(delta):
	#damage = Global.stats["player_damagey"]
	velocity += Vector2(bullet_speed*delta,0).rotated(rotation) 
	var info = move_and_collide(velocity)
	if is_flamethrower:
		var enemies = $Hitbox.get_overlapping_bodies()
		if !enemies.empty():
			for enemy in enemies:
				enemy.burn(5,1,5)
#	for i in get_slide_count():
#		var collision = get_slide_collision(i)
#		if collision.get_collider().has_method("take_damage"):
##			queue_free()
##			collision.get_collider().take_damage(damage)
	if info != null:
		if info.collider.has_method("take_damage"):
			$timer_to_dissapear.paused = true
	else:
		$timer_to_dissapear.paused = false


func _on_timer_to_dissapear_timeout():
	queue_free()

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	pass
#	if is_instance_valid($timer_to_dissapear):
#		$timer_to_dissapear.start()

func remove_ghost():
	$CollisionShape2D.set_deferred("disabled",false)
	ghost = false

func become_ghost():
	$CollisionShape2D.set_deferred("disabled",true)
	ghost = true
