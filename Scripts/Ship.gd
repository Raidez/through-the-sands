extends KinematicBody2D

#Variable de vitesse horizontale du personnage joueur, modifiable dans l'éditeur
export(int) var GROUND_FRICTION = 200

#Variables de vitesse verticale du personnage joueur, modifiable dans l'éditeur
export(int) var GRAVITY = 5
export(int) var MAX_FALL_SPEED = 200

var ship_velocity = Vector2.ZERO

func _physics_process(delta):
	if not is_on_floor():
		apply_gravity()
	
	ship_velocity = move_and_slide(ship_velocity, Vector2.UP)
	print(ship_velocity)

func apply_gravity():
	ship_velocity.y += GRAVITY;
	ship_velocity.y = min(ship_velocity.y, MAX_FALL_SPEED)

func slide(vector: Vector2):
	ship_velocity.x = vector.x
