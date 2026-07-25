extends Control

@onready var pages = [
	$Pump,
	$PressureValve,
	$FuelLoader,
	$ShellLoader,
	$CopperShell,
	
	$Pump,
	$PressureValve,
	$FuelLoader,
	$ShellLoader,
	$CopperShell,
]

var current_page = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for p in pages:
		p.visible = false
		
	pages[0].visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func next_page():
	pages[current_page].visible = false
	current_page = clamp(current_page + 1, 0, len(pages) - 1)
	pages[current_page].visible = true
	
func previous_page():
	pages[current_page].visible = false
	current_page = clamp(current_page - 1, 0, len(pages) - 1)
	pages[current_page].visible = true

func can_next():
	return current_page + 1 < len(pages)
	
func can_prev():
	return current_page - 1 >= 0
