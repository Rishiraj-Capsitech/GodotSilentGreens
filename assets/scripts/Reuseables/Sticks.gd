extends StaticBody2D

@onready var collider = $CollisionPolygon2D

var disable_count = 5
var total_time = 15.0

func _ready():
	randomize()
	start_random_disables()
	start_final_disable()

# ---- RANDOM DISABLES ----
func start_random_disables():
	for i in disable_count:
		var delay = randf_range(0.0, total_time)
		disable_after_delay(delay)

func disable_after_delay(delay):
	await get_tree().create_timer(delay).timeout
	await disable_temporarily(1.0)

# ---- FINAL DISABLE ----
func start_final_disable():
	await get_tree().create_timer(total_time).timeout
	await disable_temporarily(4.0)

# ---- DISABLE FUNCTION ----
func disable_temporarily(duration):
	# Disable collider + hide object
	collider.disabled = true
	visible = false
	
	await get_tree().create_timer(duration).timeout
	
	# Enable collider + show object
	collider.disabled = false
	visible = true
