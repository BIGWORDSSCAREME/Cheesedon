extends "res://entities/interactable/enemy_base.gd"

const bullet = preload("res://entities/interactable/enemies/projectiles/projectile_base.tscn")
var parent = null

enum states {
	REST,
	CHASE,
	ATTACK
}

var state : states = states.CHASE
var bulletcount = 0

var target = Vector2.ZERO:
	set(value):
		if state == states.CHASE:
			#to_target returns Vector2.ZERO which evaluates to false
			#if the enemy is not far from their target.
			if timer.time_left == 0 && !to_target(value, position):
				timer.start()
			elif to_target(value, position):
				timer.stop()
			target = value
			return
			
		elif state == states.REST:
			if timer.time_left == 0 && to_target(value, position):
				timer.start()
				
		elif state == states.ATTACK:
			speed = 1000
			target = value
			if attackvelocity == Vector2.ZERO:
				attackvelocity = to_target(target, position)
			
	get:
		return target
		
#attackvelocity is used once in the attack phase. it remains constant.
var attackvelocity = Vector2.ZERO

var timer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	timer = Timer.new()
	timer.timeout.connect(_on_update_target_timer)
	timer.set_one_shot(true)
	timer.set_wait_time(2)
	add_child(timer)
	speed = 300
	damage = 1
	maxhealth = 5
	currenthealth = 5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#The parent changes target every process call
	velocity = _get_velocity(delta)
	move_and_collide(velocity)
	if !randi_range(0, 150) && state != states.ATTACK:
		_fire_projectile()

	
	#Before the bees do their main attack, they fire potshots at the player.
	
func _on_update_target_timer():
	match state:
		states.CHASE:
			state = states.REST
		states.REST:
			state = states.CHASE
		states.ATTACK:
			queue_free()
			
func change_state(nstate = "REST"):
	timer.stop
	match nstate:
		"REST":
			state = states.REST
		"CHASE":
			state = states.CHASE
		"ATTACK":
			state = states.ATTACK
			timer.start()
		_:
			state = states.REST

func _get_velocity(delta):
	if state == states.CHASE:
		return to_target(target, position, delta)
	if state == states.ATTACK:
		return attackvelocity * delta
	return Vector2.ZERO
	
func _fire_projectile():
	#Fires projectile towards player
	bulletcount += 1
	var b = bullet.instantiate()
	b.velocity = to_target(player.position, position) / speed
	b.position = self.position
	parent.add_child(b)
	
func on_hit(caller, dmg):
	super.on_hit(caller, dmg)
	print(currenthealth)

 
