extends Marker3D

@export var spawnable_objects : Array[PackedScene]
@export var size : Vector3

@export var max_spawnable : int = 300
@export var local_velocity : Vector3 = Vector3.ZERO

var spawned_objects : int = 0
var time_stamp : int = 0

func _process(_delta):
	var now = Time.get_ticks_msec()
	var diff = (now - time_stamp)
	if diff < 30: return
	
	_spawn()
	time_stamp = Time.get_ticks_msec()

	if spawned_objects >= max_spawnable: set_process(false)

func _spawn():
	var spawn_node = spawnable_objects.pick_random()
	var node : Node3D = spawn_node.instantiate()
	add_sibling.call_deferred(node)
	var offset : Vector3 = Vector3.ZERO

	if size != Vector3.ZERO:
		offset = Vector3(
		randf_range(-size.x, size.x),
		randf_range(-size.y, size.y),
		randf_range(-size.z, size.z),
		)
	
	node.position = position + offset
	
	spawned_objects += 1

	await get_tree().physics_frame
	if node is RigidBody3D:
		node.apply_central_impulse(quaternion * local_velocity)
