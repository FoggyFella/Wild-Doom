extends Control

var current_section = "Guns"
var number_popup = preload("res://Scenes/NumberPopup.tscn")

func _ready():
	$ItemInfo/ActualInfo.hide()
	$ItemInfo/NotSelected.show()
	$ItemInfo/ActualInfo/Stats.hide()
	Global.connect("money_picked_up",self,"on_bought")
	Global.connect("ruby_collected",self,"on_ruby_bought")
	$MoneyCash/AmountOmoney.text = str(Global.money)#.pad_zeros(5)
	$Rubys/AmountOmoney.text = str(Global.settings["rubys"])
	for child in $ItemInfo/ActualInfo/ItemStuff.get_children():
		child.hide()

func change_item(texture,item_name,item_stats,top_desc,btm_desc,price,scale_of_icon,ruby_price,can_equip,amount = 0):
	$ItemInfo/NotSelected.hide()
	$ItemInfo/ActualInfo.show()
	$ItemInfo/ActualInfo/ItemStuff/ItemBtmDesc.visible = true if btm_desc != "" else false
	$ItemInfo/ActualInfo/ItemStuff/ItemTopDesc.visible = true if top_desc != "" else false
	$ItemInfo/ActualInfo/ItemStuff/ItemStats.visible = true if item_stats != [] else false
	$ItemInfo/ActualInfo/ImagePanel/Image2.texture = texture
	$ItemInfo/ActualInfo/ImagePanel/Image.texture = texture
	$ItemInfo/ActualInfo/ImagePanel/Image2.rect_scale = scale_of_icon
	$ItemInfo/ActualInfo/ImagePanel/Image.rect_scale = scale_of_icon
	$ItemInfo/ActualInfo/ItemName.text = item_name
	$ItemInfo/ActualInfo/ItemStuff/ItemBtmDesc.text = btm_desc
	$ItemInfo/ActualInfo/ItemStuff/ItemTopDesc.text = top_desc
	if item_stats != []:
		item_stats[0] = item_stats[0].replace("DMG","")
		item_stats[1] = item_stats[1].replace("FRT","")
		item_stats[2] = item_stats[2].replace("CRT","")
	if $ItemInfo/ActualInfo/ItemStuff/ItemStats.visible:
		$ItemInfo/ActualInfo/ItemStuff/ItemStats.text = item_stats[0] + "\n" + item_stats[1] + "\n" + item_stats[2]
		$ItemInfo/ActualInfo/Stats.show()
	else:
		$ItemInfo/ActualInfo/Stats.hide()
	if can_equip:
		$ItemInfo/ActualInfo/Buttons/Equip.show()
	else:
		$ItemInfo/ActualInfo/Buttons/Equip.hide()
	$ItemInfo/ActualInfo/Buttons/Buy.amount = amount
	$ItemInfo/ActualInfo/Buttons/Buy.weapon_cost = price
	$ItemInfo/ActualInfo/Buttons/Buy.weapon_cost_ruby = ruby_price * amount
	$ItemInfo/ActualInfo/Buttons/Buy.weapon_name = item_name
	$ItemInfo/ActualInfo/Buttons/Equip.weapon_name = item_name
	$ItemInfo/ActualInfo/Buttons/Equip.check()
	$ItemInfo/ActualInfo/Buttons/Buy.check()

func on_bought(amounti):
	var money_number = number_popup.instance()
	money_number.amount = "-" + str(amounti)
	money_number.type = "Green"
	money_number.position = Vector2(56,10)
	$MoneyCash/AmountOmoney.text = str(Global.money)#.pad_zeros(5) + " $"
	$MoneyCash/AmountOmoney/CenterContainer.add_child(money_number)

func on_ruby_bought(amounti):
	var money_number = number_popup.instance()
	money_number.amount = "-" + str(amounti)
	money_number.type = "Red"
	money_number.position = Vector2(56,10)
	$Rubys/AmountOmoney.text = str(Global.settings["rubys"])#.pad_zeros(5) + " $"
	$Rubys/AmountOmoney/CenterContainer.add_child(money_number)

func _on_GunSection_pressed():
	$switch.play()
	current_section = "Guns"
	$Sign/SignName.text = current_section
	$Items/Shop.hide()
	#$Items/Skills.hide()
	$Items/Guns.show()
	
func _on_SkillSection_pressed():
	$switch.play()
	current_section = "Skills"
	$Sign/SignName.text = current_section
	$Items/Shop.hide()
	$Items/Guns.hide()
	#$Items/Skills.show()

func _on_ShopSection_pressed():
	$switch.play()
	current_section = "Shop"
	$Sign/SignName.text = current_section
	#$Items/Skills.hide()
	$Items/Guns.hide()
	$Items/Shop.show()


func _on_MainMenu_pressed():
	Transition.change_scene("res://Scenes/Menu.tscn")
