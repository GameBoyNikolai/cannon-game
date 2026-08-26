class_name HapticHandle
extends RefCounted

# [0, 1)
var _phantom_position: float = 0.0
var _display_position: float = 0.0

var _last_display_position: float = 0.0

# any
var _min: float
var _max: float

var _d_min: float
var _d_max: float

# "percentage"
var _lerp_speed: float

var _haptics: Array[float]
var _haptic_width: float
var _haptic_strength: float

# for doodads which assign their value based on the snap points
var _closest_haptic: int = 0

var _is_radial: bool = false

signal trigger_haptic(int)

var _last_haptic_triggered: int = -1

var _debug := false

var display_t: float :
	get:
		return _display_position
		
var last_display_t: float :
	get:
		return _last_display_position

func _init(min: float, max: float):
	_min = min(min, max)
	_max = max(min, max)
	_d_min = _min
	_d_max = _max
	
func haptics(haptics: Array[float]) -> HapticHandle:
	for h in haptics:
		_haptics.append((h - _min) / (_max - _min))
	return self
	
func haptic_strength(w: float, s: float) -> HapticHandle:
	_haptic_width = abs(w) / (_max - _min)
	_haptic_strength = s
	return self
	
func radial(is_radial: bool) -> HapticHandle:
	_is_radial = is_radial
	return self
	
func lerp_speed(speed: float) -> HapticHandle:
	_lerp_speed = speed
	return self
	
func display_range(d_min: float, d_max: float) -> HapticHandle:
	_d_min = d_min
	_d_max = d_max
	return self
	
func set_pos(pos: float) -> HapticHandle:
	_phantom_position = (pos - _min) / (_max - _min)
	_display_position = _phantom_position
	
	_last_haptic_triggered = _get_closest(_display_position).index
	
	return self
	
class _HapticLerp:
	var strength: float
	var toward: float
	
	func _init(str: float, tow: float):
		strength = str
		toward = tow
	
func _get_haptic_lerp(haptic: float, pos: float) -> _HapticLerp:
	var dist := absf(haptic - pos)
	
	var w := _haptic_width / 2
	
	# piecewise
	# 1  0 -1 0
	# | - - - |
	
	#if dist < w / 4:
		#var d = dist / (w / 4)
		#return _HapticLerp.new(lerp(1, 0, dist), haptic)
	#elif dist < w / 2:
		#var d = (dist - w / 4) / (w / 4)
		#return _HapticLerp.new()
		
	var curve := Curve.new()
	curve.min_value = -1.0
	curve.max_value = 1.0
	
	curve.add_point(Vector2(0.0, 3.0))
	curve.add_point(Vector2(0.5, 0.0))
	curve.add_point(Vector2(0.75, -1.0))
	curve.add_point(Vector2(1.0, 0.0))
	
	if _debug:
		prints(dist, w, dist / w)
	var strength = curve.sample(clamp(dist / w, 0.0, 1.0))
	var to = haptic
	if strength < 0.0:
		if pos > haptic:
			to = haptic + w
		else:
			to = haptic - w
	
	return _HapticLerp.new(abs(strength), to)
	
class _ClosestResult:
	var val: float
	var index: int
	var dist: float
	
	func _init(cv: float, ci: int, cd: float):
		val = cv
		index = ci
		dist = cd
		
func _get_closest(val: float) -> _ClosestResult:
	var closest = _haptics[0]
	var closest_dist = INF
	var closest_index = 0
	for index in range(len(_haptics)):
		var h = _haptics[index]
		var d = abs(h - val)
		if d < closest_dist:
			closest_dist = d
			closest = h
			closest_index = index
			
	return _ClosestResult.new(closest, closest_index, closest_dist)
	
func tick(delta: float, desired_position = null) -> float:
	_last_display_position = _display_position
	
	if desired_position != null:
		desired_position = (clamp(desired_position, _min, _max) - _min) / (_max - _min)
		_phantom_position = lerp(_phantom_position, desired_position, _lerp_speed * delta)
	
	var closest_to_phantom = _get_closest(_phantom_position)
	_closest_haptic = closest_to_phantom.index
			
	if closest_to_phantom.dist < _haptic_width / 2:
		_display_position = lerp(_display_position, closest_to_phantom.val, _haptic_strength * delta)
		#var hlerp = _get_haptic_lerp(closest_to_phantom.val, _phantom_position)
		#if _debug:
			##prints(hlerp.strength)
			#print(hlerp.toward)
		#_display_position = lerp(_display_position, hlerp.toward, (_haptic_strength + hlerp.strength) * delta)	
	else:
		_display_position = lerp(_display_position, _phantom_position, _lerp_speed * delta)
		
	var closest_to_disp = _get_closest(_display_position)
	if closest_to_disp.dist < _haptic_width / 4:
		if _last_haptic_triggered != closest_to_disp.index:
			_last_haptic_triggered = closest_to_disp.index
			trigger_haptic.emit(_last_haptic_triggered)
	elif closest_to_disp.dist > _haptic_width / 2:
		_last_haptic_triggered = -1
			
	return remap(_display_position, 0.0, 1.0, _d_min, _d_max)

func get_closest_haptic() -> int:
	return _closest_haptic
