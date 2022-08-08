extends Node2D

onready var ship = $Ship
onready var player = $Player

func _ready():
	HyperLog.log(player).text("player_velocity>round")
	HyperLog.log(player).text("state")
#
	HyperLog.log(ship).text("velocity>round")


func _on_Lever1_power_on():
	get_tree().call_group("door1", "open")

func _on_Lever1_power_off():
	get_tree().call_group("door1", "close")

func _on_Button1_power_on():
	get_tree().call_group("door1", "open")

func _on_PressurePlate1_power_on():
	get_tree().call_group("door1", "open")

func _on_PressurePlate1_power_off():
	get_tree().call_group("door1", "close")
