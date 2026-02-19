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
	
	"overclock": [
		PressureState.new().init(2),
	],
	
	"delayed_fuse": [
		ButtonState.new().init(true, true, false)
	],
	
	"vacuum": [
		PressureState.new().init(-2),
		KeyState.new().init(2, -1, 0)
	],
	
	"homing": [
		ButtonState.new().init(true, false, true),
		KeyState.new().init(1, 2, -1)
	],
	
	"large_missile": [
		MissileState.new().init(2)
	]
}

var ingredient_descs : Dictionary[String, String] = {
	"med_range": "- Pressure Valve at +1 atm\n- Thruster control buttons Blue only",
	"short_range": "- Pressure Valve at -1 atm\n- Orange Ignition Key in center socket",
	"overclock": "- Pressure Valvev at +2 atm",
	"delayed_fuse": "- Thruster control buttons Green and Orange",
	"vacuum": "- Pressure Valve at -2 atm\n- Orange ignition Key in center, Pink in right socket",
	"homing": "- Thruster control buttons Green and Blue\n- Blue Ignition Key in left, Orange in center",
	"large_missile": "- Large Missile Shell loaded",
}

var ingredient_names : Dictionary[String, String] = {
	"med_range": "Medium Range Thruster",
	"short_range": "Short Range Thruster",
	"overclock": "Overclocked Launch",
	"delayed_fuse": "Delayed Fuse Detonator",
	"vacuum": "Launch under Vacuum",
	"homing": "Homing System Installed",
	"large_missile": "Large Missile Shell",
}

var recipes : Array[Array] = [
	["large_missile", "med_range",],
	["large_missile", "short_range",],
	
	["large_missile", "overclock",],
	["large_missile", "overclock", "delayed_fuse"],
	["large_missile", "vacuum", "delayed_fuse"],
	["large_missile", "homing", "overclock"],
]

#var recipe_descs : Array[String] = [
	#"- Large Missile Shell\n- Short Range Thruster",
	#"- Large Missile Shell\n- Medium Range Thruster",
#]

func was_correct(current_task : int):
	var good = true
	for ingredient in recipes[current_task]:
		for state in ingredients[ingredient]:
			good = good and state.correct()
			
	return good
	
func get_recipe_description(task: int) -> String:
	var text = "> New Mission Parameters:\n\n"
	for ing in recipes[task]:
		text += "- " + ingredient_names[ing] + "\n"
		
	return text

func first_tasks():
	return [0, 1]
	
func normal_tasks():
	return [0, 1, 2, 3, 4, 5]
	
func hard_tasks():
	return []
