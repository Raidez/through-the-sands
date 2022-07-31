extends KinematicBody2D

export(Resource) var move_data = preload("res://Scripts/CustomRessource/PlayerMovementData.tres") as PlayerMovementData

#Variable pour stocker l'animation du joueur
onready var player_animated_sprite = $AnimatedSprite

#Variable pour stocker les minuteurs joueur
onready var coyote_time = $CoyoteTimeTimer
onready var jump_buffer = $JumpBufferTimer
onready var dash_timer = $DashTimer

onready var wall_raycast = $WallRaycast as RayCast2D
onready var ground_raycast = $GroundRaycast as RayCast2D

#Variables pour stocker l'état du joueur
enum STATE { IDLE, RUN, JUMP, PUSH, PULL, DASH, CLIMB }
var state = STATE.IDLE

#Variable pour stocker les bouttons du joueur, facile à changer pour plus tard
var input_move_right = "move_right"
var input_move_left = "move_left"
var input_move_up = "move_up"
var input_move_down = "move_down"
var input_move_dash = "move_dash"
var input_jump = "move_jump"
var input_pull_object = "pull_object"

var player_direction = Vector2.ZERO
var player_velocity = Vector2.ZERO
var jump_count = 0
var dash_count = 0
var is_dashing = false
var fast_fall = false
var pull_object = null
var nearest_ladder = null
var ladder_object = null

####################################################################################################

func _ready():
	wall_raycast.cast_to.x = -move_data.WALL_DETECTION_DISTANCE

func _process(delta):
	
	_state()
	_animate()

func _state():
	if is_on_ladder():
		state = STATE.CLIMB
	elif pull_object:
		state = STATE.PULL
	elif wall_raycast.is_colliding() and player_direction.x != 0:
		state = STATE.PUSH
	elif !is_zero_approx(player_velocity.y):
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
	make_player_move()
	make_player_pull_object()
	make_player_climb_ladder(delta)
	
	player_velocity = move_and_slide(player_velocity, Vector2.UP)

func get_player_direction():
	player_direction.x = Input.get_axis(input_move_left, input_move_right)
	player_direction.y = Input.get_axis(input_move_up, input_move_down)

func apply_gravity():
	if is_dashing or is_on_ladder():
		player_velocity.y = 0
	else:
		player_velocity.y += move_data.GRAVITY;
		player_velocity.y = min(player_velocity.y, move_data.MAX_FALL_SPEED)

func apply_friction():
	player_velocity.x = move_toward(player_velocity.x, 0, move_data.GROUND_FRICTION)

func apply_acceleration(direction):
	var speed = move_data.MAX_SPEED
	if state == STATE.PUSH:
		speed = move_data.PUSH_SPEED
	elif state == STATE.PULL:
		speed = move_data.PULL_SPEED
	
	player_velocity.x = move_toward(player_velocity.x, speed * direction, move_data.ACCELERATION)

func make_player_move():
	make_player_move_dash()
	
	if dash_timer.is_stopped():
		make_player_move_horizontal(player_direction.x)
		make_player_move_vertical()

func make_player_move_horizontal(direction):
	#When pressing nothing, grind to a halt
	if direction == 0:
		apply_friction()
	#When pressing something, accelerate in the input direction
	else:
		if is_on_ladder():
			ladder_object.leave()
		apply_acceleration(direction)
		
		# on pousse l'objet si on n'est pas sur l'objet lui-même
		if state == STATE.PUSH:
			var push_object = wall_raycast.get_collider()
			if push_object and push_object.is_in_group("pushable") and not is_on_something():
				push_object.slide(player_velocity)
		elif state == STATE.PULL:
			pull_object.slide(player_velocity)

func make_player_move_vertical():
	#Démarre le minuteur pour le saut, cette étape supplémentaire permet d'éviter l'impression que 
	#le jeu "mange" les inputs du joueur. Le personnage sautera même si la touche saut est utilisé
	#un peu avant d'avoir touché le sol.
	if Input.is_action_just_pressed(input_jump):
		jump_buffer.start()
	
	if (is_on_floor() and state != STATE.PULL) or (is_on_ladder() and state == STATE.CLIMB):
		jump_count = 0
		coyote_time.start()
		if !jump_buffer.is_stopped():
			make_player_jump()
	else:
		#Donne au joueur la possibilité de sauter un court instant après avoir quitté une plateforme
		#avant que la gravité ne prenne effet
		if coyote_time.is_stopped():
			apply_gravity()
			#Si il reste des sauts disponible dans le compteur de saut, permettre au joueur de sauter
			if !jump_buffer.is_stopped() and jump_count < move_data.MAX_JUMP_NUMBER:
				make_player_jump()
		elif !jump_buffer.is_stopped():
			make_player_jump()
		
		#Permet d'avoir une hauteur de saut minimum
		if Input.is_action_just_released(input_jump) and player_velocity.y < move_data.JUMP_FORCE / 2:
			player_velocity.y = move_data.JUMP_FORCE / 2
		
		#Fait chuter le joueur plus vite après un saut
		if player_velocity.y > 0 and !fast_fall:
			player_velocity.y = move_data.FAST_FALL_SPEED
			fast_fall = true
		
	
	has_player_landed()

func make_player_move_dash():
	if is_on_floor() or is_on_ladder():
		dash_count = 0
	
	if Input.is_action_just_pressed(input_move_dash) and dash_count < move_data.MAX_DASH_NUMBER and player_direction != Vector2.ZERO:
		dash_timer.start(move_data.DASH_LENGTH)
		dash_count += 1
		is_dashing = true
		player_velocity.x =  move_data.DASH_SPEED * player_direction.x
		
	if dash_timer.is_stopped():
		is_dashing = false
		if !is_on_floor():
			apply_gravity()

func make_player_jump():
	if is_on_ladder():
		leave_ladder()
	jump_count += 1
	fast_fall = false
	player_velocity.y = move_data.JUMP_FORCE
	jump_buffer.stop()
	coyote_time.stop()

func make_player_climb_ladder(delta):
	if is_close_to_ladder():
		if state != STATE.CLIMB:
			nearest_ladder.find_closet_point(global_position)
		
		if Input.is_action_pressed(input_move_up):
			ladder_object = nearest_ladder
			ladder_object.climb(self, move_data.CLIMB_UP_SPEED * delta)
		elif Input.is_action_pressed(input_move_down):
			ladder_object = nearest_ladder
			ladder_object.fall(self, move_data.CLIMB_DOWN_SPEED * delta)

func is_on_something():
	var ground = ground_raycast.get_collider()
	return ground and (ground.is_in_group("pushable") or ground.is_in_group("pushable"))

func make_player_pull_object():
	# action pour permettre de tirer un objet
	if Input.is_action_just_pressed(input_pull_object) and pull_object:
		pull_object = null
	elif Input.is_action_just_pressed(input_pull_object) and not is_on_something():
		var collider = wall_raycast.get_collider()
		if wall_raycast.is_colliding() and collider.is_in_group("pullable"):
			pull_object = wall_raycast.get_collider()
			print("Trying to pull the object")

func has_player_landed():
	#Contrôle si le joueur a atteint le sol et reset les animations
	var was_in_air = not is_on_floor()
	
	var just_landed = is_on_floor() and was_in_air
	
	if just_landed:
		player_animated_sprite.frame = 1

func player_facing_direction():
	#Face the direction of movement. Horizontal symmetry
	if player_velocity.x > 0:
		player_animated_sprite.flip_h = true
		wall_raycast.cast_to.x = move_data.WALL_DETECTION_DISTANCE
	elif player_velocity.x < 0:
		player_animated_sprite.flip_h = false
		wall_raycast.cast_to.x = -move_data.WALL_DETECTION_DISTANCE

####################################################################################################

func _on_DetectLadder_area_entered(area):
	if area is Ladder:
		nearest_ladder = area
		nearest_ladder.find_closet_point(global_position)

func _on_DetectLadder_area_exited(_area):
	leave_ladder()
	nearest_ladder = null

func is_close_to_ladder():
	return nearest_ladder != null

func is_on_ladder():
	return ladder_object != null

func leave_ladder():
	if nearest_ladder:
		nearest_ladder.leave()
	
	if ladder_object:
		ladder_object.leave()
		ladder_object = null
