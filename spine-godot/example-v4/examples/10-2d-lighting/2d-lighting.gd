extends Node2D

func _ready():
	$SpineSprite2.get_animation_state().set_animation("idle");
	# 화면 중앙 좌표 계산
	var viewport_size = get_viewport_rect().size
	center = viewport_size / 2
	
@onready var light = $Lights/Light2D
var radius = 100  # 원의 반지름 (픽셀)
var angle = 0     # 현재 각도
var speed = 2     # 회전 속도 (라디안/초)
var center        # 화면 중앙 좌표

var anim = false
func _process(delta):
	if not anim: 
		return 
	# 각도 업데이트
	angle += speed * delta
	
	# 원형 경로를 따라 이동
	var x = center.x + radius * cos(angle)
	var y = center.y + radius * sin(angle)
	light.position = Vector2(x, y)
