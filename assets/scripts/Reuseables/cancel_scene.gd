extends Control

@onready var warning = $warning_panel
@onready var cancel_icon = $TextureRect

var is_cancel_active := false
var tween: Tween
var warning_base_pos: Vector2


func _ready():
	warning_base_pos = warning.position
	warning.hide()
	warning.modulate.a = 0.0
	cancel_icon.hide()
	cancel_icon.modulate.a = 0.0


func active_cancel():
	if is_cancel_active:
		return

	is_cancel_active = true

	if tween:
		tween.kill()

	warning.show()
	warning.modulate.a = 0.0

	tween = create_tween()
	tween.tween_property(warning, "modulate:a", 1.0, 0.2)



func inactive_cancel():
	if not is_cancel_active:
		return

	is_cancel_active = false

	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(warning, "modulate:a", 0.0, 0.15)

	tween.tween_callback(func():
		warning.hide()
	)
	
	
func cancel_pop():
	cancel_icon.show()
	cancel_icon.modulate.a = 1.0

	var t = create_tween()

	t.tween_interval(0.35)  # 👈 stay visible longer
	t.tween_property(cancel_icon, "modulate:a", 0.0, 0.4)  # 👈 slower fade

	t.tween_callback(func():
		cancel_icon.hide()
	)
