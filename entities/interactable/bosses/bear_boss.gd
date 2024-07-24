extends "res://entities/interactable/enemy_base.gd"

#Attack timer does not have a timeout function.- is just used
#to keep track of the duration of an attack. Calls _attack_done
#when done.
var attacktimer = null
#Cooldown timer called after an attack, and its timeout
#allows another attack to be made.
var cooldowntimer = null
var attackcooldowndone = true
#Set to false before attacking, set to true by attacktimer's timeout.
var attackdone = false
var ahbox1 = null
var ahbox2 = null

var attacks = [_bite_attack, _claw_attack]

#Dash timer is only used in the dash attack. Calls it and changes the phase
#of the dash attack.
var dashtimer = null
var dashstate = -1



var currentAttack = null
var attackphase = 0
var phase = 0
var target = null

#Passed by bear_fight_scene
var treemap = null
var arenadimensions = null
var cellsize = null

const BASESPEED = 500

var overlapping = []

enum states {
	PASSIVE,
	ACTIVE,
	EATING
}
func change_state(nstate):
	match nstate:
		"PASSIVE":
			state = states.PASSIVE
		"ACTIVE":
			state = states.ACTIVE
		"EATING":
			state = states.EATING


var state = states.PASSIVE


func _ready():
	super._ready()
	_get_hitboxes()
	ahbox1 = $Sprite2D/AttackHitbox1
	ahbox2 = $Sprite2D/AttackHitbox2
	dmghbox.on_hit_s.connect(on_hit_f)
	dmghbox.on_death_s.connect(on_death_f)
	dmghbox.maxhp = 100
	dmghbox.currenthp = dmghbox.maxhp
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
	attackdone = true
	set_physics_process(false)

func _physics_process(delta):
	velocity = Vector2.ZERO
	if currentAttack != null:
		attackdone = false
		attackcooldowndone = false
		currentAttack = currentAttack.call()
	elif state == states.ACTIVE:
		target = player.position
		velocity = to_target(target, position, delta)
		if attackcooldowndone && !randi_range(0, 150):
			#Have some checks here to see if player is in a good position
			#for a specific attack. (bite, claw, dash, etc), or pick randomly.
			#Bite attack if player is near the front of the bear, claw if its
			#near the bear but not in front.
			#Calculate euclidian distance, then direction of player.
			print("attack")
			currentAttack = attacks[randi_range(0, len(attacks) - 1)]
			
	move_and_collide(velocity)
	position.x = clamp(position.x, -arenadimensions.x / 2, arenadimensions.x / 2)
	position.y = clamp(position.y, -arenadimensions.y / 2, arenadimensions.y / 2)
		
	

func _claw_attack():
	if attacktimer.wait_time != 2:
		attacktimer.set_wait_time(2)
	if attacktimer.is_stopped():
		#Change this to the starting position of the hands
		_reset_hitboxes()
		#Make sure to set attacking to true before calling these functions.
		#Reminder: when attacktimer expires it calls _attack_done which
		#changes attacking to false.
		if attackdone: return null; cooldowntimer.start()
		attacktimer.start()
		
	const ATKSPEED = 0.025
	
	var aframe = _timeleft_to_percent(attacktimer.time_left, attacktimer.wait_time)	
	var graphstart = 1.25
	var length = 1
	
	#This counts down. The greater the aframe, the smaller the new aframe with
	#the following line. Generally keep the graph between -1 and 2
	aframe = -(aframe * ATKSPEED) + graphstart
	var tlate = pow(aframe, 3) + 2*pow(aframe, 2)
	

	#Double check that delta is unneeded. I believe timers account for delta.
	ahbox1.position = Vector2(-aframe*5 - 10, -tlate* 10 + 20)
	ahbox2.position = Vector2(aframe*5 + 10, -tlate* 10 + 20)
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
		_reset_hitboxes
		#Make sure to set attacking to true before calling these functions.
		if attackdone: return null; attackphase = 0; cooldowntimer.start()
		attacktimer.start()
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

func _reset_hitboxes():
	ahbox1.transform = Transform2D.IDENTITY
	ahbox2.transform = Transform2D.IDENTITY
		

func on_hit_f(caller, dmg):
	if state == states.PASSIVE:
		state = states.ACTIVE
		currentAttack = _bite_attack
		set_physics_process(true)
		
func on_death_f(caller, dmg):
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
	attackcooldowndone = true
	
func _attack_done():
	attackdone = false
	currentAttack = null
	attackphase = 0
	_reset_hitboxes()
	cooldowntimer.start()

func _timeleft_to_percent(timeleft, waittime):
	return (1 - (timeleft / waittime)) * 100
