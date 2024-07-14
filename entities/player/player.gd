extends CharacterBody2D

const SPEED = 1500.0
var maxhp = 5
var currenthp = 5
var damage = 1

var interactSize = null
var lastDirection = Vector2.ZERO
var aihbox = null
var dmghbox = null
var contactdamage = 0

var arenadimensions = Vector2.ZERO:
	set(value):
		$Camera2D.limit_top = -value.y / 2
		$Camera2D.limit_bottom = value.y / 2
		$Camera2D.limit_left = -value.x / 2
		$Camera2D.limit_right = value.x / 2
		arenadimensions = value
		

func _ready():
	aihbox = $"attack_interact_hitbox"
	dmghbox = $"damage_hitbox"
	dmghbox.maxhp = 5
	dmghbox.currenthp = 5
	dmghbox.monitoring = false
	aihbox.damage = 2
	
	

func _physics_process(delta):
	var direction = Vector2.ZERO
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction.x = Input.get_axis("A", "D")
	direction.y = Input.get_axis("W", "S")
	if direction:
		lastDirection = direction
		direction = direction.normalized()
		velocity = direction * SPEED
	else:
		#move_toward(from, to, delta)
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
		
			
	if Input.is_action_just_pressed("Roll"):
		print(position.angle_to(get_parent().get_node("bear_boss").position))
		pass
	var kb = dmghbox.get_knockback_vector()
	if kb:
		velocity = dmghbox.get_knockback_vector()
	move_and_slide()
	
	if Input.is_action_just_pressed("Attack interact"):
		#Interactable objects should be in the 3 layer.
		aihbox.interact_or_attack()
		
	
	aihbox.position = lastDirection * 100
		#The int(bool()) cast converts to 0 or 1. Non-zeros become 1.
		#This line is incredibly beefy. whoops. Just determining rotation in radians.
	aihbox.rotation = ((
		abs(((lastDirection.y + lastDirection.x * 0.5) / 
		(1 + int(bool(lastDirection.y)) * int(bool(lastDirection.x)))))
		 * PI))
	position.x = clamp(position.x, -arenadimensions.x / 2, arenadimensions.x / 2)
	position.y = clamp(position.y, -arenadimensions.y / 2, arenadimensions.y / 2)
		
func set_camera_limit(t = -10000000, b = 10000000, l = -10000000, r = 10000000):
	$Camera2D.limit_top = t
	$Camera2D.limit_bottom = b
	$Camera2D.limit_left = l
	$Camera2D.limit_right = r
	
func on_hit(caller, damage):
	dmghbox.on_hit(caller, damage)
