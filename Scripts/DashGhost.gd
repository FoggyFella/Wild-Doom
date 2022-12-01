extends AnimatedSprite


func _ready():
	var tween = create_tween()
	tween.tween_property(self,"modulate",Color(1,1,1,0),0.2)
	yield(tween,"finished")
	queue_free()
