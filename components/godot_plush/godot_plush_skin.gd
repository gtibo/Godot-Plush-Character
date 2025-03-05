extends Node3D

@onready var godot_plush_mesh = $GodotPlushModel/Rig/Skeleton3D/GodotPlushMesh
@onready var physical_bone_simulator_3d = %PhysicalBoneSimulator3D
@onready var animation_tree : AnimationTree = %AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")

@export var ragdoll : bool = false : set = _set_ragdoll
var tilt : float = 0.0 : set = _set_tilt
var squash_and_stretch = 1.0 : set = _set_squash_and_stretch

signal footstep(intensity : float)
signal waved

func _ready():
	_set_ragdoll(ragdoll)

func _set_ragdoll(value : bool) -> void:
	ragdoll = value
	if !is_inside_tree(): return
	physical_bone_simulator_3d.active = ragdoll
	animation_tree.active = !ragdoll
	if ragdoll:
		physical_bone_simulator_3d.physical_bones_start_simulation()
	else:
		physical_bone_simulator_3d.physical_bones_stop_simulation()

func _set_tilt(value : float) -> void:
	tilt = clamp(value, -1.0, 1.0)
	animation_tree.set("parameters/AddTilt/add_amount", abs(tilt))
	animation_tree.set("parameters/TiltAmount/blend_position", tilt)

func set_state(state_name : String) -> void:
	state_machine.travel(state_name)

func wave() -> void:
	waved.emit()
	animation_tree.set("parameters/WaveOneShot/request", true)

func is_waving() -> bool:
	return animation_tree.get("parameters/WaveOneShot/active")

func _set_squash_and_stretch(value : float) -> void:
	squash_and_stretch = value
	var negative = 1.0 + (1.0 - squash_and_stretch)
	godot_plush_mesh.scale = Vector3(negative, squash_and_stretch, negative)

func emit_footstep(intensity : float = 1.0) -> void:
	footstep.emit(intensity)
