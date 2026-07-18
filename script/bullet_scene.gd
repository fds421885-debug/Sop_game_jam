extends Area2D

# سرعة المقذوف
@export var speed: float = 600.0
# اتجاه الحركة
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# ربط إشارة الاصطدام لتدمير المقذوف عند ملامسة الأعداء أو الجدران
	body_entered.connect(_on_body_entered)
	
	# تدمير الرصاصة تلقائياً بعد 3 ثوانٍ إذا لم تصطدم بشيء لتوفير الذاكرة
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	# تحريك المقذوف للأمام بناءً على اتجاهه
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# هنا يمكنك التحقق إذا اصطدم المقذوف بالعدو لتدميره
	if body.is_in_group("enemies"):
		body.take_damage() # افترض وجود دالة ضرر لدى الأعداء
	
	# تدمير المقذوف عند أي اصطدام
	queue_free()
