extends Control

@onready var _light_position : ValueSliderV2 = $LightPosition
@onready var _light_color_picker : ColorPicker = $LightColorPicker
@onready var _energy_slider : ValueSlider = $EnergySlider
@onready var _scale_slider : ValueSlider = $ScaleSlider

var _light : Light2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_tree_light_selected(light: Light2D) -> void:
	if light != null:
		_light = light

		_light_position.value = light.position
		_light_color_picker.color = light.color
		_energy_slider.value = light.energy
		_scale_slider.value = light.texture_scale


func _on_light_position_value_changed(value: Vector2) -> void:
	if _light != null:
		_light.position = value

func _on_light_color_picker_color_changed(color: Color) -> void:
	if _light != null:
		_light.color = color


func _on_energy_slider_value_changed(value: float) -> void:
	if _light != null:
		_light.energy = value


func _on_scale_slider_value_changed(value: float) -> void:
	if _light != null:
		_light.texture_scale = value
