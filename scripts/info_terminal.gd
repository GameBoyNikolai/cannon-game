extends Control

@onready var menus = [$CanvasGroup/PanelContainer/VBoxContainer/StartMenu, $CanvasGroup/PanelContainer/VBoxContainer/BackMenu, $CanvasGroup/PanelContainer/VBoxContainer/NavMenu]
@onready var content = $CanvasGroup/PanelContainer/VBoxContainer/Label

@onready var original_text = content.text

#var all_ingredients = []
#var current_page = 0

var protocol_descs = []
var in_protocols = false

var in_emails = false

var in_ingredient = false
var in_message = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_menu($CanvasGroup/PanelContainer/VBoxContainer/StartMenu)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	InteractionManager.start_modal_interaction(self)

		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func exit():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()
	
func stop_interaction():
	exit()

func show_menu(menu):
	for m in menus:
		m.hide()
		
	if menu:
		menu.show()


func show_message_list():
	in_emails = true
	content.text = "> Messages"
	show_menu($CanvasGroup/PanelContainer/VBoxContainer/BackMenu)
	
	$CanvasGroup/PanelContainer/VBoxContainer/ItemList.clear()
	for email in Game.emails:
		var text = email.from
		if email.is_new:
			text = "** " + text + " **"
		$CanvasGroup/PanelContainer/VBoxContainer/ItemList.add_item(text)
		
	show_menu($CanvasGroup/PanelContainer/VBoxContainer/BackMenu)
	$CanvasGroup/PanelContainer/VBoxContainer/MarginContainer.hide()
	$CanvasGroup/PanelContainer/VBoxContainer/ItemList.show()
	
func show_protocol_list():
	in_protocols = true
	# later filter out the ones that haven't been used yet
	content.text = "> Protocol"
	$CanvasGroup/PanelContainer/VBoxContainer/ItemList.clear()
		
	for shell in Game.tasks.shell_reqs:
		$CanvasGroup/PanelContainer/VBoxContainer/ItemList.add_item(Game.tasks.shell_names[shell])
		protocol_descs.append("> " + Game.tasks.shell_names[shell] + "\n\n" + Game.tasks.get_shell_description(shell))
		
	for juice in Game.tasks.juice_reqs:
		$CanvasGroup/PanelContainer/VBoxContainer/ItemList.add_item(Game.tasks.juice_names[juice])
		protocol_descs.append("> " + Game.tasks.juice_names[juice] + "\n\n" + Game.tasks.get_juice_description(juice))
		
		
	show_menu($CanvasGroup/PanelContainer/VBoxContainer/BackMenu)
	$CanvasGroup/PanelContainer/VBoxContainer/MarginContainer.hide()
	$CanvasGroup/PanelContainer/VBoxContainer/ItemList.show()

func _on_button_pressed(b: String) -> void:
	Game.hud.click_sound()
	match b:
		"Messages":
			show_message_list()
		"Back":
			if in_ingredient: 
				in_ingredient = false
				show_protocol_list()
			elif in_message:
				in_message = false
				show_message_list()
			else:
				in_protocols = false
				in_emails = false
				show_menu($CanvasGroup/PanelContainer/VBoxContainer/StartMenu)
				$CanvasGroup/PanelContainer/VBoxContainer/MarginContainer.show()
				$CanvasGroup/PanelContainer/VBoxContainer/ItemList.hide()
				
				content.text = original_text
		"Protocol":
			show_protocol_list()
		"Exit":
			exit()
		#"Prev":
			#current_page -= 1
			#current_page = clamp(current_page, 0, len(all_ingredients) - 1)
			#content.text = all_ingredients[current_page]
			#
		#"Next":
			#current_page += 1
			#current_page = clamp(current_page, 0, len(all_ingredients) - 1)
			#content.text = all_ingredients[current_page]

func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	Game.hud.click_sound()
	if mouse_button_index != MOUSE_BUTTON_LEFT:
		return
		
	if in_protocols:
		in_ingredient = true
		
		show_menu($CanvasGroup/PanelContainer/VBoxContainer/BackMenu)
		$CanvasGroup/PanelContainer/VBoxContainer/MarginContainer.show()
		$CanvasGroup/PanelContainer/VBoxContainer/ItemList.hide()
		
		content.text = protocol_descs[index]
			
	elif in_emails:
		in_message = true
		
		show_menu($CanvasGroup/PanelContainer/VBoxContainer/BackMenu)
		$CanvasGroup/PanelContainer/VBoxContainer/MarginContainer.show()
		$CanvasGroup/PanelContainer/VBoxContainer/ItemList.hide()
		
		content.text = "> " + Game.emails[index].from + "\n\n" + Game.emails[index].message
		Game.emails[index].is_new = false
