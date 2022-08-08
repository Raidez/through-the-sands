extends Interact

export(bool) var default_sate = false

onready var animation = $AnimatedSprite as AnimatedSprite
onready var state = default_sate

func _ready():
	#On définit par défaut l'état du levier
	if state:
		emit_signal("power_on")
	else:
		emit_signal("power_off")

func _process(_delta):
	if state:
		animation.frame = 1
	else:
		animation.frame = 0

func switch():
	#Permet d'échanger l'état du levier
	if state:
		emit_signal("power_off")
		state = false
	else:
		emit_signal("power_on")
		state = true
