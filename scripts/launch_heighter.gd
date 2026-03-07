extends Control

@onready var reticle := $Targeting/TextureRect

@onready var top_left := $Targeting/TopLeft
@onready var bottom_right := $Targeting/BottomRight

var speed := 0.0
var max := 500.0

@onready var raw_position = reticle.position

var cells : Array[Vector2] = []
var closest

var final_height := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#InteractionManager.start_modal_interaction(self)

	var diff = (bottom_right.position - top_left.position) / (5.0 - 1)

	for j in range(5):
		cells.append(top_left.position + Vector2(0, j * diff.y))
		if DoodadState.height == j:
			closest = cells.back()
			reticle.position = closest
			raw_position = reticle.position
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not self.visible:
		return
		
	#reticle.position = lerp(top_left.position, bottom_right.position, abs(sin(Time.get_ticks_msec() / 100.0)))
	var dir = Input.get_axis("ui_up", "ui_down")
	if abs(dir) > 0.0:
		speed = lerp(speed, max, delta)
		raw_position += speed * delta * dir * Vector2.DOWN
	else:
		speed = 0.0
		
	raw_position.y = clamp(raw_position.y, bottom_right.position.y, top_left.position.y)
		
	var dist = 10000.0
	for i in range(len(cells)):
		var c = cells[i]
		var d = c.distance_squared_to(raw_position)
		if d < dist:
			closest = c
			dist = d
			final_height = i
			
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
