extends Node

var PausePanel:CanvasLayer
var HudPanel:CanvasLayer
var GameOver:CanvasLayer
var SettingPannel:CanvasLayer
var Lifes: Array = []
var LevelNumber:Label
var CoinCount:Label
var RestartGameOver:TextureButton
var HomeGameOver:TextureButton
var SkipGameOver:TextureButton
var pauseButton:TextureButton


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

func _ready():
	PausePanel = get_tree().get_first_node_in_group("pause_ui")
	HudPanel = get_tree().get_first_node_in_group("hud_ui")
	GameOver = get_tree().get_first_node_in_group("game_over_ui")
	SettingPannel = get_tree().get_first_node_in_group("setting_ui")
	_setup_hud()
	_setup_GameOver()
	_setup_settings()
	_setup_pause()

func _setup_hud():
	if HudPanel == null:
		print("HUD not found!")
		return
	
	var hud = HudPanel.get_node("GameHUD")
	
	LevelNumber = hud.get_node("Level/LevelCount")
	CoinCount= hud.get_node("CoinGroup/CoinsCount")
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
		HomeButtonPause = Pause_node.get_node("options/HomeButton")
		RestartButtonPause = Pause_node.get_node("options/RestartButton")
		ResumeButtonPause = Pause_node.get_node("options/ResumeButton")
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

func _setup_settings():
	if not SettingPannel:
		print("settings not found")
		return
		
		
	var setting_node = SettingPannel.get_node("Settings")
	if setting_node:
		CLoseSetiings = setting_node.get_node("CloseButton")
		SoundToggel= setting_node.get_node("VBoxContainer/SoundButton")
		EnglishButton=setting_node.get_node("VBoxContainer/EnglishButton")
		PortugueseButton=setting_node.get_node("VBoxContainer/PortugueseButton")
		SpanishButton=setting_node.get_node("VBoxContainer/SpanishButton")
		Senstivity=setting_node.get_node("VBoxContainer/Senstivity/Senstivity_Slider")
		SoundIcon=setting_node.get_node("VBoxContainer/SoundButton/Off")
		if (CLoseSetiings and SoundToggel and 
			EnglishButton and PortugueseButton and 
			SpanishButton and Senstivity):
			CLoseSetiings.pressed.connect(Close_settings)
			SoundToggel.pressed.connect(toggel_sound)




func toggel_sound():
	GameManager.SoundOn = false if GameManager.SoundOn else true
	SoundIcon.visible = GameManager.SoundOn


func Close_settings():
	SettingPannel.hide()
	GameOver.hide()
	HudPanel.hide() 



func _on_pause_button_pressed() -> void:
	GameOver.hide()
	PausePanel.show()
	HudPanel.hide() 
	SettingPannel.hide()
	

func _on_resume_button_pressed() -> void:
	PausePanel.hide()
	GameOver.hide()
	HudPanel.show()
	SettingPannel.hide()


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
	print("pressed")

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
