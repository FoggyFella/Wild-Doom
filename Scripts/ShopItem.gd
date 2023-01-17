extends Button

export var item_name = "ItemName"
export var item_top_desc = ""
export var item_stats = []
export var item_btm_desc = ""
export var price = 0
export var ruby_price = 0
export var scale_of_icon = Vector2(1,1)
export var can_equip = true
export var amount = 0

func _ready():
	connect("pressed",self,"on_pressed")

func on_pressed():
	get_tree().current_scene.get_node("click").play()
	get_tree().current_scene.change_item($ItemIcon.texture,item_name,item_stats,item_top_desc,item_btm_desc,price,scale_of_icon,ruby_price,can_equip,amount)
