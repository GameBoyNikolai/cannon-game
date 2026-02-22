extends MeshInstance3D


func on():
	get_active_material(0).emission = Color.GREEN
	
func off():
	get_active_material(0).emission = Color.RED
