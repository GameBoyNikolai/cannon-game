extends Node

class MissileState:
	var type : int = 0
	
	func init(val):
		type = val
		return self
		
	func correct():
		return type == DoodadState.missile_load_type

class PressureState:
	var pressure : int = 0
	
	func init(val):
		pressure = val
		return self
		
	func correct():
		return pressure == DoodadState.pressure_valve

class ButtonState:
	var buttons : Array[bool] = [false, false, false]
	
	func init(a, b, c):
		buttons = [a, b, c]
		return self
		
	func correct():
		for i in range(len(buttons)):
			if buttons[i] != DoodadState.buttons[i]:
				return false
		return true
		
class KeyState:
	var keys : Array[int] = [-1, -1, -1]
	
	func init(a, b, c):
		keys = [a, b, c]
		return self
		
	func correct():
		for i in range(len(keys)):
			if keys[i] != DoodadState.key_holes[i]:
				return false
		return true

class StateBag:
	var states = []	
	
	func init(states):
		self.states = states
		return null

var ingredients : Dictionary[String, Array] = {
	"long_range": [
		PressureState.new().init(1),
		ButtonState.new().init(false, false, true),
	],
	
	"short_range": [
		PressureState.new().init(-1),
		KeyState.new().init(-1, 2, -1),
	],
	
	"large_missile": [
		MissileState.new().init(2)
	]
}

var recipes : Array[Array] = [
	["long_range", "large_missile"],
	["short_range", "large_missile"],
]

var current_task : int = -1

var just_launched := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

signal launch(message: String)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_task == -1:
		# eventually need logic to choose a progression of tasks
		current_task = randi_range(0, len(recipes) - 1)
	else:
		if just_launched and DoodadState.missile_load_type != 0:
			just_launched = false
			
			if was_correct():
				launch.emit("Commander Ballari: Beautiful strike, the target was destroyed!")
			else:
				launch.emit("Commander Ballari: What in hell are you doing!? Follow the launch orders this time. Insubordinaton will necessitate... termination.")
			# need to signal that a missile is no longer loaded
			DoodadState.missile_load_type = 0
		else:
			just_launched = false
				
				
func was_correct():
	var good = true
	for ingredient in recipes[current_task]:
		for state in ingredients[ingredient]:
			good = good and state.correct()
			
	return good
