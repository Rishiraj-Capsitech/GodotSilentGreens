extends Node

#panels
var PausePanel:CanvasLayer
var HudPanel:CanvasLayer
var GameOver:CanvasLayer
var SettingPannel:CanvasLayer


#hud 
var Lifes: Array = []
var LevelNumber:Label
var CoinCount:Label
var pauseButton:TextureButton


#Gameover buttons
var RestartGameOver:TextureButton
var HomeGameOver:TextureButton
var SkipGameOver:TextureButton
var OopsPannel:CanvasLayer
var oops_node:Control
var oops_lable:Label
var _current_tween: Tween


#setiings buttons
var CLoseSetiings:TextureButton
var SoundToggel:TextureButton
var SoundIcon:TextureRect
var EnglishButton:TextureButton
var PortugueseButton:TextureButton
var SpanishButton:TextureButton
var Senstivity:Slider


#pasue menu buttons
var HomeButtonPause:TextureButton
var RestartButtonPause:TextureButton
var ResumeButtonPause:TextureButton
var SettingsButtonPause:TextureButton
var HomeCnf:CanvasLayer
var cnfButton:TextureButton
var cancelButton:TextureButton

	
func _setup_ui():
	print("setting up")
	PausePanel = get_tree().get_first_node_in_group("pause_ui")
	HudPanel = get_tree().get_first_node_in_group("hud_ui")
	GameOver = get_tree().get_first_node_in_group("game_over_ui")
	SettingPannel = get_tree().get_first_node_in_group("setting_ui")
	OopsPannel = get_tree().get_first_node_in_group("Oops_ui")
	HomeCnf = get_tree().get_first_node_in_group("home_confirmation")
	_setup_hud()
	_setup_GameOver()
	_setup_settings()
	_setup_pause()
	_setup_confirmation_home()


#setup methods

func _setup_hud():
	if HudPanel == null:
		print("HUD not found!")
		return
	
	var hud = HudPanel.get_node("GameHUD")
	
	LevelNumber = hud.get_node("Level/LevelCount")
	CoinCount= hud.get_node("CoinGroup/CoinsCount")
	LevelNumber.text =str(GameManager.current_level+1)
	pauseButton=hud.get_node("PauseButton")
	
	
	Lifes = [
		hud.get_node("Life_Bar/life1/Done"),
		hud.get_node("Life_Bar/life2/Done2"),
		hud.get_node("Life_Bar/life3/Done3")
	]
	
	pauseButton.pressed.connect(_on_pause_button_pressed)

func _setup_pause():
	if PausePanel == null:
		print("PausePanel not found!")
		return
	
	var Pause_node = PausePanel.get_node("PausePanel")
	
	if Pause_node:
		print("pause node found")
		HomeButtonPause = Pause_node.get_node("options/HBoxContainer/HomeButton")
		RestartButtonPause = Pause_node.get_node("options/HBoxContainer/RestartButton")
		ResumeButtonPause = Pause_node.get_node("options/HBoxContainer/ResumeButton")
		SettingsButtonPause = Pause_node.get_node("SettingsButton")
		if (HomeButtonPause and SettingsButtonPause and ResumeButtonPause and RestartButtonPause):
			print("Found all buttons")
			HomeButtonPause.pressed.connect(_home)
			RestartButtonPause.pressed.connect(_on_restart_button_pressed)
			ResumeButtonPause.pressed.connect(_on_resume_button_pressed)
			SettingsButtonPause.pressed.connect(_open_setting)
	else:
		print("node not found")

func _setup_GameOver():
	if GameOver == null:
		print("Gameover not found!")
		return
		
	var GameOverNode = GameOver.get_node("GameOver")
	
	SkipGameOver = GameOverNode.get_node("Container/SkipButton")
	HomeGameOver= GameOverNode.get_node("Container/HomeButton")
	RestartGameOver= GameOverNode.get_node("Container/RestartButton")
	if  HomeGameOver and RestartGameOver:
		HomeGameOver.pressed.connect(_home)
		RestartGameOver.pressed.connect(_on_restart_button_pressed)
		
	if OopsPannel == null:
		print("OopsPannel not found!")
		return
	
	oops_node= OopsPannel.get_node("OopsScene")
	if oops_node:
		oops_lable=oops_node.get_node("Label")

func _setup_settings():
	if not SettingPannel:
		print("settings not found")
		return
		
	var setting_node = SettingPannel.get_node("Settings")
	if setting_node:
		CLoseSetiings = setting_node.get_node("CloseButton")
		SoundToggel = setting_node.get_node("VBoxContainer/SoundButton")
		EnglishButton = setting_node.get_node("VBoxContainer/EnglishButton")
		PortugueseButton = setting_node.get_node("VBoxContainer/PortugueseButton")
		SpanishButton = setting_node.get_node("VBoxContainer/SpanishButton")
		Senstivity = setting_node.get_node("VBoxContainer/Senstivity/Senstivity_Slider")
		SoundIcon = setting_node.get_node("VBoxContainer/SoundButton/Off")

		if (CLoseSetiings and SoundToggel and 
			EnglishButton and PortugueseButton and 
			SpanishButton and Senstivity):

			# Close button
			if CLoseSetiings.pressed.is_connected(Close_settings):
				CLoseSetiings.pressed.disconnect(Close_settings)
			CLoseSetiings.pressed.connect(Close_settings)

			# Sound toggle
			if SoundToggel.pressed.is_connected(toggel_sound):
				SoundToggel.pressed.disconnect(toggel_sound)
			SoundToggel.pressed.connect(toggel_sound)

			# Language selection
			EnglishButton.pressed.connect(_on_english_pressed)
			PortugueseButton.pressed.connect(_on_portuguese_pressed)
			SpanishButton.pressed.connect(_on_spanish_pressed)

func _on_english_pressed():
	LocalizationManager.set_locale("en")
	GameManager.current_language = "en"
	GameManager.save_game_data()

func _on_portuguese_pressed():
	LocalizationManager.set_locale("pt-BR")
	GameManager.current_language = "pt-BR"
	GameManager.save_game_data()

func _on_spanish_pressed():
	LocalizationManager.set_locale("es")
	GameManager.current_language = "es"
	GameManager.save_game_data()

func _setup_confirmation_home():
	if not HomeCnf:
		print("Home cnf Not found")
		return
		
	var HomeCnf_node = HomeCnf.get_node("HomeConfirmation2")
	if HomeCnf_node:
		cnfButton = HomeCnf_node.get_node("Confirmation_options/ConfirmButton")
		cancelButton = HomeCnf_node.get_node("Confirmation_options/CancelButton")
		

		if (cnfButton and cancelButton):
			cnfButton.pressed.connect(_open_home)
			cancelButton.pressed.connect(_cancel_home)
		

func _open_home():
	GameManager.showWindWarn=false
	get_tree().change_scene_to_file("res://assets/scenes/UI/UI_Scenes/main_menu.tscn")

	
	
func _cancel_home():
	HomeCnf.hide()

func _play_oops():
	OopsPannel.show()
	oops_lable.text = "Oops!"
	print(oops_lable.get_script())
	if _current_tween and _current_tween.is_running():
		_current_tween.kill()
 
	oops_lable.visible = true
	oops_lable.scale = Vector2.ZERO
	oops_lable.modulate.a = 1.0
	oops_lable.pivot_offset = oops_lable.size / 2.0  
 
	_current_tween = create_tween()
 
	_current_tween.parallel().tween_property(oops_lable, "scale", Vector2.ONE, 0.5)
 
	_current_tween.parallel().tween_property(oops_lable, "modulate:a", 0.0, 1.0)
	 
	_current_tween.finished.connect(func():
		oops_lable.visible = false
	)
	await get_tree().create_timer(1).timeout
	OopsPannel.hide()

func toggel_sound():
	GameManager.SoundOn = false if GameManager.SoundOn else true
	SoundIcon.visible = GameManager.SoundOn
	GameManager.save_game_data()

func Close_settings():
	SettingPannel.hide()
	if GameOver and HudPanel:
		GameOver.hide()
		HudPanel.hide() 

func _on_pause_button_pressed() -> void:
	GameManager.state= GameManager.GameState.PAUSED
	GameOver.hide()
	PausePanel.show()
	HudPanel.hide() 
	SettingPannel.hide()

func _on_resume_button_pressed() -> void:
	PausePanel.hide()
	GameOver.hide()
	HudPanel.show()
	SettingPannel.hide()
	GameManager.state= GameManager.GameState.PLAYING

func _updateLife(life: int):
	for i in range(Lifes.size()):
		Lifes[i].visible = i < life

func _gameOver():
	GameOver.show()
	PausePanel.hide()
	HudPanel.hide()
	SettingPannel.hide()

func add_coin(coin: int):
	var current = int(CoinCount.text)
	current += coin
	CoinCount.text = str(current)
	
func set_level(level:int):
	if LevelNumber:
		LevelNumber.text =str(level)
	else:
		print(" Not Found")

func _home():
	HomeCnf.show()

func _open_setting():
	SettingPannel.show()
	if GameOver and HudPanel:
		GameOver.hide()
		HudPanel.hide() 

func _on_restart_button_pressed() -> void:	
	PausePanel.hide()
	GameOver.hide()
	SettingPannel.hide()
	HudPanel.show()
	GameManager.reset_game() 
