extends KinematicBody2D

#Variable de vitesse horizontale du personnage joueur, modifiable dans l'éditeur
export(int) var MAX_SPEED = 200
export(int) var ACCELERATION = 200
export(int) var GROUND_FRICTION = 200

#Variables de vitesse verticale du personnage joueur, modifiable dans l'éditeur
export(int) var JUMP_FORCE = 50
export(int) var MAX_FALL_SPEED = 200
export(int) var FAST_FALL_SPEED = 150
export(int) var GRAVITY = 5

#Variable pour stocker l'animation du joueur
onready var player_animated_sprite = $AnimatedSprite

#Variable pour stocker les minuteurs joueur
onready var coyote_time = $CoyoteTimeTimer
onready var jump_buffer = $JumpBufferTimer

#Variable pour stocker les bouttons du joueur, facile à changer pour plus tard
var input_move_right = "move_right"
var input_move_left = "move_left"
var input_jump = "move_jump"
var input_move_down = "move_down"

var player_direction = Vector2.ZERO
var player_velocity = Vector2.ZERO
var fast_fall = false


func _physics_process(delta):
	get_player_direction()
	
	make_player_move_horizontal(player_direction.x)
	apply_gravity()
	
	make_player_jump()
	
	move_and_slide(player_velocity)
	pass

func get_player_input(input):
	pass


func get_player_direction():
	player_direction.x = Input.get_action_strength(input_move_right) - Input.get_action_strength(input_move_left)
	
func apply_gravity():
	player_velocity.y += GRAVITY;
	player_velocity.y = min(player_velocity.y, MAX_FALL_SPEED)

func apply_friction():
	player_velocity.x = move_toward(player_velocity.x, 0, GROUND_FRICTION)

func apply_acceleration(direction):
	player_velocity.x = move_toward(player_velocity.x, MAX_SPEED * direction.x, ACCELERATION)

func make_player_move_horizontal(direction):
	#When pressing nothing, grind to a halt
	if direction == 0:
		apply_friction()
		player_animated_sprite.animation = "Idle"
	#When pressing something, accelerate in the input direction
	else:
		apply_acceleration(player_direction)
		player_animated_sprite.animation = "Run"
		
		#Face the direction of movement. Horizontal symmetry
		if direction > 0:
			player_animated_sprite.flip_h = true
		else:
			player_animated_sprite.flip_h = false
			
func make_player_jump():
	
	if is_on_floor() or coyote_time.time_left > 0:
		if Input.is_action_just_pressed(input_jump):
			fast_fall = false
			player_velocity.y = JUMP_FORCE
	else:
		player_animated_sprite.animation = "Jump"
		if Input.is_action_just_released(input_jump) and player_velocity.y < JUMP_FORCE / 2:
			player_velocity.y = JUMP_FORCE / 2
		
		if player_velocity.y > 0 and !fast_fall:
			player_velocity.y += FAST_FALL_SPEED
			fast_fall = true
			
	has_player_landed()
	
func has_player_landed():
	#Contrôle si le joueur a atteint le sol et reset les animations
	var was_in_air = not is_on_floor()
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		player_animated_sprite.animation = "Run"
		player_animated_sprite.frame = 1
