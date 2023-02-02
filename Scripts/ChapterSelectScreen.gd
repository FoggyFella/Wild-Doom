extends Control

var selected_chapter = ""
var should_spend_pass = false

func _ready():
	if Global.settings["bought_items"].has("BossPass"):
		$ChapterMenus/BossPasses/Amount.text = str(Global.settings["bought_items"]["BossPass"])
	else:
		$ChapterMenus/BossPasses/Amount.text = "0"

func _on_Chapter1_pressed():
	$ChapterMenus.show()
	for child in $ChapterMenus.get_children():
		child.hide()
	$ChapterMenus/Chapter1.show()
	$ChapterMenus/ColorRect.show()
	$ChapterMenus/Chapter1/ChoicesContainer/Choice.grab_focus()
	$ChapterMenus/Chapter1/ChoicesContainer/Choice.pressed = true
	$ChapterMenus/CloseButton.show()
	$ChapterMenus/ColorRect2.show()
	$ChapterMenus/ColorRect3.show()
	$ChapterMenus/BossPasses.show()

func _on_Chapter2_pressed():
	if !2 in Global.settings["unlocked_chapters"]:
		$locked.play()

func _on_Chapter3_pressed():
	if !3 in Global.settings["unlocked_chapters"]:
		$locked.play()

func _on_Chapter4_pressed():
	if !4 in Global.settings["unlocked_chapters"]:
		$locked.play()

func _on_PlayButton_pressed():
	if !should_spend_pass:
		if selected_chapter != "":
			$ChapterMenus/Chapter1/PlayButton.disabled = true
			Transition.white_transition(selected_chapter)
		else:
			$ChapterMenus/Chapter1/PlayButton.disabled = true
			Transition.white_transition("res://Scenes/World.tscn")
		Music.fade_in("Chapter1",3,-15,"Game",2)
	else:
		if Global.settings["bought_items"].has("BossPass"):
			if Global.settings["bought_items"]["BossPass"] > 0:
				$ChapterMenus/Chapter1/PlayButton.disabled = true
				Global.settings["bought_items"]["BossPass"] -= 1
				$ChapterMenus/BossPasses/Amount.text = str(Global.settings["bought_items"]["BossPass"])
				Transition.white_transition(selected_chapter)
				Music.fade_in("Chapter1",3,-15,"Game",2)
		else:
			$ChapterMenus/Error.show()


func _on_CloseButton_pressed():
	$Chapters/Chapter1.grab_focus()
	$ChapterMenus.hide()

func _on_MainMenu_pressed():
	Transition.change_scene("res://Scenes/Menu.tscn")
