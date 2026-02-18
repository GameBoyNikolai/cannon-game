extends Control

@onready var menus = [$CanvasGroup/PanelContainer/VBoxContainer/StartMenu, $CanvasGroup/PanelContainer/VBoxContainer/BackMenu, $CanvasGroup/PanelContainer/VBoxContainer/NavMenu]
@onready var content = $CanvasGroup/PanelContainer/VBoxContainer/Label

@onready var original_text = content.text

#var all_ingredients = []
#var current_page = 0

var name_order = []
var in_ingredient = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_menu($CanvasGroup/PanelContainer/VBoxContainer/StartMenu)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	InteractionManager.start_modal_interaction(self)
	
	# later filter out the ones that haven't been used yet
	for name in Game.tasks.ingredient_descs:
		name_order.append(name)
		$CanvasGroup/PanelContainer/VBoxContainer/ItemList.add_item(Game.tasks.ingredient_names[name])
		
		#var desc = Game.tasks.ingredient_descs[name]
		#all_ingredients.append("> " + Game.tasks.ingredient_names[name] + "\n\n" + desc)
		
		

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


func _on_button_pressed(b: String) -> void:
	match b:
		"Task":
			show_menu($CanvasGroup/PanelContainer/VBoxContainer/BackMenu)
			
			var ingredients = Game.tasks.ingredient_names
			var text = "> Current Task:\n\n"
			for ing in Game.tasks.recipes[Game.current_task]:
				text += "- " + ingredients[ing] + "\n"
			
			content.text = text
		"Back":
			if in_ingredient: 
				in_ingredient = false
				
				show_menu($CanvasGroup/PanelContainer/VBoxContainer/BackMenu)
				$CanvasGroup/PanelContainer/VBoxContainer/MarginContainer.hide()
				$CanvasGroup/PanelContainer/VBoxContainer/ItemList.show()
			else:
				show_menu($CanvasGroup/PanelContainer/VBoxContainer/StartMenu)
				$CanvasGroup/PanelContainer/VBoxContainer/MarginContainer.show()
				$CanvasGroup/PanelContainer/VBoxContainer/ItemList.hide()
				
			content.text = original_text
		"Protocol":
			show_menu($CanvasGroup/PanelContainer/VBoxContainer/BackMenu)
			$CanvasGroup/PanelContainer/VBoxContainer/MarginContainer.hide()
			$CanvasGroup/PanelContainer/VBoxContainer/ItemList.show()
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
	if mouse_button_index != MOUSE_BUTTON_LEFT:
		return
		
	in_ingredient = true
	
	show_menu($CanvasGroup/PanelContainer/VBoxContainer/BackMenu)
	$CanvasGroup/PanelContainer/VBoxContainer/MarginContainer.show()
	$CanvasGroup/PanelContainer/VBoxContainer/ItemList.hide()
	
	content.text = "> " + Game.tasks.ingredient_names[name_order[index]] + "\n\n" + Game.tasks.ingredient_descs[name_order[index]]
