extends StaticBody2D

onready var sprite = $Sprite
onready var collision = $CollisionShape2D

func open():
	sprite.visible = false
	collision.disabled = true

func close():
	sprite.visible = true
	collision.disabled = false
