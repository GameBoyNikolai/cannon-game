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
		$click.play()
		if current_message < len(messages):
			$Radio/Box/Text.text = messages[current_message]
		else:
			messages = []
			current_message = -1
			$Radio.hide()
		
	if current_message < len(messages) - 1:
		$Radio/Label/AckNot.modulate = Color(1, 1, 1, sin(Time.get_ticks_msec() / 100))
	$Radio/Label/AckNot.visible = current_message >= 0 and current_message < len(messages) - 1
	
	$Timer.hide()
	if Game.cat.overheating:
		var seconds = round(10.0 * max(20.0 - Game.cat.start_time, 0.0)) / 10.0
		$Timer.show()
		$Timer.text = str(seconds) + "s"
		
	#if Input.is_action_just_pressed("ui_cancel"):
		#game_over()
		
func click_sound():
	$click.play()

func display_messages(messages: Array[String]):
	$Radio.show()
	
	$message.play()
	
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
	
func game_over():
	$Radio.hide()
	
	var fade = func(t: float):
		$ColorRect.color = Color(lerp(Color.RED, Color.BLACK, t), t)
	
	var tween = create_tween()
	tween.tween_method(fade, 0.0, 1.0, 2.0) 
	
	await tween.finished
	
	$ColorRect/Label.show()
	
	await get_tree().create_timer(3.0).timeout
	
	get_tree().change_scene_to_file("res://scenes/start.tscn")

func game_finish(good):
	display_messages(Game.story.game_end(good))
	
	await get_tree().create_timer(5.0).timeout
	
	var fade = func(t: float):
		$ColorRect.color = Color(lerp(Color.DIM_GRAY if good else Color.RED, Color.BLACK, t), t)
	
	if not good:
		_CameraShake3D._custom_shake(0.2, 5)
	
	var tween = create_tween()
	tween.tween_method(fade, 0.0, 1.0, 2.0) 
	
	await get_tree().create_timer(10.0).timeout
	
	get_tree().change_scene_to_file("res://scenes/start.tscn")
	
