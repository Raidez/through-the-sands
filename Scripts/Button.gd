extends Interact

enum DIRECTION_TYPE { LEFT, RIGHT }
export(DIRECTION_TYPE) var direction = DIRECTION_TYPE.RIGHT

onready var sprite = $AnimatedSprite as AnimatedSprite
onready var state = false

func _process(_delta):
	if state:
		sprite.frame = 1
	else:
		sprite.frame = 0

func switch():
	if not state:
		emit_signal("power_on")
		state = true
