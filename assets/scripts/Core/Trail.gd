extends Line2D

var queue: Array




func _process(_delta: float) -> void:
	var pos = get_parent().global_position
	if get_parent().linear_velocity.length() <200:
		if get_point_count() > 1:
			remove_point(0)
		
		return
	add_point(pos)
	if points.size() >16:
		remove_point(0)
		
