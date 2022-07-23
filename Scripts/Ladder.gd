extends Area2D

class_name Ladder

onready var path2d = $Path2D as Path2D
onready var path_follow = $Path2D/PathFollow2D as PathFollow2D
onready var remote_transform = $Path2D/PathFollow2D/RemoteTransform2D as RemoteTransform2D

export(float) var CLIMB_SPEED = 0.2
export(float) var FALL_SPEED = 0.5

func find_closet_point_for_player(player):
	# trouve le point le plus proche sur le chemin pour le joueur
	var first_point = path2d.curve.get_point_position(0) + path2d.global_position
	var last_point = path2d.curve.get_point_position(1) + path2d.global_position
	var closest_point = Geometry.get_closest_point_to_segment_2d(player.global_position, first_point, last_point)
	
	# convertit le point en unité relative (entre 0 et 1)
	var distance_segment = first_point.distance_to(last_point)
	var distance_player = closest_point.distance_to(last_point)
	var closest_point_unit = 1 - distance_player / distance_segment
	
	path_follow.unit_offset = closest_point_unit

func climb(player, delta: float):
	remote_transform.remote_path = player.get_path()
	path_follow.unit_offset = clamp(path_follow.unit_offset + CLIMB_SPEED * delta, 0, 1) # ne pas oublier de CLAMPER

func fall(player, delta: float):
	remote_transform.remote_path = player.get_path()
	path_follow.unit_offset = clamp(path_follow.unit_offset - FALL_SPEED * delta, 0, 1) # ne pas oublier de CLAMPER

func leave():
	remote_transform.remote_path = ""
