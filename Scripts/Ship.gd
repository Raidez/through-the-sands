extends KinematicBody2D

#Variable de vitesse horizontale du personnage joueur, modifiable dans l'éditeur
export(int) var GROUND_FRICTION = 600

#Variables de vitesse verticale du personnage joueur, modifiable dans l'éditeur
export(int) var GRAVITY = 5
export(int) var MAX_FALL_SPEED = 500

var ship_velocity = Vector2.ZERO
var trigger_friction = true

func _physics_process(delta):
	if not is_on_floor():
		apply_gravity()
	
	if trigger_friction:
		apply_friction(delta)
	ship_velocity = move_and_slide(ship_velocity, Vector2.UP)

func apply_friction(delta):
	ship_velocity.x = move_toward(ship_velocity.x, 0, GROUND_FRICTION * delta)

func apply_gravity():
	ship_velocity.y += GRAVITY;
	ship_velocity.y = min(ship_velocity.y, MAX_FALL_SPEED)

func slide(vector: Vector2):
	ship_velocity.x = vector.x
	trigger_friction = false

func _on_Timer_timeout():
	trigger_friction = true
