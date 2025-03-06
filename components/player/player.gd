extends RigidBody3D

@export var jump_height : float = 2.5
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.35

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@export var base_speed = 4.5
@export var run_speed = 8.0

@onready var visual_root = %VisualRoot
@onready var godot_plush_skin = $VisualRoot/GodotPlushSkin
@onready var movement_dust = %MovementDust
@onready var foot_step_audio = %FootStepAudio
@onready var impact_audio = %ImpactAudio
@onready var wave_audio = %WaveAudio
@onready var collision_shape_3d = %CollisionShape3D

const JUMP_PARTICLES_SCENE = preload("./vfx/jump_particles.tscn")
const LAND_PARTICLES_SCENE = preload("./vfx/land_particles.tscn")

var movement_input : Vector2 = Vector2.ZERO
var target_angle : float = 0.0
var last_movement_input : Vector2 = Vector2.ZERO

var ragdoll : bool = false : set = _set_ragdoll

var _is_on_floor : bool = false
var _was_on_floor : bool = false

# The “_integrate_forces” method is a quick translation of the integration of the character's body movements.
# This code is not optimal; perhaps “move_and_collide” should be used to check is_on_floor.

func _set_ragdoll(value : bool) -> void:
	ragdoll = value
	collision_shape_3d.set_deferred("disabled", ragdoll)
	godot_plush_skin.ragdoll = ragdoll
	linear_velocity = Vector3.ZERO

func _ready():
	godot_plush_skin.waved.connect(wave_audio.play)
	godot_plush_skin.footstep.connect(func(intensity : float = 1.0):
		foot_step_audio.volume_db = linear_to_db(intensity)
		foot_step_audio.play()
		)

func _unhandled_input(event):
	if event.is_action_pressed("ragdoll"):
		ragdoll = !ragdoll

	if (event.is_action_pressed("wave")
		&& _is_on_floor
		&& !godot_plush_skin.is_waving()):
		godot_plush_skin.wave()

func _integrate_forces(state : PhysicsDirectBodyState3D):
	if ragdoll: return
	var camera : Camera3D = get_viewport().get_camera_3d()
	if camera == null: return
	var is_waving : bool = godot_plush_skin.is_waving()
	movement_input = Input.get_vector("left", "right", "up", "down").rotated(-camera.global_rotation.y)
	var is_running : bool = Input.is_action_pressed("run")
	var vel_2d = Vector2(state.linear_velocity.x, state.linear_velocity.z)
	var is_moving : bool = movement_input != Vector2.ZERO && !is_waving

	if is_moving:
		godot_plush_skin.set_state("run" if is_running else "walk")
		var speed = run_speed if is_running else base_speed
		vel_2d += movement_input * speed * 8.0 * state.step
		vel_2d = vel_2d.limit_length(speed)
		state.linear_velocity.x = vel_2d.x
		state.linear_velocity.z = vel_2d.y
		target_angle = -movement_input.orthogonal().angle()
	else:
		godot_plush_skin.set_state("idle")

	visual_root.rotation.y = rotate_toward(visual_root.rotation.y, target_angle, 6.0 * state.step)
	var angle_diff = angle_difference(visual_root.rotation.y, target_angle)
	godot_plush_skin.tilt = move_toward(godot_plush_skin.tilt, angle_diff, 2.0 * state.step)

	_is_on_floor = _get_is_on_floor(state)

	movement_dust.emitting = is_moving && is_running && _is_on_floor

	# Check jump and fall 
	if _is_on_floor:
		if Input.is_action_just_pressed("jump") && !is_waving:
			godot_plush_skin.set_state("jump")
			state.linear_velocity.y = -jump_velocity

			var jump_particles = JUMP_PARTICLES_SCENE.instantiate()
			add_sibling(jump_particles)
			jump_particles.global_transform = global_transform

			do_squash_and_stretch(1.2, 0.1)
	else:
		godot_plush_skin.set_state("fall")

	# Add ground friction
	physics_material_override.friction = 0.0 if is_moving else 0.8

	# Add air damp when not moving
	if !_is_on_floor && !is_moving:
		vel_2d = vel_2d.move_toward(Vector2.ZERO, base_speed * state.step)
		linear_velocity.x = vel_2d.x
		linear_velocity.z = vel_2d.y

	# Add gravity
	var gravity = jump_gravity if state.linear_velocity.y > 0.0 else fall_gravity
	state.linear_velocity.y -= gravity * state.step
	state.linear_velocity = state.linear_velocity.limit_length(fall_gravity)

	# Add ground collision feedback
	if !_was_on_floor && _is_on_floor:
		_on_hit_floor(state.linear_velocity.y)
	_was_on_floor = _is_on_floor
	
func _get_is_on_floor(state : PhysicsDirectBodyState3D) -> bool:
	for col_idx in state.get_contact_count():
		var col_normal = state.get_contact_local_normal(col_idx)
		return col_normal.dot(Vector3.UP) > -0.5
	return false

func _on_hit_floor(y_vel : float):
	y_vel = clamp(abs(y_vel), 0.0, fall_gravity)
	var floor_impact_percent : float = y_vel / fall_gravity
	impact_audio.volume_db = linear_to_db(remap(floor_impact_percent, 0.0, 1.0, 0.5, 2.0))
	impact_audio.play()
	var land_particles = LAND_PARTICLES_SCENE.instantiate()
	add_sibling(land_particles)
	land_particles.global_transform = global_transform
	do_squash_and_stretch(0.7, 0.08)

func do_squash_and_stretch(value : float, timing : float = 0.1):
	var t = create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(godot_plush_skin, "squash_and_stretch", value, timing)
	t.tween_property(godot_plush_skin, "squash_and_stretch", 1.0, timing * 1.8)
