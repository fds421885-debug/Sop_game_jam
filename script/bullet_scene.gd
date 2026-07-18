extends Area2D

@export var speed: float = 600.0
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# إذا اصطدمت الرصاصة بالعدو
	if body.is_in_group("enemies") or body.has_method("die"):
		body.die() # استدعاء دالة الموت داخل العدو
		queue_free() # تدمير الرصاصة
	elif not body.is_in_group("player"):
		# تدمير الرصاصة عند ملامسة الجدران أو الأشجار (وليس اللاعب)
		queue_free()
