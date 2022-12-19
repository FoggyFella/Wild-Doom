extends Node

var current_music = null

func _ready():
	for child in get_children():
		child.volume_db = -60

func fade_in(music1,time,fin_volume,music2 = null,time_for_2=null):
	var tween = create_tween()
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	var music_node = get_node(music1)
	music_node.playing = true
	if music2 == null:
		tween.tween_property(music_node,"volume_db",float(fin_volume),time)
		current_music = music1
	else:
		var music2_node = get_node(music2)
		if music2_node.playing == false:
			music2_node.playing = true
		current_music = music1
		tween.parallel().tween_property(music2_node,"volume_db",-60.0,time_for_2)
		tween.parallel().tween_property(music_node,"volume_db",float(fin_volume),time)
		yield(tween,"finished")
		music2_node.playing = false
