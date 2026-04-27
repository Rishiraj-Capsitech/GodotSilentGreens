class_name SoundType

# Inner enum must have a different name from the class.
# Access values as: SoundType.Values.BACKGROUND_MUSIC
# OR use the short form: SoundType.BACKGROUND_MUSIC  (via enum constant hoisting)
enum Values {
	BACKGROUND_MUSIC,
	BALL_SHOOT,
	BUTTON_CLICK,
	GAME_WIN,
	GAME_OVER
}

# Expose as top-level constants so SoundType.BACKGROUND_MUSIC works directly
const BACKGROUND_MUSIC   = Values.BACKGROUND_MUSIC
const BALL_SHOOT 		 = Values.BALL_SHOOT
const BUTTON_CLICK       = Values.BUTTON_CLICK
const GAME_WIN           = Values.GAME_WIN
const GAME_OVER          = Values.GAME_OVER
