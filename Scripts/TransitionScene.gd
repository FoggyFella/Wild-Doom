extends CanvasLayer

onready var color_rect = $"%ColorRect"
onready var color_rect_2 = $"%ColorRect2"
onready var color_rect_3 = $"%ColorRect3"


func _ready():
	set_defaults()

func reload_current_scene():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	color_rect.visible = true
	tween.tween_property(color_rect,"rect_scale",Vector2(1,1),0.3)
	tween.tween_interval(0.3)
	yield(tween,"finished")
	get_tree().reload_current_scene()
	if get_tree().paused:
		get_tree().paused = false
	var tween2 = create_tween()
	tween2.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property(color_rect,"rect_scale",Vector2(0,1),0.3)
	yield(tween,"finished")
	color_rect.visible = false

func change_scene(target):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	color_rect_2.visible = true
	tween.tween_property(color_rect_2,"rect_scale",Vector2(1,1),0.3)
	tween.tween_interval(0.3)
	yield(tween,"finished")
	get_tree().change_scene(target)
	var tween2 = create_tween()
	tween2.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property(color_rect_2,"rect_scale",Vector2(1,0),0.3)
	yield(tween,"finished")
	color_rect_2.visible = false

func white_transition(target):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	color_rect_3.visible = true
	color_rect_3.modulate = Color(1,1,1,0)
	tween.tween_property(color_rect_3,"modulate",Color(1,1,1,1),1)
	tween.tween_interval(0.3)
	yield(tween,"finished")
	get_tree().change_scene(target)
	var tween2 = create_tween()
	tween2.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property(color_rect_3,"modulate",Color(1,1,1,0),1)
	yield(tween,"finished")
	color_rect_3.visible = false

#func reload_current_scene():
#	$AnimationPlayer.play("transition_bar")
#	yield($AnimationPlayer,"animation_finished")
#	get_tree().reload_current_scene()
#	if get_tree().paused:
#		get_tree().paused = false
#	$AnimationPlayer.play_backwards("transition_bar")

#func change_scene(target):
#	$AnimationPlayer.play("transition_2")
#	yield($AnimationPlayer,"animation_finished")
#	get_tree().change_scene(target)
#	$AnimationPlayer.play_backwards("transition_2")

func set_defaults():
	color_rect.visible = false
	color_rect.rect_scale = Vector2(0,1)
	color_rect_2.visible = false
	color_rect_2.rect_scale = Vector2(1,0)
	color_rect_3.visible = false
	color_rect_3.modulate = Color(1,1,1,0)
