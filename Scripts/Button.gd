extends Interact

class_name IButton

enum DIRECTION_TYPE { LEFT, RIGHT }
export(DIRECTION_TYPE) var direction = DIRECTION_TYPE.RIGHT

onready var right_sprite = $RightCollision/RightSprite
onready var left_sprite = $LeftCollision/LeftSprite
onready var right = $RightCollision
onready var left = $LeftCollision
onready var state = false

var sprite: AnimatedSprite

func _ready():
	if direction == DIRECTION_TYPE.RIGHT:
		sprite = right_sprite
		left.visible = false
	elif direction == DIRECTION_TYPE.LEFT:
		sprite = left_sprite
		right.visible = false

func _process(_delta):
	if state:
		sprite.frame = 1
	else:
		sprite.frame = 0

func press():
	if not state:
		emit_signal("power_on")
		state = true
