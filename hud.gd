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
	$CenterContainer/Label.text = "\n\n" + text
	if desc != "":
		$CenterContainer/Label2.text = "\n\n\n\n\n\n-" + desc + "-"
	else:
		$CenterContainer/Label2.text = ""
	
