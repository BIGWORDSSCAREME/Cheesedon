extends Camera2D

var timer = null

var speed = 1000
var velocity = Vector2.ZERO
var target = Vector2.ZERO

func _ready():
	timer = Timer.new()
	timer.timeout.connect(_start_moving_cam)
	timer.set_one_shot(true)
	timer.set_wait_time(0.25)
	add_child(timer)
	set_physics_process(false)

func _physics_process(delta):
	velocity = to_target(target, position, delta)
	position += velocity
	if velocity == Vector2.ZERO:
		#Taking longer than it should maybe because it reaches the edge of the screen.
		timer.set_wait_time(2)
		var p = get_parent()
		set_physics_process(false)
		p.set_physics_process(true)
		position = target
		if target == Vector2.ZERO:
			#If we are at the target, and the target is Vector2.ZERO
			return _stop_cutscene()
		do_cutscene(p.position + Vector2.ZERO)

func do_cutscene(pos):
	#Linger for a bit, then move back to player.
	var p = get_parent()
	p.set_physics_process(false)
	timer.start()
	target = pos - p.position

func _start_moving_cam():
	set_physics_process(true)
	
func _stop_cutscene():
	get_parent().set_physics_process(true)
	set_physics_process(false)

func to_target(target, pos, delta = 1):
	#COPIED AND PASTED FROM ENEMY_BASE
	#Returns a Vector2 of speed*delta headed towards target.
	#I think normalizing this is a problem for small #'s
	var dif = abs(target - pos)
	return Vector2.ZERO if ( dif.x < 10 && dif.y < 10 )\
	 else (target - pos).normalized() * speed * delta
