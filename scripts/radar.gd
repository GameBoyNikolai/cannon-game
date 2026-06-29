class_name Radar
extends Node3D

@onready var radar_face := $RadarFace
@onready var shader_mat := $RadarFace.mesh.material as ShaderMaterial

var sectors := 5
var ranges := 5

# derived from shader params in radar.gdshader
var range_extent := 0.7
var angle_extent := PI / 2.0

var origin_ref := Vector2(0.0, 0.4);

@onready var base_rot = $PingsRef.rotation 

var ping_scene : PackedScene = load("res://scenes/radar_ping.tscn")
var all_pings : Array[Ping] = []

var active_pings : Array[Ping] = []
var scan_dist := 0.0;

@onready var missile_ping: Ping = $ReticleCenter/missile_ping

var _current_sector := 0
var _current_range := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.radar = self
	
	self.shader_mat.set_shader_parameter("sectors", sectors)
	self.shader_mat.set_shader_parameter("ranges", ranges)
	
	for i in range(8):
		var ping = ping_scene.instantiate()
		ping.visible = false
		ping.position.y = 0.01
		
		$PingsRef.add_child(ping)
		all_pings.append(ping)
		
	$ReticleCenter.position = Vector3(origin_ref.x, 0.01, origin_ref.y)
	$PingsRef.position = Vector3(origin_ref.x, 0.01, origin_ref.y)
	missile_ping.visible = false
	
	_random_enemies()
	
func _random_enemies():
	#while true:
	enemies_at(randi_range(2, ranges - 1), randi_range(0, sectors - 1))
	#await get_tree().create_timer(6.0).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#DoodadState.target_rotation = 0.0
	$PingsRef.rotation = base_rot + Vector3(0, DoodadState.target_rotation, 0)
	$ReticleCenter/Reticle.position.x = DoodadState.target_elevation
	
	scan_dist += 0.7 * delta
	scan_dist = fmod(scan_dist, 3.0)
	shader_mat.set_shader_parameter("scan_time", scan_dist)
	
	for p in active_pings:
		# transform based on aim angle
		#var angle = atan2(p.position.z, p.position.x) + PI
		p.update_visibility(DoodadState.target_rotation, angle_extent, origin_ref)
	
		var dist = p.radius
		if dist < scan_dist and dist >= scan_dist - 0.1:
			p.ping()
			
signal launch_finished		

func launch_missile():
	#$sound.play()
	_CameraShake3D._custom_shake(3 / (Game.screenshake / 10.0), Game.screenshake * 0.01)
	#$GPUParticles3D.emitting = true
	
	missile_ping.position.x = 0
	missile_ping.visible = true
	
	var speed := 0.05
	var duration := DoodadState.target_elevation / speed
	
	#var t = create_tween().tween_property(missile_ping, "position:x", -DoodadState.target_elevation, duration)
	var t = create_tween().tween_method(_tween_missile, 0.0, 1.0, duration)

	await t.finished
	
	missile_ping.visible = false
	
	_CameraShake3D._custom_shake(1 / (Game.screenshake / 10.0), Game.screenshake * 0.1)

	_random_enemies()

	launch_finished.emit()
	 
func _tween_missile(t: float):
	missile_ping.position.x = lerp(0.0, DoodadState.target_elevation, t)
	missile_ping.ping()

# assumes local size of 1.0x1.0
func range_nodes() -> Array[float]:
	var range_positions : Array[float] = []
	
	var width := range_extent / ranges
	for i in range(1, ranges):
		range_positions.append((i + 0.5) * width)
	
	return range_positions
	
func sector_nodes() -> Array[float]:
	var sector_positions : Array[float] = []
	
	var width := 2.0 * PI / (sectors * 3)
	for i in range(sectors):
		sector_positions.append((i + 0.5) * width)
	
	return sector_positions

func enemies_at(range: int, sector: int):
	assert(range >= 0 && range < ranges)
	assert(sector >= 0 && sector < sectors)
	
	_current_range = range
	_current_sector = sector
	
	var r_width := range_extent / ranges
	var s_width := 2.0 * PI / sectors
	
	for p in all_pings:
		p.visible = false
	
	active_pings.clear()
	#for i in range(randi_range(4, 8)):
	for i in range(1):
		var theta := randf_range(sector * s_width * 1.1, (sector + 1) * s_width * 0.9)
		var r := randf_range(range * r_width * 1.1, (range + 1) * r_width * 0.9)
		
		var ping = all_pings[i]
		ping.visible = true
		ping.position = Vector3(r, 0.01, r) * Vector3(cos(theta), 1.0, sin(theta))
		ping.init(theta, r)
		active_pings.append(ping)
		
		#pings.append(Vector2(r, r) * Vector2(cos(theta), sin(theta)))
#
	#self.shader_mat.set_shader_parameter("pings", pings)
	#self.shader_mat.set_shader_parameter("num_pings", pings.size())
