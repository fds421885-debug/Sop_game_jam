extends CharacterBody2D

# --- إعدادات الإطلاق والمقذوف ---
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.25 # زمن الانتظار بين الطلقات بالثواني
var can_shoot: bool = true          # للتحقق من إمكانية الإطلاق

# --- إعدادات زاوية دوران الفوهة ---
@export var limit_rotation: bool = true     # تفعيل تحديد زاوية الدوران
@export var min_angle_degrees: float = -60.0 # أقصى زاوية للأسفل بالدرجات
@export var max_angle_degrees: float = 60.0  # أقصى زاوية للأعلى بالدرجات

# عقد المدفع التي يتم البحث عنها تلقائياً
var cannon_turret: Node2D = null
var muzzle: Marker2D = null

# متغيرات اللمس في الجهة اليمنى
var aim_touch_index := -1
var is_aiming_and_shooting := false

func _ready() -> void:
	# البحث التلقائي عن العقد لتجنب أخطاء التسمية
	cannon_turret = _auto_find_turret()
	muzzle = _auto_find_muzzle()
	
	if cannon_turret:
		print("تم ربط الفوهة تلقائياً: ", cannon_turret.name)
	else:
		push_error("خطأ: لم يتم العثور على عقدة الفوهة!")

func _input(event: InputEvent) -> void:
	# رصد اللمس للهواتف
	if event is InputEventScreenTouch:
		var screen_width = get_viewport_rect().size.x
		
		if event.pressed:
			# التحقق من أن اللمس تم في النصف الأيمن من الشاشة فقط
			if event.position.x >= screen_width / 2.0 and aim_touch_index == -1:
				aim_touch_index = event.index
				is_aiming_and_shooting = true
				_aim_at_screen_pos(event.position)
		else:
			# إنهاء الإطلاق عند رفع الإصبع عن الشاشة
			if event.index == aim_touch_index:
				aim_touch_index = -1
				is_aiming_and_shooting = false

	elif event is InputEventScreenDrag:
		# تحديث اتجاه التصويب أثناء سحب الإصبع في النصف الأيمن
		if event.index == aim_touch_index:
			_aim_at_screen_pos(event.position)

func _physics_process(_delta: float) -> void:
	# اللاعب ثابت تماماً في مكانه، لا توجد أكواد حركة هنا!
	
	# تدوير الفوهة عن طريق الماوس على الكمبيوتر (إذا لم يكن هناك لمس للهاتف)
	if cannon_turret and aim_touch_index == -1:
		var mouse_pos = get_global_mouse_position()
		_rotate_turret_towards(mouse_pos)
		
		# الإطلاق بالماوس
		if Input.is_action_pressed("shoot") or Input.is_action_just_pressed("shoot"):
			shoot()
			
	# الاستمرار في الإطلاق للهاتف طالما أن اللاعب يلمس النصف الأيمن
	if is_aiming_and_shooting:
		shoot()

# دالة تدوير الفوهة مع تطبيق زوايا الالتفاف المحددة
func _rotate_turret_towards(target_position: Vector2) -> void:
	if not cannon_turret:
		return
		
	# حساب الزاوية باتجاه الهدف
	var angle_to_target = (target_position - cannon_turret.global_position).angle()
	
	if limit_rotation:
		var min_rad = deg_to_rad(min_angle_degrees)
		var max_rad = deg_to_rad(max_angle_degrees)
		angle_to_target = clamp(angle_to_target, min_rad, max_rad)
		
	cannon_turret.global_rotation = angle_to_target

# توجيه الفوهة بناءً على موقع اللمس على الشاشة
func _aim_at_screen_pos(screen_pos: Vector2) -> void:
	if cannon_turret:
		var global_target = get_canvas_transform().affine_inverse() * screen_pos
		_rotate_turret_towards(global_target)

# دالة الإطلاق مع مؤقت زمن الانتظار (Cooldown)
func shoot() -> void:
	if can_shoot and bullet_scene and cannon_turret:
		can_shoot = false
		
		var bullet_instance = bullet_scene.instantiate()
		
		if muzzle:
			bullet_instance.global_position = muzzle.global_position
		else:
			bullet_instance.global_position = cannon_turret.global_position
			
		var shoot_direction = Vector2.RIGHT.rotated(cannon_turret.global_rotation)
		bullet_instance.direction = shoot_direction
		bullet_instance.rotation = cannon_turret.global_rotation
		
		get_tree().current_scene.add_child(bullet_instance)
		
		# الانتظار قبل السماح بالطلقة التالية
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true

# --- دوال البحث التلقائي عن العقد ---
func _auto_find_turret() -> Node2D:
	for child in get_children():
		if child is Node2D:
			var child_name = child.name.to_lower()
			if "turret" in child_name or "cannon" in child_name:
				return child
	for child in get_children():
		if child is Node2D and child.name != "base_sprite" and not child is CollisionShape2D and not child is Camera2D:
			return child
	return null

func _auto_find_muzzle() -> Marker2D:
	if cannon_turret:
		for child in cannon_turret.get_children():
			if child is Marker2D:
				return child
	for child in get_children():
		if child is Marker2D:
			return child
	return null
