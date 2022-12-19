extends Panel

func set_metadata(weapon,enemies,pickups):
	$Node2D/MetadataPanel/VBoxContainer/Label.text = "Weapon: " + str(weapon)
	$Node2D/MetadataPanel/VBoxContainer/Label2.text = "Enemies killed: " + str(enemies)
	$Node2D/MetadataPanel/VBoxContainer/Label3.text = "Pickups collected: " + str(pickups)

func _on_PlayerName_mouse_entered():
	$Node2D.z_index = 1
	var tween = create_tween()
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Node2D/MetadataPanel,"rect_scale",Vector2(1,1),0.5)

func _on_PlayerName_mouse_exited():
	$Node2D.z_index = 0
	var tween = create_tween()
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Node2D/MetadataPanel,"rect_scale",Vector2(1,0),0.5)
