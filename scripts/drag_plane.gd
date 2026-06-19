class_name DragPlane
extends MeshInstance3D

var plane: Plane = Plane()
var plane_u: Vector3 = Vector3.ZERO
var plane_v: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	plane = Plane(global_basis * Vector3.UP, global_position)
	plane_u = global_basis * Vector3.FORWARD
	plane_v = global_basis * Vector3.RIGHT
	
func center() -> Vector3:
	return plane.get_center()
	
func intersects_ray(o: Vector3, d: Vector3) -> Variant:
	return plane.intersects_ray(o, d)

func project(v: Vector3) -> Vector2:
	var w := v - global_position
	return Vector2(w.dot(plane_u), w.dot(plane_v))
