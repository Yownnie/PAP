extends Area2D

func _on_body_entered(body):
	# Disable star instead of freeing it
	visible = false
	set_deferred("monitoring", false) # Disable collision
	var stars = get_tree().get_nodes_in_group("star")
	var active_stars = stars.filter(func(s): return s.visible)
	if active_stars.size() == 0:
		Events.level_completed.emit()
