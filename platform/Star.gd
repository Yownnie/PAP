extends Area2D


func _on_body_entered(body):
	queue_free()
	var star = get_tree().get_nodes_in_group("star")
	if star.size() == 1:
		Events.level_completed.emit()
		
