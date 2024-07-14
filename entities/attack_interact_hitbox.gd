extends Area2D

var damage = 0
var interactable = []

signal on_enemy_hit_s(enemy: Node)

#TODO: make sure this stuff works. Test player knockback.

##############################################################################
#HOW TO MAKE THIS WORK!!! VVVVVV
#1. Parent must have interact_or_attack() called in _physics_process()
#2. Assign value for damage in parent.
##############################################################################
	
func _on_area_entered(area):
	if area.has_method("on_hit") && !(area in interactable):
		interactable.append(area)

func _on_area_exited(area):
	interactable.erase(area)

func interact_or_attack():
	for i in interactable:
		i.on_hit(self, damage)
		on_enemy_hit_s.emit(i)
