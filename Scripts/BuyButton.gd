extends Button

export var weapon_name: String
export var weapon_cost: int
export var weapon_cost_ruby: int
export var amount:int 

func _ready():
	if weapon_name in Global.bought_weapons:
		text = "Bought"
		disabled = true
	connect("mouse_entered",self,"mouse_entered")
	connect("mouse_exited",self,"mouse_left")
	connect("focus_entered",self,"mouse_entered")
	connect("focus_exited",self,"mouse_left")
	self.rect_pivot_offset.x = self.rect_size.x/2
	self.rect_pivot_offset.y = self.rect_size.y/2


func _on_Bought():
	if weapon_cost_ruby == 0:
		if Global.money >= weapon_cost:
			Global.money -= weapon_cost
			text = "Bought"
			disabled = true
			Global.bought_weapons.append(str(weapon_name))
			Global.emit_signal("money_picked_up",weapon_cost)
			get_tree().current_scene.get_node("buy").play()
			print(Global.bought_weapons)
	else:
		if Global.settings["rubys"] >= weapon_cost_ruby:
			Global.settings["rubys"] -= weapon_cost_ruby
			if get_parent().get_node("Equip").visible:
				text = "Bought"
				disabled = true
				Global.bought_weapons.append(str(weapon_name))
				Global.emit_signal("ruby_collected",weapon_cost_ruby)
				get_tree().current_scene.get_node("buy").play()
				print(Global.bought_weapons)
			else:
				if Global.settings["bought_items"].has(str(weapon_name)):
					Global.emit_signal("ruby_collected",weapon_cost_ruby)
					Global.settings["bought_items"][str(weapon_name)] += amount
				else:
					Global.emit_signal("ruby_collected",weapon_cost_ruby)
					Global.settings["bought_items"][str(weapon_name)] = amount


func _on_Buy_mouse_entered():
	if disabled == false:
		if weapon_cost_ruby == 0:
			text = str(weapon_cost) + ' $'
		else:
			text = str(weapon_cost_ruby)


func _on_Buy_mouse_exited():
	if disabled == false:
		text = "BUY"

func mouse_entered():
	if disabled == false:
		if weapon_cost_ruby == 0:
			text = str(weapon_cost) + ' $'
		else:
			text = str(weapon_cost_ruby)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"rect_scale",Vector2(1.05,1.05),0.3)

func mouse_left():
	if disabled == false:
		text = "BUY"
	if !has_focus():
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self,"rect_scale",Vector2(1,1),0.3)

func check():
	if weapon_name in Global.bought_weapons:
		text = "Bought"
		disabled = true
	else:
		text = "Buy"
		disabled = false
