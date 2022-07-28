extends Interact

enum TRIGGER_TYPE { BOX = 1, SHIP = 2, PLAYER = 4}
export(int, FLAGS, "Box", "Ship", "Player") var trigger = 7

onready var animation = $AnimatedSprite as AnimatedSprite
onready var state = false

func _process(delta):
	if state:
		animation.frame = 1
	else:
		animation.frame = 0

func _on_PressurePlate_body_entered(body):
	if check_body(body):
		emit_signal("power_on")
		state = true

func _on_PressurePlate_body_exited(body):
	if check_body(body):
		emit_signal("power_off")
		state = false

func check_body(body) -> bool:
	var is_collision = false
	if trigger & TRIGGER_TYPE.BOX == TRIGGER_TYPE.BOX:
		is_collision = is_collision or body is Box and body.is_in_group("boxes")
	if trigger & TRIGGER_TYPE.SHIP == TRIGGER_TYPE.SHIP:
		is_collision = is_collision or body is Box and body.is_in_group("ship")
	if trigger & TRIGGER_TYPE.PLAYER == TRIGGER_TYPE.PLAYER:
		is_collision = is_collision or body is Player
	
	return is_collision
