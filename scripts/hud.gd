extends Control
class_name HUD

var messages : Array[String] = []
var current_message := -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.register_hud(self)
	$Radio.hide()
	set_target("")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_message >= 0 and Input.is_action_just_pressed("radio_ack"):
		current_message += 1
		
		if current_message < len(messages):
			$Radio/Box/Text.text = messages[current_message]
		else:
			messages = []
			current_message = -1
			$Radio.hide()
		
	if current_message < len(messages) - 1:
		$Radio/Label/AckNot.modulate = Color(1, 1, 1, sin(Time.get_ticks_msec() / 100))
	$Radio/Label/AckNot.visible = current_message >= 0 and current_message < len(messages) - 1

func display_messages(messages: Array[String]):
	$Radio.show()
	
	if self.messages.is_empty():
		self.messages = messages
		current_message = 0
	
		$Radio/Box/Text.text = self.messages[current_message]
	else:
		self.messages.append_array(messages)

func is_finished():
	return current_message == -1
	
func set_target(text = "", desc = ""):
	if text == "" and desc == "":
		$CenterContainer/Control/MarginContainer/VBoxContainer/Label.hide()
		$CenterContainer/Control/MarginContainer/VBoxContainer/Label2.hide()
	else:
		$CenterContainer/Control/MarginContainer/VBoxContainer/Label.show()
		$CenterContainer/Control/MarginContainer/VBoxContainer/Label2.show()
		
		$CenterContainer/Control/MarginContainer/VBoxContainer/Label.text = text
		if desc != "":
			$CenterContainer/Control/MarginContainer/VBoxContainer/Label2.text = "-" + desc + "-"
		else:
			$CenterContainer/Control/MarginContainer/VBoxContainer/Label2.hide()
			$CenterContainer/Control/MarginContainer/VBoxContainer/Label2.text = ""
	
