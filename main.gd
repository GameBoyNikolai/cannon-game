extends Node3D

@onready var hud_scn = preload("res://hud.tscn")

@export var terminal : Node3D = null

var hud : Control = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud = hud_scn.instantiate()
	add_child(hud)
	hud.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
