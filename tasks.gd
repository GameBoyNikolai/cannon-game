extends Node
class_name Tasks

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
	"med_range": [
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

var ingredient_descs : Dictionary[String, String] = {
	"med_range": "",
	"short_range": "",
	"large_missile": "",
}

var recipes : Array[Array] = [
	["med_range", "large_missile"],
	["short_range", "large_missile"],
]

var recipe_descs : Array[String] = [
	"- Large Missile Shell\n- Short Range Thruster",
	"- Large Missile Shell\n- Medium Range Thruster",
]

func was_correct(current_task : int):
	var good = true
	for ingredient in recipes[current_task]:
		for state in ingredients[ingredient]:
			good = good and state.correct()
			
	return good

func first_tasks():
	return [0, 1]
	
func normal_tasks():
	return []
	
func hard_tasks():
	return []
