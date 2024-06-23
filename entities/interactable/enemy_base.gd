extends AnimatableBody2D

var player = null
var velocity = Vector2.ZERO

var damage = 0
var maxhealth = 0
var currenthealth = 0
var speed = 0
var turnspeed : float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	sync_to_physics = false
	get_player()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_player():
	#Try not to let this be null
	player = get_tree().get_root().find_child("Player", true, false)




func get_player_angle():
	#Returns angle that player is at from enemy
	#Get position of player. Get bosition of enemy.
	#Triangle is easily constructed from points. Use sin and cosin of lengths.
	var playerpos = player.position
	#playerpos = (x,y)
	#pos = (x,y)
	#tan(theta) = O/A
	playerpos -= position
	var h = sqrt(pow(playerpos.x, 2) + pow(playerpos.y, 2))
	return [atan2(playerpos.y, playerpos.x), asin(playerpos.y/h), acos(playerpos.x/h)]
	
func turn_towards(x = null):
	#increment by turn speed based on sign, don't go over.
	rotation = fmod(rotation, 2 * PI)
	var p = x
	if x == null:
		p = get_player_angle()[0]
	
	var dif = abs(p - rotation)
	dif = dif if dif < PI else (2 * PI) - dif
	#If dif is less with a +1, use that, if its less with -1, use that.
	var posrot = abs(p - (rotation + turnspeed))
	posrot = posrot if posrot < PI else (2 * PI) - posrot
	var negrot = abs(p - (rotation + -turnspeed))
	negrot = negrot if negrot < PI else (2 * PI) - negrot
	var s = 1 if abs(posrot) < abs(negrot) else -1
	
	
	#use these and find difference to figure out which direction i should go in.
	#Has problems when you go Up and down to its left. This is where it goes from + to -
	return rotation + s * turnspeed

func to_target(target, pos, delta = 1):
	#Returns a Vector2 of speed*delta headed towards target.
	#I think normalizing this is a problem for small #'s
	var dif = abs(target - pos)
	return Vector2.ZERO if ( dif.x < 10 && dif.y < 10 )\
	 else (target - pos).normalized() * speed * delta
	
func on_hit(caller, dmg):
	if caller == player:
		currenthealth -= dmg
	if currenthealth == 0:
		queue_free()

func death():
	queue_free()
	
func pathfind(array, start: Vector2, end: Vector2) -> Array:
	#Uses A* with manhatten distance
	
	if start == end: return [start]
	
	var closed = {}
	var openl = []
	#pos, previous: Vector2. G, H, F: int
	var opend = {}
	var adjacentcells = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1)]
	
	var xlen = len(array)
	var ylen = len(array[0])
	
	var mhd = func _manhatten_distance(p1, p2):
		return abs(p1.x - p2.x) + abs(p1.y - p2.y)
		
	var search = func _least_distance(a, b):
		#G score - distance away from start
		#H score - distance away from target
		#F score - G score + H score
		return opend[str(a)]['F'] < opend[str(b)]['F']
		
	var returnvalue = func _get_next(last):
		var l = []
		var current = last
		while current['previous'] != null:
			l.append(current['pos'])
			current = opend[str(current['previous'])]
		return l
		
		
	
	
	openl.append(start)
	opend[str(start)] = {'pos': start, 'previous': null, 'G': 0}
	
	var i = 0
	while len(openl) != 0:
		#i+=1
		#print(i)
		for acell in adjacentcells:
			var searchingcell = opend[str(openl[0])]
			
			var pos = searchingcell['pos'] + acell
			var g = 1 + opend[str(openl[0])]['G']
			var h = mhd.call(pos, end)
			var previous = searchingcell['pos']
			
			if pos == end:
				#Figure out what it returns.
				return returnvalue.call({'pos': end, 'previous': searchingcell['pos']})
			
			if !(str(pos) in closed.keys() || pos.x < 0 || pos.y < 0 || pos.x >= xlen || pos.y >= ylen):
				if !(pos in openl):
					openl.append(pos)
					opend[str(pos)] = {'pos': pos, 'previous': searchingcell['pos'],
					'G': g, 'H': h, 'F': h + g}
				elif opend[str(pos)]['G'] > g:
					#If we have already visited this cell, but there is a faster
					#way to get there, then update G, F, and previous.
					opend[str(pos)]['G'] = g
					opend[str(pos)]['F'] = g + opend[str(pos)]['H']
					opend[str(pos)]['previous'] = pos
		var lastsearched = openl.pop_front()
		closed[str(lastsearched)] = opend[str(lastsearched)]
		openl.sort_custom(search)
	
	#If this returns an empty array, something fucked up. Prolly just no viable route.
	return []
	
	
