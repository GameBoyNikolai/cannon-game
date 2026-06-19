extends Node

var screenshake = 10.0

var current_task : Tasks.Task = null

var just_launched := false

@onready var story := Story.new()
@onready var tasks := Tasks.new()

var hud: HUD = null

class Email:
	var from: String
	var message: String
	var is_new: bool
	
	func init(f, msg):
		from = f
		message = msg
		is_new = true
		return self
		
var emails: Array[Email] = []

func update_task(new_task: Tasks.Task):
	current_task = tasks.fill_task(new_task)

	emails.insert(0, Email.new().init("Commander Ballari", tasks.get_recipe_description(current_task)))
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func register_hud(hud):
	self.hud = hud

class StartState:
	var outer = null
	
	var first_tasks
	var current = 0
	
	func init(outer):
		self.outer = outer
		return self
		
	func enter():
		first_tasks = Game.tasks.first_task_stubs() 
		Game.update_task(first_tasks[0])
		
		Game.hud.display_messages(Game.story.intro_text())
		
	func update():
		if outer.hud.is_finished():
			pass
			
	func on_launch(good):
		if good:
			print(current, " ", len(first_tasks))
			if current == len(first_tasks) - 1:
				outer.current_state = NormalFlow.new().init(outer)
				outer.current_state.enter()
			else:
				var msg: Array[String] = ["Commander Ballari:\nBeautiful strike, the target was destroyed!", "Commander Ballari:\nI've sent over more instructions, check your terminal."]
				outer.hud.display_messages(msg)
			
				current += 1
				Game.update_task(first_tasks[current])
		else:
			var msg: Array[String] = ["What in hell are you doing!? Follow the launch orders this time. Insubordinaton will necessitate... termination."]
			outer.hud.display_messages(msg)
			
	func on_kill_commander():
		pass
		
class NormalFlow:
	var outer = null
	
	var all_tasks
	var completed = 0
	
	var incorrect = 0
	
	var final_strike = false
	
	func init(outer):
		self.outer = outer
		
		return self
		
	func enter():
		# somehow gradually increase difficulty buckets
		all_tasks = Game.tasks.normal_task_stubs() 
		Game.update_task(all_tasks.pick_random())
		
		Game.hud.display_messages(Game.story.normal_flow_start())
	
	func update():
		pass
		
	func on_launch(good):
		if final_strike:
			if good:
				Game.hud.game_finish(false)
			else:
				Game.hud.display_messages(Game.story.messed_up())
				await Game.get_tree().create_timer(3.0).timeout
				Game.hud.game_over()
			return
		
		if good:
			Game.hud.display_messages(Game.story.good_hit_bark())
			
			Game.emails[0].message += "\n\n > Complete"
			
			completed += 1
			print(completed)
			
			var task = all_tasks.pick_random()
			if completed == 1:
				Game.hud.display_messages(Game.story.cat_notification())
				Game.cat.activate()
				pass  #  difficult ramp?
			elif completed == 2:
				Game.emails.insert(0, Email.new().init("???", "You don't have to do this."))
			elif completed == 3:
				# send CAT disablement code
				Game.emails.insert(0, Email.new().init("???", "You can set the C.A.T to auto cool. \nGreen key in the C.A.T. control slot. \nThey want you distracted."))
				pass  # difficulty ramp?
			elif completed == 4:
				Game.emails.insert(0, Email.new().init("???", "They'll only kill you if they think you're disobeying.\nThey don't actually know if the missiles hit.\nSet the Elevation to +150 to safely detonate them above us."))
			elif completed == 5:
				task = Game.tasks.make_task(Shell.Type.Nuclear, Juice.Type.Hydrazine)
				Game.hud.display_messages(Game.story.rebels_located())
				
				Game.emails.insert(0, Email.new().init("???", "Your targeting computer terminal is lying.\nAim their missile at G4, -50 Elevation.\nTrust me.\nPlease."))
				# email from Commander giving you the rebel's coordinates and asking for a nuke as next task
				# or, "the controls to rotate the station will be behind a locked door. Connect the vaccum tubes in <some order> to unlock it.
				
				final_strike = true
				
			Game.update_task(task)
		else:
			outer.hud.display_messages(outer.story.bad_hit_bark())
			incorrect += 1
			
			if incorrect == 3:  # and it matters still
				Game.hud.game_over()
		
	func on_kill_commander():
		Game.hud.game_finish(true)
		
var started = false
var current_state = null

var cat: Node3D = null
var cannon: Node3D = null

var radar: Radar = null

var debug_launch := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not started or not hud:
		return
	
	if current_state == null:
		current_state = StartState.new().init(self)
		current_state.enter()
		
	current_state.update()
	
	if cat.overheating and cat.start_time > 20.0:
		#get_tree().quit()
		Game.hud.game_over()
		Game.started = false
	
	if Input.is_action_just_pressed("debug_good_launch"):
		debug_launch = true
	
	if just_launched and cat.is_good() and (DoodadState.loaded() or debug_launch):
		just_launched = false
		
		var correct = debug_launch or tasks.was_correct(current_task)
		
		#cannon.fire()
		radar.launch_missile()
		DoodadState.fire()
		debug_launch = false
		
		#await cannon.finished
		await radar.launch_finished
		
		# have an alt for rebels
		if DoodadState.coordinates == Vector2i(6, 3) and DoodadState.height == 0:
			current_state.on_kill_commander()
		else:
			current_state.on_launch(correct)
		# TODO: separate on_launch() from prepare_next()
		
	just_launched = false

func can_launch():
	return cat.is_good() and (DoodadState.loaded() or debug_launch)

func start():
	started = true
	current_state = null
