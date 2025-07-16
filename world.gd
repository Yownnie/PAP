extends Node2D

@export var next_level: PackedScene

var level_time = 0.0
var start_level_msec = 0.0
@onready var star_spawn_points = $StarSpawnPoints.get_children() # Reference to spawn points
@onready var stars = get_tree().get_nodes_in_group("star") # Reference to stars

@onready var level_completed = $CanvasLayer/Levelcompleted
@onready var Start_in = %StartIn
@onready var Start_in_label = %StartInlable
@onready var animation_player = $AnimationPlayer
@onready var level_time_label = %Leveltimelabel

func _ready():
	if not next_level is PackedScene:
		level_completed.next_level_button.text = "victory screen"
		next_level = load("res://victory_screen.tscn")
	Events.level_completed.connect(show_level_completed)
	
	# Initialize star positions
	respawn_stars()
	
	get_tree().paused = true
	Start_in.visible = true
	LevelTransition.fade_from_black()
	animation_player.play("Countdown")
	await animation_player.animation_finished
	get_tree().paused = false
	Start_in.visible = false
	start_level_msec = Time.get_ticks_msec()

func _process(delta: float) -> void:
	level_time = Time.get_ticks_msec() - start_level_msec
	level_time_label.text = str(level_time / 1000.0)

func respawn_stars():
	# Ensure there are enough spawn points for all stars
	if star_spawn_points.size() < stars.size():
		push_error("Not enough spawn points for stars!")
		return
	
	# Shuffle spawn points to randomize
	var shuffled_points = star_spawn_points.duplicate()
	shuffled_points.shuffle()
	
	# Assign each star a unique spawn point
	for i in range(stars.size()):
		stars[i].global_position = shuffled_points[i].global_position
		stars[i].visible = true # Ensure stars are visible
		stars[i].set_deferred("monitoring", true) # Re-enable collision monitoring

func retry():
	# Respawn stars before restarting
	respawn_stars()
	
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_file_path)

func go_to_next_level():
	if not next_level is PackedScene: return
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)

func show_level_completed():
	level_completed.show()
	level_completed.retry_button.grab_focus()
	get_tree().paused = true

func _on_levelcompleted_retry() -> void:
	retry()

func _on_levelcompleted_next_level() -> void:
	go_to_next_level()
