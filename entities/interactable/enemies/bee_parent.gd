extends "res://entities/interactable/enemy_base.gd"

var target = null
var yoffset = null
var xoffset = null
var velocity1 = 0
var velocity2 = 0
var bee1 = null
var bee2 = null
#Each bee moves equally and opposite. Start at opposite points. 
#Both controlled by parent node.

func _ready():
	#Modify child values in this script, but let the child handle the movement
	#and everything. Use signals to tell one one bee has arrived.
	super._ready()
	$bee1.parent = self
	$bee2.parent = self
	speed = 600
	yoffset = randi_range(1, 100) * 10
	xoffset = randi_range(8, 15) * 10
	$bee1.target = player.position + Vector2(player.position.x + xoffset, yoffset)
	$bee2.target = player.position + Vector2(player.position.x - xoffset, yoffset)
	position = Vector2(0, 0)
	bee1 = get_node_or_null("bee1")
	bee2 = get_node_or_null("bee2")
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	bee1 = get_node_or_null("bee1")
	bee2 = get_node_or_null("bee2")
	#Sends the target every frame, but does the bee use the new target?
	if ($bee1.bulletcount > 4 && $bee2.bulletcount > 4 && randi_range(0, 100) == 0):
		#This node and children should destruct pretty quickly after this if.
		$bee1.change_state("ATTACK")
		$bee2.change_state("ATTACK")
		xoffset = -xoffset
		yoffset = -yoffset
	$bee1.target = player.position + Vector2(xoffset, yoffset)
	$bee2.target = player.position + Vector2(-xoffset, yoffset)
	


func change_target_position(pos: Vector2):
	$bee1.position -= pos - position
	$bee2.position -= pos - position
	position = pos
	
	

	




func _on_bee_tree_exiting():
	bee1 = get_node_or_null("bee1")
	bee2 = get_node_or_null("bee2")
	set_process(false)
	xoffset = -xoffset
	yoffset = -yoffset
	if bee1:
		$bee1.change_state("ATTACK")
		$bee1.target = player.position + Vector2(xoffset, yoffset)
	if bee2:
		$bee2.change_state("ATTACK")
		$bee2.target = player.position + Vector2(-xoffset, yoffset)
	if !bee1 && !bee2:
		queue_free()

func set_bee_position(pos):
	$bee1.position = pos
	$bee2.position = pos
