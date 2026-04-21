extends Node

## AdMobManager
## Handles Google AdMob initialization and ad lifecycle.

var rewarded_ad : RewardedAd
var rewarded_ad_load_callback := RewardedAdLoadCallback.new()

var interstitial_ad : InterstitialAd
var interstitial_ad_load_callback := InterstitialAdLoadCallback.new()

signal banner_loaded
signal rewarded_ad_ready(ad: RewardedAd)
signal rewarded_ad_failed(error_message: String)
signal interstitial_ad_ready(ad: InterstitialAd)
signal interstitial_ad_failed(error_message: String)


func _ready() -> void:
	# Initialize MobileAds once as soon as the manager is ready
	MobileAds.initialize()
	
	# Configure rewarded ad callbacks
	rewarded_ad_load_callback.on_ad_failed_to_load = _on_rewarded_ad_failed_to_load
	rewarded_ad_load_callback.on_ad_loaded = _on_rewarded_ad_loaded
	
	# Configure interstitial ad callbacks
	interstitial_ad_load_callback.on_ad_failed_to_load = _on_interstitial_ad_failed_to_load
	interstitial_ad_load_callback.on_ad_loaded = _on_interstitial_ad_loaded
	
	print("AdMobManager: MobileAds initialized and callbacks configured.")
	
	## TESTING: Auto-load banner in debug builds to verify setup
	#if OS.is_debug_build():
		#print("AdMobManager: Debug build detected, auto-loading banner in 2 seconds...")
		#get_tree().create_timer(2.0).timeout.connect(load_banner)



## Loads a banner ad at the top of the screen.
func load_banner() -> void:
	var unit_id : String
	var os_name = OS.get_name()
	
	if os_name == "Android":
		unit_id = "ca-app-pub-3940256099942544/6300978111"
	elif os_name == "iOS":
		unit_id = "ca-app-pub-3940256099942544/2934735716"
	else:
		print("AdMobManager: Banner ads only supported on Android/iOS.")
		return

	print("AdMobManager: Loading banner ad...")
	var ad_view := AdView.new(unit_id, AdSize.BANNER, AdPosition.Values.TOP)
	ad_view.load_ad(AdRequest.new())
	banner_loaded.emit()


## Loads an interstitial ad.
func load_interstitial() -> void:
	var unit_id : String
	var os_name = OS.get_name()
	
	if os_name == "Android":
		unit_id = "ca-app-pub-3940256099942544/1033173712"
	elif os_name == "iOS":
		unit_id = "ca-app-pub-3940256099942544/4411468910"
	else:
		return

	print("AdMobManager: Loading interstitial ad...")
	InterstitialAdLoader.new().load(unit_id, AdRequest.new(), interstitial_ad_load_callback)


## Loads a rewarded ad.
func load_rewarded() -> void:
	var unit_id : String
	var os_name = OS.get_name()
	
	if os_name == "Android":
		unit_id = "ca-app-pub-3940256099942544/5224354917"
	elif os_name == "iOS":
		unit_id = "ca-app-pub-3940256099942544/1712485313"
	else:
		return

	print("AdMobManager: Loading rewarded ad...")
	RewardedAdLoader.new().load(unit_id, AdRequest.new(), rewarded_ad_load_callback)


func _on_rewarded_ad_failed_to_load(adError : LoadAdError) -> void:
	print("AdMobManager: Rewarded Ad failed to load: ", adError.message)
	rewarded_ad_failed.emit(adError.message)


func _on_rewarded_ad_loaded(ad : RewardedAd) -> void:
	print("AdMobManager: Rewarded Ad loaded successfully.")
	self.rewarded_ad = ad
	rewarded_ad_ready.emit(ad)


func _on_interstitial_ad_failed_to_load(adError : LoadAdError) -> void:
	print("AdMobManager: Interstitial Ad failed to load: ", adError.message)
	interstitial_ad_failed.emit(adError.message)


func _on_interstitial_ad_loaded(ad : InterstitialAd) -> void:
	print("AdMobManager: Interstitial Ad loaded successfully.")
	self.interstitial_ad = ad
	interstitial_ad_ready.emit(ad)


## Shows the rewarded ad if it's available.
func show_rewarded() -> void:
	if rewarded_ad:
		rewarded_ad.show()
		rewarded_ad = null # Reset after showing
	else:
		print("AdMobManager: Rewarded ad is not loaded yet.")


## Shows the interstitial ad if it's available.
func show_interstitial() -> void:
	if interstitial_ad:
		interstitial_ad.show()
		interstitial_ad = null # Reset after showing
	else:
		print("AdMobManager: Interstitial ad is not loaded yet.")
