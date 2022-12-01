extends Button

export var weapon_name: String

func _ready():
	if !Global.is_connected("weapon_equipped",self,"on_new_weapon_equipped"):
		Global.connect("weapon_equipped",self,"on_new_weapon_equipped")
	if !Global.is_connected("money_picked_up",self,"on_new_bought"):
		Global.connect("money_picked_up",self,"on_new_bought")
	if weapon_name in Global.bought_weapons and !weapon_name in Global.equipped_weapon:
		text = "Equip"
		disabled = false
	elif !weapon_name in Global.bought_weapons:
		text = "Not Bought"
		disabled = true
	else:
		text = "Equipped"
		disabled = true 
func _on_Equip_pressed():
	Global.equipped_weapon = weapon_name
	Global.emit_signal("weapon_equipped")

func on_new_weapon_equipped():
	_ready()

func on_new_bought(a):
	_ready()
