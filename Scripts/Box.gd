extends KinematicBody2D

class_name Box

#Variable de vitesse horizontale du personnage joueur, modifiable dans l'éditeur
export(int) var GROUND_FRICTION = 600

#Variables de vitesse verticale du personnage joueur, modifiable dans l'éditeur
export(int) var GRAVITY = 5
export(int) var MAX_FALL_SPEED = 500

var velocity = Vector2.ZERO
var trigger_friction = true

func _physics_process(delta):
	if not is_on_floor():
		apply_gravity()
	
	if trigger_friction:
		apply_friction(delta)
	velocity = move_and_slide(velocity, Vector2.UP)

func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, GROUND_FRICTION * delta)

func apply_gravity():
	velocity.y += GRAVITY;
	velocity.y = min(velocity.y, MAX_FALL_SPEED)

func slide(vector: Vector2):
	velocity.x = vector.x
	trigger_friction = false

func _on_Timer_timeout():
	trigger_friction = true
