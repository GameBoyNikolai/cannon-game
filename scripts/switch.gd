class_name Switch
extends Node3D

var shader := load("res://outline_shader.gdshader")

@onready var highlight_objects: Array[MeshInstance3D] = [$CoverHinge/Cover, $SwitchHinge/MeshInstance3D, $SwitchHinge/MeshInstance3D2]

var cover_open := false
var switch_on := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for o in highlight_objects:
		o.material_overlay = ShaderMaterial.new()
		o.material_overlay.set_shader_parameter("density", 2.0)
		o.material_overlay.render_priority = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _highlight(objs):
	for o in highlight_objects:
		o.material_overlay.set_shader(null)
		
	for o in objs:
		o.material_overlay.set_shader(shader)
	
func highlight_all():
	_highlight(highlight_objects)
	
func unhighlight_all():
	_highlight([])

#func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int, source: CollisionObject3D) -> void:	
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#if source == $CoverHinge/Area3D:
			#if cover_open:
				#if not switch_on:
					#$CoverHinge/Animation.play_backwards("cover")
					#cover_open = false
				#else:
					#$CoverHinge/Animation.play("cover_oops")
			#else:
				#$CoverHinge/Animation.play("cover")
				#cover_open = true
				#
		#if source == $SwitchHinge/Area3D:
			#if cover_open:
				#if switch_on:
					#$SwitchHinge/Animation.play_backwards("switch")
					#switch_on = false
					#
					#$CoverHinge/Animation.play_backwards("cover")
					#cover_open = false
				#else:
					#$SwitchHinge/Animation.play("switch")
					#switch_on = true
				#
	#get_viewport().set_input_as_handled()
#
#func _on_area_3d_mouse_entered(source: CollisionObject3D) -> void:
	#if source == $CoverHinge/Area3D:
		#_highlight([$CoverHinge/Cover])
	#elif source == $SwitchHinge/Area3D:
		#_highlight([$SwitchHinge/MeshInstance3D, $SwitchHinge/MeshInstance3D2])
	#else:
		#_highlight([])
#
#
#func _on_area_3d_mouse_exited(source: CollisionObject3D) -> void:
	#_highlight([])


func _on_begin_hold(start_pos: Vector2, source: DoodadHandle) -> void:
	source.release()
	
	if source == $CoverHinge/Area3D:
		if cover_open:
			if not switch_on:
				$CoverHinge/Animation.play_backwards("cover")
				cover_open = false
			else:
				$CoverHinge/Animation.play("cover_oops")
		else:
			$CoverHinge/Animation.play("cover")
			cover_open = true
			
	if source == $SwitchHinge/Area3D:
		if cover_open:
			if switch_on:
				$SwitchHinge/Animation.play_backwards("switch")
				switch_on = false
				
				$CoverHinge/Animation.play_backwards("cover")
				cover_open = false
			else:
				$SwitchHinge/Animation.play("switch")
				switch_on = true
