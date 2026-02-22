extends Control

@onready var main_buttons = $CanvasGroup3/Control/PanelContainer/MarginContainer/VBoxContainer
@onready var menu_buttons = $CanvasGroup3/Control/PanelContainer/MarginContainer/VBoxContainer2

@onready var target = $CanvasGroup3/Target
@onready var height = $CanvasGroup3/Height

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_buttons.show()
	menu_buttons.hide()
	target.hide()
	height.hide()
	
	InteractionManager.start_modal_interaction(self)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func stop_interaction():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed(name: String) -> void:
	match name:
		"target":
			target.show()
			menu_buttons.show()
			main_buttons.hide()
		"height":
			height.show()
			menu_buttons.show()
			main_buttons.hide()
		"confirm":
			if height.visible:
				DoodadState.height = height.final_height
				print("FINAL HEIGHT ", DoodadState.height)
			elif target.visible:
				DoodadState.coordinates = target.final_coord
				print("FINAL COORDS ", DoodadState.coordinates)
			
			target.hide()
			height.hide()
			menu_buttons.hide()
			main_buttons.show()
		"cancel":
			target.hide()
			height.hide()
			menu_buttons.hide()
			main_buttons.show()
		"exit":
			stop_interaction()
