class_name RamLoader
extends Node3D

var active := false

@export var handle: DoodadHandle
var primed := false
var resetting := false

var path: Curve2D

var loader_start = self.position.z

signal loaded

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var top = handle.plane.project($LeverBase/Refs/Top.global_position)
	var center = handle.plane.project($LeverBase/Refs/Middle.global_position)
	var left = handle.plane.project($LeverBase/Refs/Left.global_position)
		
	path = Curve2D.new()
	path.add_point(top)
	path.add_point(center)
	path.add_point(left)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not active:
		return
	
	var top = handle.plane.project($LeverBase/Refs/Top.global_position)
	var center = handle.plane.project($LeverBase/Refs/Middle.global_position)
	var left = handle.plane.project($LeverBase/Refs/Left.global_position)
		
	if handle.dragging and not resetting:
		var current_pos := handle.current_pos
		
		if not primed:
			# only vertical
			var desired =\
				remap(current_pos.y, top.y, center.y, $LeverBase/Refs/Top.position.y, $LeverBase/Refs/Middle.position.y)
			desired =\
				clamp(desired, $LeverBase/Refs/Middle.position.y, $LeverBase/Refs/Top.position.y)
			
			$LeverBase/Center.position.y = lerp($LeverBase/Center.position.y, desired, 5.0 * delta)
	
			var pos = $LeverBase/Center.position.y
			if abs(pos - $LeverBase/Refs/Middle.position.y) < 0.1:
				$LeverBase/Center.position.y = lerp(pos, $LeverBase/Refs/Middle.position.y, 20.0 * delta)
				if abs(pos - $LeverBase/Refs/Middle.position.y) < 0.05:
					$LeverBase/Center.position.y = $LeverBase/Refs/Middle.position.y
					primed = true
		else:
			# only horizontal
			var desired =\
				remap(current_pos.x, center.x, left.x, $LeverBase/Refs/Middle.position.z, $LeverBase/Refs/Left.position.z)
			desired =\
				clamp(desired, $LeverBase/Refs/Middle.position.z, $LeverBase/Refs/Left.position.z)
			
			$LeverBase/Center.position.z = lerp($LeverBase/Center.position.z, desired, 10.0 * delta)
			
			var pos = $LeverBase/Center.position.z
			if abs(pos - $LeverBase/Refs/Left.position.z) < 0.1:
				$LeverBase/Center.position.z = lerp(pos, $LeverBase/Refs/Left.position.z, 20.0 * delta)
				if abs(pos - $LeverBase/Refs/Left.position.z) < 0.05:
					$LeverBase/Center.position.z = $LeverBase/Refs/Left.position.z
					
					_load_shell(handle.start_mouse_pos)
		
	return
	
	# old
	if handle.dragging:
		var current_pos := handle.current_pos
		
		var diff = current_pos - handle.last_pos
		$LeverBase/Center.position.y += -diff.y
		$LeverBase/Center.position.z += -diff.x
		
		var lever_pos = handle.plane.project($LeverBase/Center.global_position)
		
		var closest = path.get_closest_point(lever_pos)
		var offset = closest - lever_pos
		print(offset)
		
		$LeverBase/Center.position.y += -offset.y
		$LeverBase/Center.position.z += -offset.x
			
		#if abs(lever_pos.x - center.x) < 0.01:
			## can move up and down
			#$LeverBase/Center.position.y += -diff.y
			#
		#if abs(lever_pos.y - center.y) < 0.01:
			## can move left and right
			#$LeverBase/Center.position.z += -diff.x

func _load_shell(restore_pos: Vector2):
	active = false
	primed = false
	resetting = true
	
	var t = create_tween()
	t.tween_property($LeverBase/Center, "position:z", $LeverBase/Refs/Middle.position.z, 0.1)
	t.tween_property($LeverBase/Center, "position:y", $LeverBase/Refs/Top.position.y, 0.1)
	
	create_tween().tween_property(self, "position:z", 1.1, 0.4)
	
	await t.finished
	
	loaded.emit()
	
	Input.warp_mouse(restore_pos)
	handle._force_update()
	
	resetting = false
	
func set_active():
	active = true
	
func reset():
	primed = false
	resetting = false
	active = false
	self.position.z = loader_start

func start_interaction():
	pass
	
func stop_interaction():	
	pass

func _on_begin_hold(start_pos: Vector2) -> void:
	InteractionManager.start_modal_interaction(self)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _on_end_hold() -> void:
	InteractionManager.exit_interaction()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
