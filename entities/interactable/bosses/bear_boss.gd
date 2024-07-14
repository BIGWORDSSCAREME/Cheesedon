extends "res://entities/interactable/enemy_base.gd"

#Attack timer does not have a timeout function.- is just used
#to keep track of the duration of an attack. Calls _attack_done
#when done.
var attacktimer = null
#Cooldown timer called after an attack, and its timeout
#allows another attack to be made.
var cooldowntimer = null
#Dash timer is only used in the dash attack. Calls it and changes the phase
#of the dash attack.
var dashtimer = null
var dashstate = -1
#Probably change "attacking" to "attack_unavailable" or something
var attacking = false
var currentAttack = null
var attackphase = 0
var phase = 0
var target = null

#Passed by bear_fight_scene
var treemap = null
var arenadimensions = null
var cellsize = null

const BASESPEED = 500
const MAXHP = 100

var overlapping = []

enum states {
	PASSIVE,
	ATTACKING,
	EATING,
	FOLLOWING
}
func change_state(nstate):
	match nstate:
		"PASSIVE":
			state = states.PASSIVE
		"ATTACKING":
			state = states.ATTACKING
		"EATING":
			state = states.EATING
		"FOLLOWING":
			state = states.FOLLOWING

var state = states.PASSIVE


func _ready():
	super._ready()
	_get_hitboxes()
	dmghbox.on_hit_s.connect(on_hit_f)
	dmghbox.on_death_s.connect(on_death_f)
	currenthp = MAXHP
	contactdamage = 3
	attacktimer = Timer.new()
	attacktimer.set_one_shot(true)
	attacktimer.timeout.connect(_attack_done)
	add_child(attacktimer)
	cooldowntimer = Timer.new()
	cooldowntimer.set_one_shot(true)
	cooldowntimer.timeout.connect(_cooldown_done)
	add_child(cooldowntimer)
	dashtimer = Timer.new()
	dashtimer.set_one_shot(true)
	dashtimer.timeout.connect(_dash_attack)
	add_child(dashtimer)
	turnspeed = 0.01
	speed = BASESPEED
	currentAttack = _bite_attack
	attacking = true
	


#Refactor some of this. Maybe have something like:
#if currentattack:
	#currentattack.call()
#Execute for every physics_process. Make sure waking up the bear enables 
#_physics_process().
#Make every attack fit into that call. May need some other variables to
#help out. Put all those declerations in one place with a comment
#explaining them.
#Have some helper functions called by the attack functions too.

func _physics_process(delta):
	#Before it takes damage frsom the player, it stays stationary, ignoring the player
	if currentAttack != null:
		currentAttack = currentAttack.call()
	velocity = Vector2.ZERO
	if state == states.PASSIVE:
		pass
	elif state == states.FOLLOWING:
		#Bear has 2 modes of following. A faster dash that doesn't change
		#target for the duration, and a slower follow mode. In the slower
		#mode, knocking down trees slows the bear down.
		if dashstate == -1 && !randi_range(0, 150):
			#Use get player angle to in direction of player. Set timer when dash starts
			#that will allow bear to get to player plus some. When timer goes off,
			#dash ends, stun begins, then back to normal.
			
			#Dash works with timer connecting different function after each goes off.
			#MUCH OF THE LOGIC+STUFF CONTAINED IN THE _dash<x> functions.
			dashstate = 0
			_dash_attack()
			print("dashing")
		elif dashstate != 1 && dashstate != 2:
			target = player.position
			speed = BASESPEED


		if dashstate == 1 && (position.x > arenadimensions.x / 2 || position.x < -arenadimensions.x / 2 || \
		position.y > arenadimensions.y / 2 || position.y < - arenadimensions.y / 2):
		#If the bear hits a wall early, then stop the timer and call the next function.
			print("Dashed out of bounds!")
			dashtimer.stop()			
			dashstate = 1
			_dash_attack()
			
			
		velocity = to_target(target, position, delta)


	if currentAttack:
		pass
		#currentAttack.call()
	elif state == states.ATTACKING && !attacking:
		#Have some checks here to see if player is in a good position
		#for a specific attack
		pass

	move_and_collide(velocity)
	position.x = clamp(position.x, -arenadimensions.x / 2, arenadimensions.x / 2)
	position.y = clamp(position.y, -arenadimensions.y / 2, arenadimensions.y / 2)
		
		
	#elif state == states.ATTACKING:
		#rotation = turn_towards()
		#
		##How does the boss decide to act?
		#if !currentAttack:
			#if attackFrame > 0:
				#attackFrame = 0
		#else:
			##Keep doing the attack. If currentAttack returns null, the next time it will not go.
			#currentAttack = currentAttack.call(delta, attackFrame)
			#attackFrame += 1
	

func _claw_attack():
	if attacktimer.wait_time != 2:
		attacktimer.set_wait_time(2)
	if attacktimer.is_stopped():
		#Change this to the starting position of the hands
		$Sprite2D/AttackHitbox1.position = Vector2.ZERO
		$Sprite2D/AttackHitbox2.position = Vector2.ZERO
		#Make sure to set attacking to true before calling these functions.
		if !attacking: return null
		attacktimer.start()
		attacking = true
		
	const ATKSPEED = 0.025
	
	var aframe = _timeleft_to_percent(attacktimer.time_left, attacktimer.wait_time)	
	var graphstart = 1.25
	var length = 1
	
	#This counts down. The greater the aframe, the smaller the new aframe with
	#the following line. Generally keep the graph between -1 and 2
	aframe = -(aframe * ATKSPEED) + graphstart
	var tlate = pow(aframe, 3) + 2*pow(aframe, 2)
	

	#Double check that delta is unneeded. I believe timers account for delta.
	$Sprite2D/AttackHitbox1.position = Vector2(-aframe*5 - 10, -tlate* 10 + 20)
	$Sprite2D/AttackHitbox2.position = Vector2(aframe*5 + 10, -tlate* 10 + 20)
	return _claw_attack
	
func _bite_attack():
	#Also used for knife attack in second phase. Knife attack is a faster bite_attack
	#that goes many times 
	#Base bite_attack spawns a long rectangle in front of the bear. The bear lunges forward
	#and bites the player. This happens in the direction of the player, but the angle
	#is + or - by a random small ammount. The attack is close range, wide spread, and high damage.
	if attacktimer.wait_time != 2:
		attacktimer.set_wait_time(2)
	if attacktimer.is_stopped():
		#Change this to the starting position of the hitbox
		$Sprite2D/AttackHitbox1.transform = Transform2D.IDENTITY
		#Make sure to set attacking to true before calling these functions.
		if !attacking: return null; attackphase = 0
		attacktimer.start()
		attacking = true
	var aframe = _timeleft_to_percent(attacktimer.time_left, attacktimer.wait_time)
	if aframe < 25:
		#Giving player some time to prepare. Doing the "tell". Queue animation.
		pass
	elif attackphase == 0:
		#make this go towards the player.
		var offset = randf_range(-1, 1)
		#Might need to do some array math for the line below.
		#Like [40, offset * 10] * [sin(x), cos(x)] or something. I'm not sure.
		#     [40, offset * 10] 
		$Sprite2D/AttackHitbox1.position += Vector2(40, offset * 10)
		$Sprite2D/AttackHitbox1.rotation += offset * 0.5 + get_player_angle()[0]
		$Sprite2D/AttackHitbox1.scale = Vector2(3, 1)
		attackphase = 1
	return _bite_attack

func on_hit_f(caller, dmg):
	if state == states.PASSIVE:
		state = states.FOLLOWING
		currentAttack = _bite_attack
		
func on_death_f():
	queue_free()
	
func _pos_to_grid(pos: Vector2):
	#Vector2.ZERO in terms of the array is at -arenadimensions/2
	var p = ((pos / arenadimensions) * len(treemap)) + Vector2(len(treemap) / 2, len(treemap[0]) / 2)
	p.x = int(p.x)
	p.y = int(p.y)
	return p
	
func _grid_to_pos(pos: Vector2):
	
	pos -= Vector2(len(treemap), len(treemap[0])) / 2
	return (pos * (arenadimensions / Vector2(len(treemap), len(treemap[0])) )) + (cellsize / 2)

func _dash_attack():
	if dashstate == 0:
		#Starting a dash towards the player position. Will continue
		#towards the same (unmoving) position until timer goes off (dashstate is now 1).
		attacking = true
		dashstate = 1
		speed = BASESPEED * 3
		var distance = position.distance_to(player.position)
		dashtimer.set_wait_time((distance / speed) * 2)
		dashtimer.start()
		target = player.position
	elif dashstate == 1:
		#The dash is complete. The bear rests for a moment before it returns
		#to other behavior!
		dashstate = 2
		dashtimer.set_wait_time(1)
		dashtimer.start()
		speed = 0
	elif dashstate == 2:
		#Starts normal behavior again. Once the timer runs out, the bear
		#will be able to dash again.
		dashstate = 3
		cooldowntimer.set_wait_time(3)
		cooldowntimer.start()
		speed = BASESPEED
		dashtimer.set_wait_time(5)
		dashtimer.start()
	elif dashstate == 3:
		#Allows the bear to dash again.
		dashstate = -1
		
func _cooldown_done():
	attacking = false
	
func _attack_done():
	attacking = false

func _timeleft_to_percent(timeleft, waittime):
	return (1 - (timeleft / waittime)) * 100
