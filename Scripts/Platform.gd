extends StaticBody2D

class_name Platform

onready var timer = $Timer
onready var collision = $CollisionShape2D

func passthrough():
	collision.disabled = true
	timer.start()

func _on_Timer_timeout():
	collision.disabled = false
