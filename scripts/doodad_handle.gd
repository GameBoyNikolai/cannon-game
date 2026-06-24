class_name DoodadHandle
extends Area3D

@export var plane: DragPlane

var dragging: bool = false

var last_pos := Vector2.ZERO
var current_pos := Vector2.ZERO
var start_pos := Vector2.ZERO

var highlighted := false
var shader := load("res://outline_shader.gdshader")
@onready var shader_mat: ShaderMaterial = ShaderMaterial.new()

@export var density := 1.0
@export var highlights: Array[GeometryInstance3D] = []
@export var custom_highlights: Array[Node3D] = []

signal begin_hold(start_pos: Vector2)
signal end_hold()
signal on_move(pos: Vector2)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.set_collision_layer_value(3, true)
	
	shader_mat.render_priority = 1
	shader_mat.set_shader_parameter("density", density)
	for o in highlights:
		o.material_overlay = shader_mat
		
func highlight():
	if not highlighted:
		highlighted = true
		for o in highlights:
			o.material_overlay = shader_mat
		shader_mat.set_shader(shader)
		
		for o in custom_highlights:
			o.highlight(self)
	
func unhighlight():
	if highlighted:
		highlighted = false
		shader_mat.set_shader(null)
		
		for o in custom_highlights:
			o.unhighlight(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dragging:
		unhighlight()
	
	if not dragging:
		if can_grab():
			highlight()
		else:
			unhighlight()
		
		return
	
	if dragging and Input.is_action_just_released("ui_accept"):
		release()
		return
	
	last_pos = current_pos
	current_pos = plane.project(_mouse_pos())
	on_move.emit(current_pos)

# called from player
func grab():
	last_pos = plane.project(_mouse_pos())
	current_pos = last_pos
	start_pos = last_pos
	
	begin_hold.emit(current_pos)
	dragging = true
	
# called automatically on mouse release or manually
func release():
	dragging = false
	end_hold.emit()

func can_grab(): 
	var camera := get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_dir := camera.project_ray_normal(mouse_pos)
	
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_origin + ray_dir * 1.8,
		 0x00000004, []
	)
	params.collide_with_areas = true
	params.collide_with_bodies = false
	var result = space_state.intersect_ray(params)
	
	if "collider" in result and result.collider == self:
		return true

func _mouse_pos() -> Vector3:
	var camera := get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_dir := camera.project_ray_normal(mouse_pos)

	var val = plane.intersects_ray(ray_origin, ray_dir)
	if not val:
		return plane.center()
	else:
		return val
