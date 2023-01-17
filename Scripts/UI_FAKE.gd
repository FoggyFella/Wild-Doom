extends CanvasLayer

func update_dash_charge(dash_charge_time):
	var tween = create_tween()
	tween.tween_property($DashCharge,"value",0.0,0.1)
	tween.tween_property($DashCharge,"value",1.0,dash_charge_time)
