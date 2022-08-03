extends Resource
class_name PlayerMovementData

#Variable de vitesse horizontale du personnage joueur, modifiable dans l'éditeur
export(int) var PUSH_SPEED = 100
export(int) var PULL_SPEED = 20
export(int) var MAX_SPEED = 200
export(int) var ACCELERATION = 200
export(int) var GROUND_FRICTION = 200


#Variables de vitesse verticale du personnage joueur, modifiable dans l'éditeur
export(int) var JUMP_FORCE = -250
export(int) var MAX_FALL_SPEED = 500
export(int) var FAST_FALL_SPEED = 200
export(int) var GRAVITY = 5
export(int) var CLIMB_UP_SPEED = 100
export(int) var CLIMB_DOWN_SPEED = 200
export(int) var CLIMB_FALL_SPEED = 100
export(int) var DASH_SPEED = 1000
export(float) var DASH_LENGTH = .05

#Variables pour compter le nombres de saut et de dash. Facilite la possibilité de faire des upgrades dans le jeu
export(int) var MAX_JUMP_NUMBER = 2
export(int) var MAX_DASH_NUMBER = 1

export(int) var WALL_DETECTION_DISTANCE = 15
export(int) var PULL_PINJOINT = 12
