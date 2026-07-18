extends CharacterBody2D

# السرعة التي يتحرك بها العدو
@export var speed: float = 120.0

# ربط عقدة التنقل تلقائياً
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

# متغير لتخزين اللاعب المستهدف
var player: CharacterBody2D = null

func _ready() -> void:
	$AnimatedSprite2D.play("run")
	# إضافة العدو تلقائياً لمجموعة الأعداء برمجياً للأمان
	add_to_group("enemies")
	
	# الانتظار لضمان تحميل الخريطة وتزامنها مع نظام جودوت
	await get_tree().physics_frame
	await get_tree().create_timer(0.5).timeout
	
	if navigation_agent:
		navigation_agent.debug_enabled = false
	
	# البحث عن اللاعب تلقائياً بذكاء
	player = _find_player_safely()
	
	if player:
		print("✅ نجاح: تم العثور على اللاعب وملاحقته تبدأ الآن! الاسم: ", player.name)
	else:
		push_error("❌ خطأ: لم يتم العثور على اللاعب بأي طريقة!")

func _physics_process(_delta: float) -> void:
	# إذا لم يجد الكود اللاعب، يتوقف هنا تماماً
	if player == null:
		return
		
	# 1. إعطاء إحداثيات اللاعب لعقدة التنقل الذكي
	navigation_agent.target_position = player.global_position
	
	# 2. التحقق من الوصول للهدف
	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
		
	# 3. الحصول على النقطة التالية لتفادي العقبات والأشجار
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var current_position: Vector2 = global_position
	
	# 4. حساب الاتجاه والسرعة
	var move_direction: Vector2 = (next_path_position - current_position).normalized()
	velocity = move_direction * speed
	
	# 5. التحرك الفعلي وتفادي الجدران والعقبات
	move_and_slide()
	
	# --- 🚨 الطريقة الأولى والأقوى لرصد الاصطدام باللاعب وإعادة اللعبة فوراً 🚨 ---
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# إذا كان الشيء الذي اصطدمنا به هو اللاعب (سواء باسمه أو مجموعته)
		if collider:
			if collider.is_in_group("player") or "player" in collider.name.to_lower():
				_trigger_player_loss()

	# --- 🚨 الطريقة الثانية (الاحتياطية للتحقق من المسافة القريبة جداً) 🚨 ---
	# إذا اقترب العدو جداً من اللاعب (أقل من مسافة اصطدام تقريبية 35 بكسل) ولم يحدث اصطدام فيزيائي
	if global_position.distance_to(player.global_position) < 35.0:
		_trigger_player_loss()

# دالة استدعاء الموت للعدو عند إصابته بالرصاصة
func die() -> void:
	var manager = _get_game_manager()
	if manager:
		manager.add_kill()
	else:
		push_warning("تنبيه: لم يتم العثور على GameManager، سيتم إقصاء العدو فقط.")
	
	# تدمير العدو واختفاؤه من الشاشة
	queue_free()

# دالة للتعامل مع خسارة اللاعب بأمان وإعادة المشهد
func _trigger_player_loss() -> void:
	print("💀 دمر العدو اللاعب! جاري إعادة المشهد...")
	var manager = _get_game_manager()
	if manager:
		manager.reset_game() # تصفير العداد لكي يبدأ من الصفر مجدداً
	
	# إعادة تحميل المشهد الحالي فوراً
	get_tree().reload_current_scene()

# دالة للوصول الآمن إلى GameManager
func _get_game_manager() -> Node:
	if has_node("/root/GameManager"):
		return get_node("/root/GameManager")
	var root = get_tree().root
	if root.has_node("GameManager"):
		return root.get_node("GameManager")
	return null

# دالة للبحث عن اللاعب بأكثر من طريقة تلقائياً لضمان سلامة الكود
func _find_player_safely() -> CharacterBody2D:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
		
	players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		return players[0]
		
	var root = get_tree().current_scene
	if root:
		var found = root.find_child("Player", true, false)
		if found and found is CharacterBody2D:
			return found
			
		found = root.find_child("player", true, false)
		if found and found is CharacterBody2D:
			return found
	return null
