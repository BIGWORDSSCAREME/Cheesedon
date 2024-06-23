extends "res://entities/interactable/enemy_base.gd"

var attacking = false
var currentAttack = bite_attack
var attackFrame = 0
var phase = 0

#Passed by bear_fight_scene
var treemap = null
var arenadimensions = null

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
	turnspeed = 0.01

func _physics_process(delta):
	#Before it takes damage from the player, it stays stationary, ignoring the player
	
	pathfind(treemap, _pos_to_grid(position), _pos_to_grid(player.position))
	
	
	if state == states.PASSIVE:
		pass
	elif state == states.FOLLOWING:
		#If following, find next square every time the center of the previous
		#square is reached. Or if a tree is destroyed.
		
		#Pick whether to attack or eat/retreat based on some logic. 
		#make some AI for moving in a more unpredictable way.
		#In the first phase, the bear cannot move through trees. Must knock them down
		#In the second phase the bear tears them down as its moving
		pass
	elif state == states.ATTACKING:
		rotation = turn_towards()
		
		#How does the boss decide to act?
		if !currentAttack:
			if attackFrame > 0:
				attackFrame = 0
		else:
			#Keep doing the attack. If currentAttack returns null, the next time it will not go.
			currentAttack = currentAttack.call(delta, attackFrame)
			attackFrame += 1
		

func claw_attack(delta, aframe = 0):
	const ATKSPEED = 0.05
	
	var graphstart = 1.25
	var length = 1

	if aframe == 0:
		#change this to the starting position of the hands
		$Sprite2D/AttackHitbox1.position = Vector2.ZERO
		$Sprite2D/AttackHitbox2.position = Vector2.ZERO
	
	#This counts down. The greater the aframe, the smaller the new aframe with
	#the following line. Generally keep the graph between -1 and 2
	aframe =-(aframe * ATKSPEED) + graphstart
	var tlate = pow(aframe, 3) + 2*pow(aframe, 2)
	
	if -length > aframe:
		$Sprite2D/AttackHitbox1.position = Vector2.ZERO
		$Sprite2D/AttackHitbox2.position = Vector2.ZERO
		return null
	else:
		#Multiply by delta * 60. If framerate is 60, then delta * 60 = 1,
		#else adjusts for change in framerate.
		$Sprite2D/AttackHitbox1.position = Vector2(-aframe*5 - 10, -tlate* 10 + 20) * delta * 60
		$Sprite2D/AttackHitbox2.position = Vector2(aframe*5 + 10, -tlate* 10 + 20) * delta * 60
		return claw_attack
	
func bite_attack(delta, aframe):
	#Also used for knife attack in second phase. Knife attack is a faster bite_attack
	#that goes many times 
	#Base bite_attack spawns a long rectangle in front of the bear. The bear lunges forward
	#and bites the player. This happens in the direction of the player, but the angle
	#is + or - by a random small ammount. The attack is close range, wide spread, but high damage.
	var length = 150
	if phase == 1: length = 30
	if aframe < 50:
		#Giving player some time to prepare. Doing the "tell". Queue animation.
		pass
	elif aframe == 50:
		var offset = randf_range(-1, 1)
		$Sprite2D/AttackHitbox1.position += Vector2(40, offset * 10)
		$Sprite2D/AttackHitbox1.rotation += offset * 0.5
		$Sprite2D/AttackHitbox1.scale = Vector2(3, 1)
	elif aframe > length:
		$Sprite2D/AttackHitbox1.transform = Transform2D.IDENTITY
		return null
	return bite_attack
	
func run_attack():
	pass

func summon_bees_attack():
	pass

func on_hit(caller, dmg):
	super.on_hit(caller, dmg)
	print("hit")
	if state == states.PASSIVE:
		state = states.ATTACKING
		currentAttack = bite_attack
		
		
func _pos_to_grid(pos: Vector2):
	#Vector2.ZERO in terms of the array is at -arenadimensions/2
	var p = ((pos / arenadimensions) * len(treemap)) + Vector2(len(treemap) / 2, len(treemap[0]) / 2)
	p.x = int(p.x)
	p.y = int(p.y)
	return p

