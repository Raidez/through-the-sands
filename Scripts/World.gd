extends Node2D

onready var ship = $Ship
onready var player = $Player

func _ready():
	HyperLog.log(player).text("player_velocity>round")
	HyperLog.log(player).text("state")
#
	HyperLog.log(ship).text("velocity>round")
