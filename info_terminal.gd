extends Control

@onready var menus = [$CanvasGroup/PanelContainer/VBoxContainer/StartMenu, $CanvasGroup/PanelContainer/VBoxContainer/BackMenu, $CanvasGroup/PanelContainer/VBoxContainer/NavMenu]
@onready var content = $CanvasGroup/PanelContainer/VBoxContainer/Label

@onready var original_text = content.text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_menu($CanvasGroup/PanelContainer/VBoxContainer/StartMenu)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	InteractionManager.start_modal_interaction(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		exit()

func exit():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()

func show_menu(menu):
	for m in menus:
		m.hide()
		
	menu.show()


func _on_button_pressed(b: String) -> void:
	match b:
		"Task":
			show_menu($CanvasGroup/PanelContainer/VBoxContainer/BackMenu)
			content.text = "> Current Task:\nShoot"
		"Back":
			show_menu($CanvasGroup/PanelContainer/VBoxContainer/StartMenu)
			content.text = original_text
		"Protocol":
			show_menu($CanvasGroup/PanelContainer/VBoxContainer/NavMenu)
			content.text = "> Long Range"
		"Exit":
			exit()
		"Prev":
			pass
		"Next":
			pass
