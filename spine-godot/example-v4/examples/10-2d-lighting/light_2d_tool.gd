extends Node

var skel_path: String = ""
var atlas_path: String = ""
var normal_path: String = ""
var loaded_object: Node2D = null

var _light : Light2D = null

var _default_dir = "C:/Users/ffdd270/git/godot-spine/spine-runtimes/spine-godot/example-v4/examples/10-2d-lighting/spine_resource/"

@onready var skel_button: Button = %UI/Character/Buttons/SkelButton
@onready var atlas_button: Button = %UI/Character/Buttons/AtlasButton
@onready var normal_button: Button = %UI/Character/Buttons/NormalButton

@export var test = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_default_dir = "C:/Users/ffdd270/Documents/mascot_hazel/"
	if test:
		skel_path = _default_dir + "frida.skel"
		atlas_path = _default_dir + "normalmap_test.atlas"
		normal_path = _default_dir + "n_normalmap_test.png"

	update_button_text(skel_button, "Skel", skel_path)
	update_button_text(atlas_button, "Atlas", atlas_path)
	update_button_text(normal_button, "Normal", normal_path)

func update_button_text(button : Button, type : String, path : String):
	if path == "":
		button.text = type + " : None"
	else:
		# 경로의 마지막 20글자만 표시
		var shortened_path = path.substr(max(0, path.length() - 20))
		if path.length() > 20:
			shortened_path = "..." + shortened_path
		button.text = type + " : " + shortened_path

func disconnect_file_selected():
	var conns = %FileDialog.file_selected.get_connections()
	for conn in conns:
		%FileDialog.file_selected.disconnect(conn.callable)


func open_skel_dialog():
	%FileDialog.access = FileDialog.ACCESS_FILESYSTEM
	%FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE  # 단일 파일 선택 모드
	%FileDialog.filters = ["*.skel"] # 필터 설정 (선택사항)
	%FileDialog.current_dir = _default_dir

	# 파일이 선택되었을 때 호출될 함수 연결
	disconnect_file_selected()
	%FileDialog.file_selected.connect(_on_skel_file_selected)
	%FileDialog.popup_centered(Vector2(800, 600))

func open_atlas_dialog():
	%FileDialog.access = FileDialog.ACCESS_FILESYSTEM
	%FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE  # 단일 파일 선택 모드
	%FileDialog.filters = ["*.atlas"] # 필터 설정 (선택사항)
	%FileDialog.current_dir = _default_dir

	# 파일이 선택되었을 때 호출될 함수 연결
	disconnect_file_selected()
	%FileDialog.file_selected.connect(_on_atlas_file_selected)
	%FileDialog.popup_centered(Vector2(800, 600))

func open_normal_dialog():
	%FileDialog.access = FileDialog.ACCESS_FILESYSTEM
	%FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE  # 단일 파일 선택 모드
	%FileDialog.filters = ["*.png"] # 필터 설정 (선택사항)
	%FileDialog.current_dir = _default_dir

	# 파일이 선택되었을 때 호출될 함수 연결
	disconnect_file_selected()
	%FileDialog.file_selected.connect(_on_normal_file_selected)
	%FileDialog.popup_centered(Vector2(800, 600))

func _on_skel_file_selected(path: String) -> void:
	skel_path = path
	update_button_text(skel_button, "Skel", skel_path)

func _on_atlas_file_selected(path: String) -> void:
	atlas_path = path
	update_button_text(atlas_button, "Atlas", atlas_path)

func _on_normal_file_selected(path: String) -> void:
	normal_path = path
	update_button_text(normal_button, "Normal", normal_path)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_skel_button_pressed() -> void:
	open_skel_dialog()


func _on_atlas_button_pressed() -> void:
	open_atlas_dialog()


func _on_normal_button_pressed() -> void:
	open_normal_dialog()


func _on_load_button_pressed() -> void:
	# 로드 로직
	var skel_file_res := SpineSkeletonFileResource.new();
	skel_file_res.load_from_file(skel_path);

	var atlas_file_res := SpineAtlasResource.new();
	#atlas_file_res.set_normal_texture_prefix("n")
	atlas_file_res.load_from_atlas_file(atlas_path);

	#var normal_image = Image.new()
	#normal_image.load(normal_path)
	#var normal_texture = ImageTexture.create_from_image(normal_image)
	#atlas_file_res.normal_maps.append(normal_texture)
	

	var skeleton_data_res := SpineSkeletonDataResource.new();
	skeleton_data_res.skeleton_file_res = skel_file_res;
	skeleton_data_res.atlas_res = atlas_file_res;

	var sprite := SpineSprite.new();
	sprite.skeleton_data_res = skeleton_data_res;
	sprite.position.x = 200;
	sprite.position.y = 200;
	sprite.get_animation_state().set_animation("camping", true, 0);
	%LoadObjects.add_child(sprite)

	%ValueSliderV2.value = sprite.position
	loaded_object = sprite


func _on_value_slider_v_2_value_changed(value: Vector2) -> void:
	if loaded_object != null:
		loaded_object.position = value

func _on_tree_light_selected(light: Light2D) -> void:
	if light != null:
		print("selected light: ", light.name)
		_light = light
