extends Button

export var what_to_add = 0

func _ready():
	connect("pressed",self,"on_pressed")

func on_pressed():
	if int(get_parent().get_node("Amount").text) + what_to_add > 0:
		get_parent().get_node("Amount").text = str(int(get_parent().get_node("Amount").text) + what_to_add)
		get_parent().get_parent().amount = int(get_parent().get_node("Amount").text)
		get_parent().get_parent().item_top_desc = "Amount you're gonna buy: "+str(get_parent().get_parent().amount)
		get_parent().get_parent().on_pressed()
