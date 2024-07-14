extends Area2D

var knockbackvect = Vector2.ZERO
var cooldowntimer = null
var overlapping = []

var contactdamage = 0
var maxhp = 0
var currenthp = 0

signal on_hit_s
signal on_death_s
#add signals for taking damage and dying.

#MAKE A WAY TO DISABLED _on_area_entered!!

##############################################################################
#HOW TO MAKE THIS WORK!!! VVVVVV
#1. The real coding is the friends we made along the way.
#2. Disable _on_area_entered if no contact damage is wanted.
#3. Parent must add get_knockback_vector to velocity to recieve knockback.
#4. This hitbox should be slightly bigger than the parent for collisions.
#5. Assign values for contactdamage, currenthp, maxhp in the parent.
#6. Connect parent to on_hit_s/on_death_s signals if any specific behavior wanted.
#Can I add a function to do all of this? Maybe with settings.
##############################################################################

func _ready():
	cooldowntimer = Timer.new()
	cooldowntimer.set_one_shot(true)
	cooldowntimer.set_wait_time(1)
	add_child(cooldowntimer)

func _on_area_entered(area):
	if area.has_method("on_hit") && !(area in overlapping):
		area.on_hit(self, contactdamage)

func on_hit(caller, dmg):
	#MUST HAVE on_hit() function in parent
	if cooldowntimer.time_left == 0:
		if dmg != 0:
			cooldowntimer.start()
		currenthp -= dmg
		knockbackvect = calc_initial_knockback(caller, dmg)
		on_hit_s.emit(caller, dmg)
		if currenthp <= 0: on_death_s.emit(caller, dmg)

func heal(dmg):
	currenthp += dmg
	if currenthp > maxhp: currenthp = maxhp

func calc_initial_knockback(caller, dmg):
	#Get angle of enemy. Apply knockback in opposite direction,
	#multiplied by dmg
	#var angle = caller.position.angle_to(p.position)
	#Not really sure why the above line doesn't work.
	#Stuff below is taken from get_player_ange in enemy_base.
	var angle = caller.global_position - global_position
	var h = sqrt(pow(angle.x, 2) + pow(angle.y, 2))
	return -Vector2(acos(angle.x/h) - PI / 2, -asin(angle.y/h)).normalized() * (1000)

func get_knockback_vector() -> Vector2:
	#Calculates knockback from damage. This must then be added to velocity
	#of parent manually
	knockbackvect = knockbackvect.move_toward(Vector2.ZERO, 60)
	return knockbackvect
