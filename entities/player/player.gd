extends CharacterBody2D

const SPEED = 1500.0
var maxhp = 5
var currenthp = 5
var damage = 1

var interactSize = null
var lastDirection = Vector2.ZERO
var interactable = []

var arenadimensions = Vector2.ZERO:
	set(value):
		$Camera2D.limit_top = -value.y / 2
		$Camera2D.limit_bottom = value.y / 2
		$Camera2D.limit_left = -value.x / 2
		$Camera2D.limit_right = value.x / 2
		arenadimensions = value
		

func _ready():
	pass
	
	

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
		pass
	move_and_slide()
	
	if Input.is_action_just_pressed("Attack interact"):
		#Interactable objects should be in the 3 layer.
		if interactable:
			var p = interactable[0].get_parent()
			if p.has_method("on_interact"):
				#Does funky stuff if many things in the interactable list.
				p.on_interact(self)
			for i in interactable:
				p = i.get_parent()
				if p.has_method("on_hit"):
				#Probably pass the player's damage or something.
					p.on_hit(self, damage)
		
	
	$"Attack_interact Hitbox".position = lastDirection * 100
		#The int(bool()) cast converts to 0 or 1. Non-zeros become 1.
		#This line is incredibly beefy. whoops. Just determining rotation in radians.
	$"Attack_interact Hitbox".rotation = ((
		abs(((lastDirection.y + lastDirection.x * 0.5) / 
		(1 + int(bool(lastDirection.y)) * int(bool(lastDirection.x)))))
		 * PI))
	position.x = clamp(position.x, -arenadimensions.x / 2, arenadimensions.x / 2)
	position.y = clamp(position.y, -arenadimensions.y / 2, arenadimensions.y / 2)



func _on_attack_interact_hitbox_area_entered(area):
	if !area in interactable:
		interactable.append(area)

func _on_attack_interact_hitbox_area_exited(area):
	interactable.erase(area)


func _on_player_damage_hitbox_area_entered(area):
	#Only damages when areas initially collide. Maybe use a timer here,
	#And if currentenemy != null, then deal damage.
	var p = area.get_parent()
	if "damage" in p:
		currenthp -= p.damage
	
func set_camera_limit(t = -10000000, b = 10000000, l = -10000000, r = 10000000):
	$Camera2D.limit_top = t
	$Camera2D.limit_bottom = b
	$Camera2D.limit_left = l
	$Camera2D.limit_right = r
