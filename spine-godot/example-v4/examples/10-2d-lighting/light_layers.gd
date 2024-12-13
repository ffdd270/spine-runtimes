extends Tree

signal light_selected(light: Light2D)

var _root: TreeItem
var _selected_light : Light2D = null
var _data_map : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_root = create_item()
	hide_root = true

	var lights : Node2D = %Lights
	for light in lights.get_children():
		var child = create_item(_root)
		child.set_text(0, light.name)
		_data_map[light.name] = light



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_item_selected() -> void:
	var selected_item = get_selected()

	if selected_item != null:
		var light = _data_map[selected_item.get_text(0)]
		_selected_light = light
		light_selected.emit(light)

func get_selected_light() -> Light2D:
	return _selected_light
