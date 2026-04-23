extends Label

# LocalizedLabel.gd
# Automatically updates the label text based on a translation key when the locale changes.

@export var translation_key: String = ""

func _ready() -> void:
	if translation_key.is_empty():
		translation_key = text
	
	update_text()
	
	if has_node("/root/LocalizationManager"):
		LocalizationManager.locale_changed.connect(_on_locale_changed)


func update_text() -> void:
	if not translation_key.is_empty():
		text = tr(translation_key)


func _on_locale_changed(_locale: String) -> void:
	update_text()
