extends Node2D
#At the beginning of the fight, spawns a bunch of trees and stuff. Deletes
#them if the bear/player interacts. Sends the position of the trees to the
#bear.
#Probably distribute these in a semi-circle. The player is in a clearing when
#They enter the arena, and the trees form a half-circle above them.

signal bear_aggro

const tree = preload("res://entities/interactable/objects/bear_fight_tree.tscn")

#Defined by bear_fight_scene
var arenadimensions = null
var treelist = []

var killedtrees = 0

func _ready():
	bear_aggro.connect(get_parent().aggro_bear)

func _process(delta):
	pass

func _create_trees(num):
	#Unused worse version
	#Fewer bees than berries.
	#Some trees do nothing and are just destructable.
	#Get size of arena, then place trees based on that. Assuming 0,0 is the middle
	var r = arenadimensions.x / 2
	var c = Vector2(0, arenadimensions.y / 2)
	for i in num:
		var pos = c
		while Geometry2D.is_point_in_circle(pos, c, r):
			pos.x = randi_range(-arenadimensions.x / 2, arenadimensions.x / 2)
			pos.y = randi_range(-arenadimensions.y / 2, arenadimensions.y / 2)
		var t = tree.instantiate()
		t.position = pos
		t.change_tree_type(randi_range(0, 2))
		treelist.append(t)
		add_child(t)
		
		
func create_trees2(x, y, nooverlap = true):
	#GIVE THE BEAR THE GRID SO IT CAN DO PATHFINDING
	
	#Divides the area into quadrats. Only uses quadrats where the center point
	#is in bounds.
	#Probably want to stop trees from overlapping. Either add a border to each
	#quadrat where they cannot spawn (50% of tree size), or make trees despawn
	#each other when they land on top of each other.
	
	#Change this to be ~50 of width/height of tree. May want to use Vector2.
	var border = 0
	if nooverlap:
		border = 25
	
	#Circle center location and radius
	var cr = arenadimensions.x / 2
	var cc = Vector2(0, arenadimensions.y / 2)
	
	#Get the center of the first cell, then just add the width/height.
	var topleft = Vector2.ZERO - (Vector2(arenadimensions.x, arenadimensions.y) / 2)
	var cellsize = Vector2(arenadimensions.x / x, arenadimensions.y / y)
	var firstcellcenter = topleft + (cellsize / 2)
	var currentcelltl = Vector2.ZERO
	var currentcellbr = Vector2.ZERO
	var currentcellcenter = Vector2.ZERO
	var distancefromfirst = Vector2.ZERO
	
	#Add this to the top left of the current cell to get to
	#the center of the location within the cell.
	#Top left, top right, bottom left, bottom right
	var obstacleoffsets = [Vector2(cellsize.x * 0.25, cellsize.y * 0.25),
	Vector2(cellsize.x * 0.75, cellsize.y * 0.25),
	Vector2(cellsize.x * 0.25, cellsize.y * 0.75),
	Vector2(cellsize.x * 0.75, cellsize.y * 0.75)]
	var coordinatelocations = [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]
	
	var obstacles = []
	
	for i in x:
		for j in y:
			distancefromfirst = Vector2(i * cellsize.x, j * cellsize.y)
			currentcellcenter = firstcellcenter + distancefromfirst
			if Geometry2D.is_point_in_circle(currentcellcenter, cc, cr):
				continue
			else:
				currentcelltl = topleft + distancefromfirst
				currentcellbr = currentcelltl + cellsize
				var subcell = randi_range(0, 3)
				var pos = currentcelltl + obstacleoffsets[subcell]
				obstacles.append({"v": Vector2(i, j), "l": coordinatelocations[subcell]})
				
				
				#Old version.
				#while Geometry2D.is_point_in_circle(pos, cc, cr):
					#pos.x = randi_range(currentcelltl.x + border, currentcellbr.x - border)
					#pos.y = randi_range(currentcelltl.y + border, currentcellbr.y - border)
				var t = tree.instantiate()
				t.position = pos
				t.change_tree_type(randi_range(0, 2))
				treelist.append(t)
				add_child(t)
				
	var _make_array = func _make_array(x2, y2, obstaclearray):
		#Create an array based on these parameters.
		
		#sqrt of how many possible placements an obstacle has.
		const INCREASEFACTOR = 2
		
		x2 = x2 * INCREASEFACTOR
		y2 = y2 * INCREASEFACTOR
		var array = []
		for i in x2:
			array.append([])
			for j in y2:
				array[i].append(0)
		for obstacle in obstaclearray:
		#obstacles is a list of dicts that have a "v": Vector2 (cell coordinates)
		#and "l" location within cell. # of possible "l" is equal to OBSTACLELOCATIONS
			obstacle = Vector2(obstacle["v"] * INCREASEFACTOR + obstacle["l"])
			array[obstacle.x][obstacle.y] = 1
		
		return array
		
	obstacles = _make_array.call(x, y, obstacles)
	return obstacles

#func _draw():
	##Figure out boundaries of spawning stuff.
	#var r = arenadimensions.x / 2
	#var c = Vector2(0, arenadimensions.y / 2)
	#draw_circle(c, r, Color(255, 255, 255, 0.3))
	#draw_rect(Rect2(Vector2.ZERO - (Vector2(arenadimensions.x, arenadimensions.y) / 2),
		#Vector2(arenadimensions.x, arenadimensions.y)),  Color(0, 0, 255, 0.3), true)

func on_tree_death():
	killedtrees += 1
	if killedtrees == 7:
		bear_aggro.emit()
