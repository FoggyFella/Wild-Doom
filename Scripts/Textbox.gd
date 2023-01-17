extends CanvasLayer

const character_read_rate = 0.9

onready var textbox_container = $TextContainer
onready var start_symbol = $TextContainer/MarginContainer/HBoxContainer/Start
onready var end_symbol = $TextContainer/MarginContainer/HBoxContainer/End
onready var label = $TextContainer/MarginContainer/HBoxContainer/Label2

enum State{
	READY,
	READING,
	FINISHED
}

var on_mouse = true

signal time_to_choose
signal stand
signal nope_finished
signal finished
signal begin_tutorial

var current_state = State.READY
var text_queue = []

func _ready():
	hide_textbox()
	
func _process(delta):
	match current_state:
		State.READY:
			if !text_queue.empty():
				display_text()
				#get_tree().paused = true
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				label.percent_visible = 1.0
				$Tween.remove_all()
				end_symbol.text = 'ENTER'
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				change_state(State.READY)
				hide_textbox()
				emit_signal("finished")

func queue_text(next_text):
	text_queue.push_back(next_text)
	

func hide_textbox():
	#get_tree().paused = false
	start_symbol.text = ''
	end_symbol.text = ""
	label.text = ''
	$Name.text = ''
	textbox_container.hide()
	$Name.hide()

func show_textbox():
	start_symbol.text = '*'
	textbox_container.show()
	$Name.show()
	
func display_text():
	var next_text = text_queue.pop_front()
	if next_text == ["So...","The Devil"]:
		emit_signal("stand")
	if next_text == ["Hmm... let's get right into it then","The Devil"]:
		emit_signal("nope_finished")
	if next_text == ["Now... would you like to know the rules?","The Devil"]:
		emit_signal("time_to_choose")
	if next_text == ["Follow along","The Devil"]:
		emit_signal("begin_tutorial")
	label.text = next_text[0]
	$Name.text = next_text[1]
	label.percent_visible = 0.0
	change_state(State.READING)
	show_textbox()
	$Tween.interpolate_property(label, "percent_visible" , 0.0,1.0, len(next_text) * character_read_rate, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	$Tween.start()

	
func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			print("Changing state to state.READY")
		State.READING:
			print("Changing state to state.READING")
		State.FINISHED:
			print("Changing state to state.FINISHED")


func _on_Tween_tween_completed(object, key):
		end_symbol.text = 'ENTER'
		change_state(State.FINISHED)
