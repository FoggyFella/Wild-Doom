extends Node2D

var enemy = null
var is_the_fucker : bool
var should_walk_to_the_point = false
var velocity_of_the_fucker = 0
var name_to_look_up = ""
var max_amount_of_this_type = 200

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()

func _on_AnimationTimer_timeout():
#	var amount_of_children_of_this_type = 0
#	for child in get_tree().root.get_children():
#		if name_to_look_up in child.name:
#			amount_of_children_of_this_type += 1
#			print(amount_of_children_of_this_type)
#	if amount_of_children_of_this_type < max_amount_of_this_type:
	var enemy_inst = enemy.instance()
	enemy_inst.global_position = self.position
	if "should_walk_to_the_closest_thing" in enemy_inst:
		enemy_inst.should_walk_to_the_closest_thing = should_walk_to_the_point
	if is_the_fucker:
		enemy_inst.speed = velocity_of_the_fucker
	#enemy_inst.player = get_parent().get_node("Player")
	get_tree().current_scene.get_node("Enemies").add_child(enemy_inst)
#	else:
#		pass
