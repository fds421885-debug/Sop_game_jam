extends Node

# متغير لمراقبة عدد قتلى الأعداء
var kills: int = 0
const MAX_KILLS: int = 12

# روابط المشاهد (تأكد من مطابقة الأسماء لملفات مشروعك)
var main_scene_path: String = "res://main.tscn" # ضع مسار مشهد اللعبة الرئيسي هنا
var victory_scene_path: String = "res://victory_scene.tscn" # مسار مشهد الفوز

func add_kill() -> void:
	kills += 1
	print("عدد القتلى الحالي: ", kills)
	if kills >= MAX_KILLS:
		# الذهاب لشاشة الفوز
		get_tree().change_scene_to_file(victory_scene_path)

func reset_game() -> void:
	kills = 0
