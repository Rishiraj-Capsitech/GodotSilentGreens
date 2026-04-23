extends Node

# LocalizationManager.gd
# Handles loading translations from JSON and managing the current locale.

const TRANSLATION_PATH = "res://assets/localization/localization.json"

signal locale_changed(locale: String)

func _ready() -> void:
	load_translations()
	# Set initial locale based on GameManager or system default
	var initial_lang = GameManager.current_language if "current_language" in GameManager else TranslationServer.get_locale()
	set_locale(initial_lang)


func load_translations() -> void:
	if not FileAccess.file_exists(TRANSLATION_PATH):
		push_error("LocalizationManager: Translation file not found at " + TRANSLATION_PATH)
		return

	var file = FileAccess.open(TRANSLATION_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("LocalizationManager: JSON parse error: " + json.get_error_message())
		return

	var data = json.data
	var translations = {} # Dictionary to store OptimizedTranslation objects by locale

	for key in data.keys():
		var locales_dict = data[key]
		for locale in locales_dict.keys():
			if not translations.has(locale):
				var trans = OptimizedTranslation.new()
				trans.locale = locale
				translations[locale] = trans
			
			translations[locale].add_message(key, locales_dict[locale])
	
	for trans in translations.values():
		TranslationServer.add_translation(trans)
	
	print("LocalizationManager: Translations loaded successfully.")


func set_locale(locale: String) -> void:
	# Normalize locale (e.g., "en" instead of "en_US" if we only have "en")
	if locale.begins_with("en"): locale = "en"
	elif locale.begins_with("pt"): locale = "pt-BR"
	elif locale.begins_with("id"): locale = "id"
	elif locale.begins_with("es"): locale = "es"
	
	TranslationServer.set_locale(locale)
	locale_changed.emit(locale)
	print("LocalizationManager: Locale set to ", locale)


func get_text(key: String) -> String:
	return TranslationServer.translate(key)
