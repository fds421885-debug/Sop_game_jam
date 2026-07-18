extends Control

func _ready() -> void:
	# ربط ضغطة الزر برمجياً لتشغيل دالة الإعادة
	var restart_button = $Button # تأكد أن اسم الزر هو Button تماماً في مشهدك
	if restart_button:
		restart_button.pressed.connect(_on_restart_button_pressed)

func _on_restart_button_pressed() -> void:
	var manager = _get_game_manager()
	if manager:
		# تصفير عدد القتلى والعودة للمشهد الرئيسي باستخدام المسار المخزن
		manager.reset_game()
		get_tree().change_scene_to_file(manager.main_scene_path)
	else:
		# حل احتياطي في حال لم يتم العثور على مدير اللعبة
		get_tree().change_scene_to_file("res://main.tscn")

# دالة ذكية للوصول إلى GameManager لتجنب خطأ الـ Identifier Not Declared
func _get_game_manager() -> Node:
	# 1. البحث في جذور اللعبة الأساسية (Autoload)
	if has_node("/root/GameManager"):
		return get_node("/root/GameManager")
		
	# 2. البحث كعقدة عادية في نافذة اللعبة
	var root = get_tree().root
	if root.has_node("GameManager"):
		return root.get_node("GameManager")
		
	return null
