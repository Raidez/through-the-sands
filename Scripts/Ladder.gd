extends Area2D

class_name Ladder

onready var path2d = $Path2D as Path2D
onready var path_follow = $Path2D/PathFollow2D as PathFollow2D
onready var remote_transform = $Path2D/PathFollow2D/RemoteTransform2D as RemoteTransform2D

var upper_point: Vector2
var bottom_point: Vector2
var direction = 1

func _ready():
	#On récupère le 1er et dernier point
	var last_index = path2d.curve.get_point_count() - 1
	var first_point = path2d.curve.get_point_position(0) + path2d.global_position
	var last_point = path2d.curve.get_point_position(last_index) + path2d.global_position
	
	#On détermine le point le plus haut et le plus bas
	if first_point.y < last_point.y:
		upper_point = first_point
		bottom_point = last_point
	else:
		upper_point = last_point
		bottom_point = first_point
	
	#On récupère la distance entre le follow et le point le plus bas
	var follow_point = path_follow.position +  + path2d.global_position
	var distance_follow = follow_point.distance_to(bottom_point)
	
	#On détermine alors la valeur pour monter/descendre
	if distance_follow <= 1:
		path_follow.unit_offset = 0
		direction = 1
	else:
		path_follow.unit_offset = 1
		direction = -1

func find_closet_point(player_point: Vector2):
	#Trouve le point le plus proche sur le chemin pour le joueur
	var closest_point = Geometry.get_closest_point_to_segment_2d(player_point, upper_point, bottom_point)

	#Convertit le point en unité relative (entre 0 et 1)
	var distance_segment = upper_point.distance_to(bottom_point)
	var distance_player = closest_point.distance_to(bottom_point)
	var closest_point_unit = distance_player / distance_segment
	if direction < 0:
		closest_point_unit = 1 - closest_point_unit

	path_follow.unit_offset = closest_point_unit

func climb(player, speed: float):
	remote_transform.remote_path = player.get_path()
	path_follow.offset += direction * speed

func fall(player, speed: float):
	remote_transform.remote_path = player.get_path()
	path_follow.offset -= direction * speed

func leave():
	remote_transform.remote_path = ""
