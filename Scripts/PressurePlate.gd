extends Interact

export(bool) var default_state = false

onready var raycast = $RayCast2D as RayCast2D
onready var animation = $AnimatedSprite as AnimatedSprite
onready var state = default_state

func _ready():
	if default_state:
		emit_signal("power_on")
	else:
		emit_signal("power_off")

func _process(delta):
	if state:
		animation.frame = 1
	else:
		animation.frame = 0

func _on_PressurePlate_body_entered(body):
	if body is Box:
		emit_signal("power_on")
		state = true

func _on_PressurePlate_body_exited(body):
	if body is Box:
		emit_signal("power_off")
		state = false
