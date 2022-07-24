extends KinematicBody2D

class_name Player

#Variable de vitesse horizontale du personnage joueur, modifiable dans l'éditeur
export(int) var PUSH_SPEED = 100
export(int) var PULL_SPEED = 20
export(int) var MAX_SPEED = 200
export(int) var ACCELERATION = 200
export(int) var GROUND_FRICTION = 200

#Variables de vitesse verticale du personnage joueur, modifiable dans l'éditeur
export(int) var JUMP_FORCE = -150
export(int) var MAX_FALL_SPEED = 500
export(int) var FAST_FALL_SPEED = 200
export(int) var GRAVITY = 5
export(int) var CLIMB_UP_SPEED = 100
export(int) var CLIMB_DOWN_SPEED = 200
export(int) var CLIMB_FALL_SPEED = 100

export(int) var WALL_DETECTION_DISTANCE = 15

#Variable pour stocker l'animation du joueur
onready var player_animated_sprite = $AnimatedSprite

#Variable pour stocker les minuteurs joueur
onready var coyote_time = $CoyoteTimeTimer
onready var jump_buffer = $JumpBufferTimer

#Variables pour vérifier les collisions avec le sol et les objets/murs
onready var wall_raycast = $WallRaycast as RayCast2D
onready var ground_raycast = $GroundRaycast as RayCast2D

#Variables pour stocker l'état du joueur
enum STATE { IDLE, RUN, JUMP, PUSH, PULL, CLIMB_UP, CLIMB_DOWN }
var state = STATE.IDLE

#Variable pour stocker les bouttons du joueur, facile à changer pour plus tard
var input_move_right = "move_right"
var input_move_left = "move_left"
var input_jump = "move_jump"
var input_move_down = "move_down"
var input_move_up = "move_up"
var input_pull_object = "pull_object"

var player_direction = Vector2.ZERO
var player_velocity = Vector2.ZERO
var fast_fall = false
var pull_object = null
var ladder_object = null

####################################################################################################

func _ready():
	wall_raycast.cast_to.x = -WALL_DETECTION_DISTANCE

func _process(_delta):
	_state()
	_animate()

func _state():
	if is_on_ladder():
		if player_direction.y > 0:
			state = STATE.CLIMB_DOWN
		elif player_direction.y < 0:
			state = STATE.CLIMB_UP
	elif pull_object:
		state = STATE.PULL
	elif wall_raycast.is_colliding() and player_direction.x != 0:
		state = STATE.PUSH
	elif not is_on_floor():
		state = STATE.JUMP
	elif is_zero_approx(player_velocity.x):
		state = STATE.IDLE
	else:
		state = STATE.RUN

func _animate():
	var animation_state = STATE.keys()[state].to_lower()
	player_animated_sprite.animation = animation_state
	
	player_facing_direction()

func _physics_process(delta):
	get_player_direction()
	apply_gravity()
	
	make_player_move_horizontal(player_direction.x)
	make_player_move_vertical()
	
	make_player_pull_object()
	make_player_climb_ladder(delta)
	
	player_velocity = move_and_slide(player_velocity, Vector2.UP)

####################################################################################################

func get_player_direction():
	player_direction.x = Input.get_action_strength(input_move_right) - Input.get_action_strength(input_move_left)
	player_direction.y = Input.get_action_strength(input_move_down) - Input.get_action_strength(input_move_up)

func apply_gravity():
	#On annule la gravité sur le joueur est sur une échelle (s'il grimpe)
	if is_on_ladder() and (state == STATE.CLIMB_UP or state == STATE.CLIMB_DOWN):
		player_velocity.y = 0
	else:
		player_velocity.y += GRAVITY;
		player_velocity.y = min(player_velocity.y, MAX_FALL_SPEED)

func apply_friction():
	player_velocity.x = move_toward(player_velocity.x, 0, GROUND_FRICTION)

func apply_acceleration(direction):
	var speed = MAX_SPEED
	if state == STATE.PUSH:
		speed = PUSH_SPEED
	elif state == STATE.PULL:
		speed = PULL_SPEED
	
	player_velocity.x = move_toward(player_velocity.x, speed * direction, ACCELERATION)

func make_player_move_horizontal(direction):
	if direction == 0:
		apply_friction()
	else:
		if is_on_ladder():
			ladder_object.leave()
		
		apply_acceleration(direction)
		
		#On pousse l'objet si on n'est pas sur l'objet lui-même
		if state == STATE.PUSH:
			var push_object = wall_raycast.get_collider()
			if push_object and push_object.is_in_group("pushable") and not is_on_something():
				push_object.slide(player_velocity)
		elif state == STATE.PULL:
			pull_object.slide(player_velocity)

func make_player_move_vertical():
	if (is_on_floor() and state != STATE.PULL) or (is_on_ladder() and (state == STATE.CLIMB_UP or state == STATE.CLIMB_DOWN)):
		if Input.is_action_just_pressed(input_jump):
			if ladder_object:
				ladder_object.leave()
				ladder_object = null
				player_velocity.y = CLIMB_FALL_SPEED
			fast_fall = false
			player_velocity.y = JUMP_FORCE
	else:
		if Input.is_action_just_released(input_jump) and player_velocity.y < JUMP_FORCE / 2:
			player_velocity.y = JUMP_FORCE / 2
		
		if player_velocity.y > 0 and !fast_fall:
			player_velocity.y += FAST_FALL_SPEED
			fast_fall = true
			
	has_player_landed()

func is_on_something():
	var ground = ground_raycast.get_collider()
	return ground and (ground.is_in_group("pushable") or ground.is_in_group("pushable"))

func make_player_pull_object():
	#Action pour permettre de tirer un objet
	if Input.is_action_just_pressed(input_pull_object) and pull_object:
		pull_object = null
	
	elif Input.is_action_just_pressed(input_pull_object) and not is_on_something():
		var collider = wall_raycast.get_collider()
		if wall_raycast.is_colliding() and collider.is_in_group("pullable"):
			pull_object = wall_raycast.get_collider()

func make_player_climb_ladder(delta):
	if is_on_ladder():
		if state != STATE.CLIMB_UP and state != STATE.CLIMB_DOWN:
			ladder_object.find_closet_point(global_position)
		
		if Input.is_action_pressed("move_up"):
			ladder_object.climb(self, CLIMB_UP_SPEED * delta)
		elif Input.is_action_pressed("move_down"):
			ladder_object.fall(self, CLIMB_DOWN_SPEED * delta)

func has_player_landed():
	#Contrôle si le joueur a atteint le sol et reset les animations
	var was_in_air = not is_on_floor()
	
	var just_landed = is_on_floor() and was_in_air
	
	if just_landed:
		player_animated_sprite.frame = 1

func player_facing_direction():
	if player_velocity.x > 0:
		player_animated_sprite.flip_h = true
		wall_raycast.cast_to.x = WALL_DETECTION_DISTANCE
	elif player_velocity.x < 0:
		player_animated_sprite.flip_h = false
		wall_raycast.cast_to.x = -WALL_DETECTION_DISTANCE

####################################################################################################

func _on_DetectLadder_area_entered(area):
	if area is Ladder:
		ladder_object = area
		ladder_object.find_closet_point(global_position)

func _on_DetectLadder_area_exited(_area):
	if ladder_object:
		ladder_object.leave()
		ladder_object = null
		player_velocity.y = CLIMB_FALL_SPEED

func is_on_ladder():
	return ladder_object != null
