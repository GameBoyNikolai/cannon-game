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
		
	func str():
		return "- Pressure Valve at %s%d atm" % ["+" if pressure > 0 else "-", abs(pressure)]
		
	func correct():
		return pressure == DoodadState.pressure_valve
		
class FuelState:
	var amount : int = 0
	
	func init(val):
		amount = val
		return self
		
	func str():
		return "- Pump at %d%% atm" % [amount * 10 + 30]
		
	func correct():
		return amount == DoodadState.fuel_pump

class ButtonState:
	var buttons : Array[bool] = [false, false, false]
	
	func init(a, b, c):
		buttons = [a, b, c]
		return self
		
	func str():
		return "- Thruster Control buttons | %s | %s | %s |" % [
				"on" if buttons[0] else "off",
				"on" if buttons[1] else "off",
				"on" if buttons[2] else "off",
			]
		
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
		
	func color(i):
		match i:
			-1: return "Empty"
			0: return "Pink"
			1: return "Blue"
			2: return "Orange"
		
	func str():
		return "- Ignition Keys | %s | %s | %s |" % [
				color(keys[0]),
				color(keys[1]),
				color(keys[2]),
			]
		
	func correct():
		for i in range(len(keys)):
			if keys[i] != DoodadState.key_holes[i]:
				return false
		return true


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
	#["large_missile", "med_range",],
	#["large_missile", "short_range",],
	#
	#["large_missile", "overclock",],
	#["large_missile", "overclock", "delayed_fuse"],
	#["large_missile", "vacuum", "delayed_fuse"],
	#["large_missile", "homing", "overclock"],
]

#var recipe_descs : Array[String] = [
	#"- Large Missile Shell\n- Short Range Thruster",
	#"- Large Missile Shell\n- Medium Range Thruster",
#]

#func was_correct(current_task : int):
	#var good = true
	#for ingredient in recipes[current_task]:
		#for state in ingredients[ingredient]:
			#good = good and state.correct()
			#
	#return good
	
class _ReqState:
	var states := []
	var desc := ""
	
func ReqState(states, desc):
	var rq = _ReqState.new()
	rq.states = states
	rq.desc = desc
	
	return rq
	
var shell_reqs := {
	Shell.Type.Steel: ReqState([
		PressureState.new().init(1),
	],
	""),
	
	Shell.Type.Titanium: ReqState([
		KeyState.new().init(-1, 2, -1),
		PressureState.new().init(2),
	],
	""),
	
	Shell.Type.Depth: ReqState([
		KeyState.new().init(-1, 2, 1),
		PressureState.new().init(0),
	],
	""),
}
var juice_reqs := {
	Juice.Type.AmNitrate: ReqState([
		ButtonState.new().init(false, false, true),
	],
	""),
	
	Juice.Type.Methane: ReqState([
		ButtonState.new().init(true, false, true),
		FuelState.new().init(2)
	],
	""),
	
	Juice.Type.Kerosene: ReqState([
		ButtonState.new().init(false, true, false),
		FuelState.new().init(0)
	],
	""),
}

var shell_names := {
	Shell.Type.Steel: "Copper Warhead",
	Shell.Type.Titanium: "Titanium Warhead",
	Shell.Type.Depth: "Depth Charge Warhead",
	Shell.Type.Nuclear: "Nuclear Warhead",
}
var juice_names := {
	Juice.Type.AmNitrate: "Ammonium Nitrate Propellant",
	Juice.Type.Methane: "Methane Propellant",
	Juice.Type.Kerosene: "Kerosene Propellant",
	Juice.Type.Hydrazine: "Hydrazine Propellant",
}

class Task:
	var shell: Shell.Type
	var juice: Juice.Type
	var coord: Vector2i
	var height: int
	
func make_task(shell: Shell.Type, juice: Juice.Type):
	var t = Task.new()
	t.shell = shell
	t.juice = juice
	
	return t
	
func fill_task(t: Task):
	var task = make_task(t.shell, t.juice)
	task.coord = generate_coord()
	task.height = generate_height()
	
	return task
	
func was_correct(task: Task):
	var good = true
	
	good = good and DoodadState.missile_load_type == task.shell
	good = good and DoodadState.juice_load_type == task.juice
	
	for state in shell_reqs[task.shell].states:
		good = good and state.correct()
	for state in juice_reqs[task.juice].states:
		good = good and state.correct()
			
	#good = good and DoodadState.coords == task.coords
	good = good and DoodadState.coordinates == task.coord
	good = good and (DoodadState.height == task.height or task.height == 4)
		
	return good
	
func get_recipe_description(task: Task) -> String:
	var text = "> New Mission Parameters:\n\n"
	text += "  - " + shell_names[task.shell] + "\n"
	text += "  - " + juice_names[task.juice] + "\n"
	
	var dc = to_display_coord(task.coord)
	var h = to_display_height(task.height)
	text += "  - Target Coords: %s-%s\n" % dc
	text += "  - Target Elevation: %s" % [h]
		
	return text
	
func get_shell_description(shell: Shell.Type) -> String:
	var rq = shell_reqs[shell]
	if len(rq.desc) > 0:
		return rq.desc
	else:
		var text = ""
		for s in rq.states:
			text += s.str() + "\n"
		return text
		
func get_juice_description(juice: Juice.Type) -> String:
	var rq = juice_reqs[juice]
	if len(rq.desc) > 0:
		return rq.desc
	else:
		var text = ""
		for s in rq.states:
			text += "  " + s.str() + "\n"
		return text

func first_task_stubs():
	return [
		make_task(Shell.Type.Steel, Juice.Type.AmNitrate),
		make_task(Shell.Type.Titanium, Juice.Type.AmNitrate),
	]
	
func normal_task_stubs():
	var shells = [Shell.Type.Steel, Shell.Type.Titanium, Shell.Type.Depth]
	var juices = [Juice.Type.AmNitrate, Juice.Type.Methane]
	
	var tasks = []
	for s in shells:
		for j in juices:
			tasks.append(make_task(s, j))
			
	return tasks

func generate_coord():
	return Vector2i(randi_range(0, 3), randi_range(0, 4))
	
func generate_height():
	return randi_range(0, 3)
	
func to_display_coord(coord: Vector2i):
	return ["ABCDEFGHI"[coord.x], "1234567"[coord.y]]
	
func to_display_height(height: int):
	return ["-50", "0", "50", "100", "150", "200"][height]
