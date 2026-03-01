extends Node3D

var active := false
var overheating := false

var can_overheat = true

@onready var timer = $Timer

@export var lights: Array[OmniLight3D] = []
var start_time := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.cat = self
	timer.timeout.connect(_on_overheat)
	
	for l in lights:
		l.light_energy = 0.0
	
func _process(delta: float):
	if active and overheating:
		start_time += delta
		for l in lights:
			var t = (sin(2 * start_time + PI * 3 / 2) + 1) / 2.0
			l.light_energy = lerp(0.0, 5.0, t)
			
	if not can_overheat:
		overheating = false

func activate():
	if not active:
		active = true
		timer.start(randi_range(30, 60))
		
func deactivate():
	active = false
	timer.stop()

func is_good():
	return not active or not overheating
	
func _on_overheat():
	if not can_overheat:
		return
		
	Game.hud.display_messages(Game.story.cat_overheating())
	overheating = true
	start_time = 0.0

func start_interaction():
	if active and overheating:
		overheating = false
		timer.start(randi_range(30, 60))
		
		for l in lights:
			l.light_energy = 0.0
			

func target_text():
	if overheating:
		Game.hud.set_target("C.A.T.", "Whisper to C.A.T.")
	else:
		Game.hud.set_target("C.A.T.", "")
