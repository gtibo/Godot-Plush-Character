extends RigidBody3D

var mat_list : Array[Material] = [preload("res://assets/materials/green_mat.tres"), preload("res://assets/materials/red_mat.tres"), preload("res://assets/materials/yellow_mat.tres"), preload("res://assets/materials/blue_mat.tres")]
@onready var mesh : MeshInstance3D = %Mesh
@onready var collision : CollisionShape3D = %Collision

func _ready():
	var size = randf_range(0.5, 0.8)
	mesh.material_override = mat_list.pick_random()
	mesh.scale *= size
	collision.shape.radius = size / 2.0
