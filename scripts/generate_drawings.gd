@tool
class_name GenerateDrawings
extends EditorScript

func _run() -> void:
	var self_ref = self
	
	var root := EditorInterface.get_edited_scene_root()
	var viewport : SubViewport = root.get_node("SubViewport")
	var cameras_root := viewport.get_node("Cameras")
	
	print("do_scene")
	root.do_scene()
	root.call("do_scene")
	
	for c in cameras_root.get_children():
		if c.has_method("_apply_state"):
			print("Had method")
			print(c.num_states)
			for i in range(c.num_states):
				#print(i)
				c._apply_state(i)
				#DoodadState.pressure_valve = i - 2
				#print(DoodadState.pressure_valve)
				await capture_and_save_photo(viewport, c as Camera3D, "_" + str(i))
		else:
			await capture_and_save_photo(viewport, c as Camera3D)
		
	var fs := EditorInterface.get_resource_filesystem()
	
	if not fs.is_scanning():
		fs.scan()

func capture_and_save_photo(viewport : SubViewport, camera: Camera3D, suffix: String = ""):
	camera.make_current()
	
	await RenderingServer.frame_post_draw
	
	var img: Image = viewport.get_texture().get_image()
	
	var save_path = "drawings/%s%s.png" % [camera.name, suffix]
	if img.save_png(save_path) == Error.OK:
		print("Drawing saved: ", camera.name)
	else:
		print("Failed to save drawing")
	
