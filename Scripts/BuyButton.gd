extends Button

export var weapon_name: String
export var weapon_cost: int

func _ready():
	if weapon_name in Global.bought_weapons:
		text = "Bought"
		disabled = true


func _on_Bought():
	if Global.money >= weapon_cost:
		Global.money -= weapon_cost
		text = "Bought"
		disabled = true
		Global.bought_weapons.append(str(weapon_name))
		Global.emit_signal("money_picked_up",weapon_cost)
		print(Global.bought_weapons)


func _on_Buy_mouse_entered():
	if disabled == false:
		text = str(weapon_cost) + ' $'


func _on_Buy_mouse_exited():
	if disabled == false:
		text = "BUY"
