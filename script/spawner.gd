extends Node2D

# تحديد مشهد العدو ليتم توليده
@export var enemy_scene: PackedScene
# معدل التوليد بالثواني
@export var spawn_cooldown: float = 3.0

@onready var timer: Timer = $Timer

func _ready() -> void:
	if timer:
		timer.wait_time = spawn_cooldown
		timer.timeout.connect(_on_timer_timeout)
		timer.start()

func _on_timer_timeout() -> void:
	if enemy_scene:
		# إنشاء وحش جديد
		var enemy_instance = enemy_scene.instantiate()
		# وضعه في نفس مكان الـ Spawner
		enemy_instance.global_position = global_position
		# إضافته للمشهد الرئيسي
		get_tree().current_scene.add_child(enemy_instance)
