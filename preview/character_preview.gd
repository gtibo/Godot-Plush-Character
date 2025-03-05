extends Node3D

@onready var option_button : OptionButton = %OptionButton
@onready var character_root = %CharacterRoot
@onready var godot_plush_skin = %GodotPlushSkin
@onready var grid = %Grid

var is_pressed : bool = false

var states = ["idle", "walk", "run", "jump"]

var grid_speed : Dictionary = {
	"walk": 0.6,
	"run": 0.8,
}

func _unhandled_input(event):
	if event is InputEventMouseButton:
		is_pressed = event.pressed
	if event is InputEventMouseMotion && is_pressed:
		character_root.rotation.y += event.screen_relative.x * 0.005

func _ready():
	for state in states:
		option_button.add_item(state)
	option_button.selected = 0
	option_button.item_selected.connect(func(idx : int):
		godot_plush_skin.set_state(states[idx])
		
		var speed : float = 0.0
		if grid_speed.has(states[idx]): speed = grid_speed[states[idx]]
		grid.material_override.set_shader_parameter("speed_factor", speed)
		)
