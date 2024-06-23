extends Node2D

var player = null
var bear = null
var trees = null

#To make this fit to screen, width must be equal to get_viewport_rect().size * 4 
#and project settings>display>window>aspect = ignore, if window changes size.
#May want to mess with this. I think that stretches it a bit which is not great.
#Might just want to have some black bars.
var arenadimensions = Vector2(4608, 5000)

func _ready():
	var r = get_tree().get_root()
	player = r.find_child("Player", true, false)
	player.arenadimensions = arenadimensions
	player.position = Vector2(0, (arenadimensions.y / 2) - 500)
	
	bear = r.find_child("bear_boss", true, false)
	
	player.find_child("Camera2D", true, false).do_cutscene(bear.position)
	
	trees = get_tree().get_root().find_child("bear_fight_tree_parent", true, false)
	trees.arenadimensions = arenadimensions
	bear.treemap = trees.create_trees2(10, 10)
	bear.arenadimensions = arenadimensions


func _process(delta):
	pass

func aggro_bear():
	bear.change_state("AGGRO")
