extends Control
class_name HUD

var messages : Array[String] = []
var current_message := -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.register_hud(self)
	self.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_message >= 0 and Input.is_action_just_pressed("radio_ack"):
		current_message += 1
		
		if current_message < len(messages):
			$Radio/Text.text = messages[current_message]
		else:
			current_message = -1
			self.hide()
		

func display_messages(messages: Array[String]):
	self.show()
	
	self.messages = messages
	current_message = 0
	
	$Radio/Text.text = self.messages[current_message]

func is_finished():
	return current_message == -1
