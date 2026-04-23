extends Node

# LocalizationManager.gd
# Handles loading translations from JSON and managing the current locale.
# Does NOT use TranslationServer so that only labels with LocalizedLabel.gd are affected.

const TRANSLATION_PATH = "res://assets/localization/localization.json"

signal locale_changed(locale: String)

var _translations := {} # locale -> { key -> value }
var _current_locale := "en"


func _ready() -> void:
	# We intentionally avoid TranslationServer locale changes.
	# Localization is handled only by this manager + LocalizedLabel.gd.
	load_translations()
	var initial_lang = GameManager.current_language if "current_language" in GameManager else "en"
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
	_translations.clear()

	for key in data.keys():
		var locales_dict = data[key]
		for locale in locales_dict.keys():
			if not _translations.has(locale):
				_translations[locale] = {}
			_translations[locale][key] = locales_dict[locale]
	
	print("LocalizationManager: Translations loaded successfully.")


func set_locale(locale: String) -> void:
	# Normalize locale to match our JSON keys
	if locale.begins_with("en"): locale = "en"
	elif locale.begins_with("pt"): locale = "pt-BR"
	elif locale.begins_with("id"): locale = "id"
	elif locale.begins_with("es"): locale = "es"
	
	_current_locale = locale
	locale_changed.emit(locale)
	print("LocalizationManager: Locale set to ", locale)


func get_text(key: String) -> String:
	# Exact match
	if _translations.has(_current_locale) and _translations[_current_locale].has(key):
		return _translations[_current_locale][key]
	
	# Fallback: try base language (e.g. "pt" from "pt-BR")
	var base = _current_locale.split("-")[0]
	for l in _translations.keys():
		if l.split("-")[0] == base:
			if _translations[l].has(key):
				return _translations[l][key]
	
	# Final fallback to English
	if _translations.has("en") and _translations["en"].has(key):
		return _translations["en"][key]
	
	# Key not found at all, return the key itself
	return key
