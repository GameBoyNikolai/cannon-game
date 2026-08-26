@tool
class_name ClampArray
extends Node3D

@onready var pistons = [
	$PistonClamp2,
	$PistonClamp,
	$PistonClamp3,
]

@onready var original_y = {
	$PistonClamp2: $PistonClamp2.position.y,
	$PistonClamp: $PistonClamp.position.y,
	$PistonClamp3: $PistonClamp3.position.y,
}

@export_tool_button("Lower", "Callable") var test_lower = _test_lower
@export_tool_button("Raise", "Callable") var test_raise = _test_raise

enum State {
	RAISED,
	RAISING,
	LOWERED,
	LOWERING,
}

class PistonState:
	var state = State.LOWERED
	var queue_state = null
	
var piston_states : Array[PistonState]

func _test_lower():
	for i in len(pistons):
		lower(i)
		await get_tree().create_timer(1.0).timeout
		
func _test_raise():
	for i in len(pistons):
		raise(i)
		await get_tree().create_timer(1.0).timeout
		
func _ready():
	for i in range(len(pistons)):
		_translate(1.0, pistons[i])
		
		piston_states.append(PistonState.new())
		
func _process(delta):
	for pi in range(len(piston_states)):
		var ps = piston_states[pi]
		if ps.queue_state:
			if ps.queue_state == State.RAISING and ps.state == State.LOWERED:
				raise(pi)
				ps.queue_state = null
				continue
				
			if ps.queue_state == State.LOWERING and ps.state == State.RAISED:
				lower(pi)
				ps.queue_state = null
				continue
			

func raise(index: int):
	var ps = piston_states[index]
	if ps.state != State.LOWERED:
		ps.queue_state = State.RAISING
		return
		
	ps.state = State.RAISING
	ps.queue_state = null
		
	var p = pistons[index]
	var t = create_tween()
	t.tween_method(_translate.bind(p), 1.0, 0.0, 0.4)
	t.tween_callback(p.emit)
	t.tween_method(_nop, 0.0, 0.0, 0.2)
	t.tween_method(_rotate.bind(p), 0.0, 1.0, 0.5)
	t.tween_callback(func(): ps.state = State.RAISED)
		
func lower(index: int):
	var ps = piston_states[index]
	if ps.state != State.RAISED:
		ps.queue_state = State.LOWERING
		return
		
	ps.state = State.LOWERING
	ps.queue_state = null
	
	var p = pistons[index]
	var t = create_tween()
	t.tween_method(_rotate.bind(p), 0.0, 1.0, 0.5)
	t.tween_method(_nop, 0.0, 0.0, 0.2)
	t.tween_method(_translate.bind(p), 0.0, 1.0, 0.4)
	t.tween_callback(func(): ps.state = State.LOWERED)
	
func _nop(t):
	pass
		
func _rotate(t: float, p: Node3D):
	var num_rots := 1.0
	p.rotation.y = num_rots * 2.0 * PI * ease(t, -2.0)
		
func _translate(t: float, p: Node3D):
	var half_sep := 5.0
	#p.set_separation(half_sep * ease(t, 1.5))
	var sep = half_sep * Tween.interpolate_value(0.0, 1.0, t, 1.0, Tween.TRANS_BACK, Tween.EASE_IN)
	
	if sep < 0.0:
		p.set_separation(0.0)
		p.position.y = original_y[p] + sep
	else:
		p.position.y = original_y[p]
		p.set_separation(sep)
