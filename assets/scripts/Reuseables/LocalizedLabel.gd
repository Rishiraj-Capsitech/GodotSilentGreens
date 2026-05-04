extends Label

# LocalizedLabel.gd
# Automatically updates the label text based on a translation key when the locale changes.

@export var translation_key: String = "":
	set(value):
		translation_key = value
		update_text()

func _ready() -> void:
	if translation_key.is_empty():
		translation_key = text
	
	# Wait a frame to ensure all Autoloads are fully initialized
	await get_tree().process_frame
	
	update_text()
	LocalizationManager.locale_changed.connect(_on_locale_changed)


func update_text() -> void:
	if not translation_key.is_empty():
		text = LocalizationManager.get_text(translation_key)


func _on_locale_changed(_locale: String) -> void:
	update_text()
