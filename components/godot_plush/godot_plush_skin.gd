extends Node3D

@onready var animation_tree : AnimationTree = %AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")

@export var squash_and_stretch = 1.0 : set = _set_squash_and_stretch

signal footstep(intensity : float)

var tilt : float = 0.0 : set = _set_tilt

func _set_tilt(value : float):
	tilt = clamp(value, -1.0, 1.0)
	animation_tree.set("parameters/TiltAmount/blend_position", tilt)

func set_state(state_name : String) -> void:
	state_machine.travel(state_name)

func _set_squash_and_stretch(value : float):
	squash_and_stretch = value
	var negative = 1.0 + (1.0 - squash_and_stretch)
	scale = Vector3(negative, squash_and_stretch, negative)

func emit_footstep(intensity : float = 1.0):
	footstep.emit(intensity)
