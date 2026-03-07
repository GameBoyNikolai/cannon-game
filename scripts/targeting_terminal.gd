extends Control

@onready var reticle := $Targeting/Control

@onready var top_left := $Targeting/TopLeft
@onready var bottom_right := $Targeting/BottomRight

var speed := 0.0
var max := 500.0

@onready var raw_position = reticle.position

var cells : Array[Vector2] = []
var cell_coords : Array[Vector2i] = []
var closest

var final_coord := Vector2i.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#InteractionManager.start_modal_interaction(self)

	var diff = (bottom_right.position - top_left.position) / (5.0 - 1)

	for i in range(8):
		for j in range(5):
			cells.append(top_left.position + Vector2(i * diff.x, j * diff.y))
			cell_coords.append(Vector2i(i, j))
			
			if DoodadState.coordinates == Vector2i(i, j):
				closest = cells.back()
				reticle.position = closest
				raw_position = reticle.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not self.visible:
		return
	
	#reticle.position = lerp(top_left.position, bottom_right.position, abs(sin(Time.get_ticks_msec() / 100.0)))
	var dirs = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dirs.length_squared() > 0.0:
		speed = lerp(speed, max, delta)
		raw_position += speed * delta * dirs
	else:
		speed = 0.0
		
	raw_position.y = clamp(raw_position.y, top_left.position.y, bottom_right.position.y)
	
	var diff = (bottom_right.position - top_left.position) / (5.0 - 1)
	raw_position.x = clamp(raw_position.x, top_left.position.x, bottom_right.position.x + 3 * diff.x)

		
	var dist = 10000.0
	for i in range(len(cells)):
		var c = cells[i]
		var d = c.distance_squared_to(raw_position)
		if d < dist:
			closest = c
			dist = d
			final_coord = cell_coords[i]
			
	if speed < 100.0:
		reticle.position = lerp(reticle.position, closest, 0.01)
		raw_position = reticle.position
	else:
		reticle.position = raw_position
	
func exit():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()
	
func stop_interaction():
	exit()
