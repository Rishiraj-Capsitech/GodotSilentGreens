extends Node2D

@onready var hand: Sprite2D = $Hand
@onready var trail: Line2D = $Trail
@onready var start_sprite: Sprite2D = $StartPoint
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@export var start_pos: Vector2 = Vector2(1600, -1600)
@export var end_pos: Vector2 = Vector2(1000, -1100)
@export var animation_name: String = "drag_tutorial"

func _ready():
	# Ensure nodes are at start_pos initially
	hand.position = start_pos
	start_sprite.position = start_pos
	trail.clear_points()
	
	if anim_player.has_animation(animation_name):
		anim_player.play(animation_name)
	else:
		_create_default_animation()
		anim_player.play(animation_name)

func _process(_delta):
	# Update trail to always connect start_pos to hand position
	# We only show the trail when the hand's opacity is high enough (during drag)
	if hand.modulate.a > 0.1:
		trail.clear_points()
		trail.add_point(start_pos)
		trail.add_point(hand.position)
	else:
		trail.clear_points()

func _create_default_animation():
	var anim = Animation.new()
	var track_pos = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_pos, "Hand:position")
	anim.track_insert_key(track_pos, 0.0, start_pos)
	anim.track_insert_key(track_pos, 0.5, start_pos) # Wait a bit
	anim.track_insert_key(track_pos, 1.5, end_pos) # Drag
	anim.track_insert_key(track_pos, 2.0, end_pos) # Hold
	
	var track_alpha = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_alpha, "Hand:modulate:a")
	anim.track_insert_key(track_alpha, 0.0, 0.0)
	anim.track_insert_key(track_alpha, 0.3, 1.0)
	anim.track_insert_key(track_alpha, 1.7, 1.0)
	anim.track_insert_key(track_alpha, 2.0, 0.0)
	
	anim.length = 2.2
	anim.loop_mode = Animation.LOOP_LINEAR
	
	var library = AnimationLibrary.new()
	library.add_animation(animation_name, anim)
	anim_player.add_animation_library("", library)
