extends Control

var music_bus = AudioServer.get_bus_index("MusicBus")
var sfx_bus = AudioServer.get_bus_index("SoundEffects")
var dash_bus = AudioServer.get_bus_index("DashBus")
var focused_on_scroll = false

func _ready():
	$HBoxContainer/VBoxContainer/HBoxContainer3/CheckButton.grab_focus()
	Global.stop_timer()
	Global.reset_timer()
	$HBoxContainer/VBoxContainer/HBoxContainer3/CheckButton.pressed = OS.is_window_fullscreen()
	$HBoxContainer/VBoxContainer/HBoxContainer/MusicSlider.value = AudioServer.get_bus_volume_db(music_bus)
	$HBoxContainer/VBoxContainer/HBoxContainer2/SfxSlider.value = AudioServer.get_bus_volume_db(sfx_bus)

func _on_MainMenu_pressed():
	$click.play()
	Global.save_game()
	Transition.change_scene("res://Scenes/Menu.tscn")

func _on_MusicSlider_value_changed(value):
	$scroll.play()
	AudioServer.set_bus_volume_db(music_bus,value)
	Global.settings["music_volume"] = value
	if value == -50:
		AudioServer.set_bus_mute(music_bus,true)
	else:
		AudioServer.set_bus_mute(music_bus,false)

func _on_SfxSlider_value_changed(value):
	$scroll.play()
	AudioServer.set_bus_volume_db(sfx_bus,value)
	AudioServer.set_bus_volume_db(dash_bus,value)
	Global.settings["sfx_volume"] = value
	if value == -30:
		AudioServer.set_bus_mute(sfx_bus,true)
		AudioServer.set_bus_mute(dash_bus,true)
	else:
		AudioServer.set_bus_mute(sfx_bus,false)
		AudioServer.set_bus_mute(dash_bus,false)


func _on_CheckButton_pressed():
	if OS.is_window_fullscreen():
		$switch.pitch_scale = 0.8
		$switch.play()
		OS.set_window_fullscreen(false)
		Global.settings["fullscreen"] = false
	else:
		$switch.pitch_scale = 1
		$switch.play()
		OS.set_window_fullscreen(true)
		Global.settings["fullscreen"] = true

func on_scroll_focused():
	focused_on_scroll = true

func on_scroll_focus_exited():
	focused_on_scroll = false

func _on_SfxSlider_drag_ended(value_changed):
	$scroll.stop()


func _on_MusicSlider_drag_ended(value_changed):
	$scroll.stop()

func _input(event):
	if event is InputEventJoypadButton and focused_on_scroll:
		if Input.is_action_just_pressed("ui_left"):
			$Timer.start()
		if Input.is_action_just_released("ui_left"):
			$Timer.stop()
		if Input.is_action_just_pressed("ui_right"):
			$Timer2.start()
		if Input.is_action_just_released("ui_right"):
			$Timer2.stop()


func _on_Timer_timeout():
	get_focus_owner().value -= 0.1


func _on_Timer2_timeout():
	get_focus_owner().value += 0.1


func _on_DeadzoneSlider_drag_ended(value_changed):
	$scroll.stop()

func _on_DeadzoneSlider_value_changed(value):
	$scroll.play()
	Global.settings["deadzone"] = value
