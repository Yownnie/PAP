extends CharacterBody2D


const SPEED = 105.0
const JUMP_VELOCITY = -300.0
const ACCELERATION = 800.0
const FRICTION = 1000.0
const AIR_RESISTANCE = 200.0
const AIR_ACCELERATION = 400.0

var air_jump = false

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $coyotejumptimer
@onready var starting_position = global_position

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_wall_jump()
	handle_jump()
	var input_axis := Input.get_axis("move_left", "move_right")
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
func handle_wall_jump():
	if not is_on_wall_only(): return
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("move_left") and wall_normal == Vector2.LEFT:
		velocity.x = wall_normal.x * SPEED
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("move_right") and wall_normal == Vector2.RIGHT:
		velocity.x = wall_normal.x * SPEED
		velocity.y = JUMP_VELOCITY


		
func handle_jump():
	if is_on_floor(): air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
	elif  not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < JUMP_VELOCITY / 2:
			velocity.y = JUMP_VELOCITY / 2
	
		if Input.is_action_just_pressed("jump") and air_jump:
			velocity.y = JUMP_VELOCITY * 0.8
			air_jump = false
			
func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		
func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, AIR_RESISTANCE * delta)
			
func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, SPEED * input_axis, ACCELERATION * delta)
	
func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, SPEED * input_axis, AIR_ACCELERATION)
	
	
func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("Run")
	else:
		animated_sprite_2d.play("Idle")
	if not is_on_floor():
		animated_sprite_2d.play("Jump")
		

func _on_hazard_detector_area_entered(area:):
	global_position = starting_position
	pass # Replace with function body.
