extends StaticBody2D

signal on_death

var dmghbox = null

var healthvalue = 0
const bee = preload("res://entities/interactable/enemies/bee_enemy.tscn")

enum trees {
	BASE,
	BERRY,
	BEE,
}
var treetype = null

func _ready():
	on_death.connect(get_parent().on_tree_death)
	dmghbox = $damage_hitbox
	dmghbox.maxhp = 3
	dmghbox.currenthp = 3
	dmghbox.on_death_s.connect(on_death_f)
	
func change_tree_type(tree = 0):
	#Meant for use only by parents during construction
	match int(tree):
		0:
			healthvalue = 0
		1:
			healthvalue = 1
		2:
			healthvalue = 2
	treetype = tree as trees

func _process(delta):
	pass

#func on_hit_f(caller, damage):
	#currenthp -= damage
	#if currenthp <= 0:
		#caller.currenthp += healthvalue
		#if caller.currenthp > caller.maxhp: caller.currenthp = caller.maxhp
		#if treetype == trees.BEE: 
			#var b = bee.instantiate()
			#b.position = Vector2.ZERO
			#b.set_bee_position(self.position)
			#get_parent().add_child(b)
		#on_death.emit()
		#queue_free()
		
func on_death_f(caller, dmg):
	var p = caller.get_parent()
	if "dmghbox" in p:
		p.dmghbox.heal(healthvalue)
	if treetype == trees.BEE: 
		var b = bee.instantiate()
		b.position = Vector2.ZERO
		b.set_bee_position(self.position)
		get_parent().add_child(b)
	on_death.emit()
	queue_free()
#func _on_area_2d_area_entered(area):
	#if "treetype" in area.get_parent() || area.get_parent().get_name() == "bear_boss":
		#queue_free()
