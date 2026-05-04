extends StaticBody2D

@onready var collider = $CollisionPolygon2D

var disable_count := 5
var total_time := 15.0

var cycle_id := 0  # 

func _ready():
	randomize()
	main_cycle()

# 🔁 MAIN LOOP
func main_cycle():
	while true:
		cycle_id += 1
		var id = cycle_id
		
		await run_random_phase(id)
		await run_final_disable(id)


func run_random_phase(id):
	for i in range(disable_count):
		var delay = randf_range(0.0, total_time - 1.5) # leave space before final
		

		disable_after_delay(delay, id)
	
	await get_tree().create_timer(total_time, false).timeout


func disable_after_delay(delay, id):
	await get_tree().create_timer(delay, false).timeout
	
	if id != cycle_id:
		return
		
	await disable_temporarily(1.0, id)


func run_final_disable(id):

	if id != cycle_id:
		return
		
	await disable_temporarily(2.0, id)

# 🔧 SAFE DISABLE
func disable_temporarily(duration, id):

	if id != cycle_id:
		return
		
	collider.disabled = true
	visible = false
	
	await get_tree().create_timer(duration, false).timeout
	

	if id != cycle_id:
		return
		
	collider.disabled = false
	visible = true
