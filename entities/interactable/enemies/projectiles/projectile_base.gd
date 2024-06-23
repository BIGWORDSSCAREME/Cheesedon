extends "res://entities/interactable/enemy_base.gd"

var timer = null

func _ready():
	super._ready()
	timer = Timer.new()
	timer.timeout.connect(_bullet_death)
	timer.set_one_shot(true)
	timer.set_wait_time(4)
	add_child(timer)
	timer.start()
	speed = 1500
	damage = 1


func _process(delta):
	move_and_collide(velocity * delta * speed)
	
func _bullet_death():
	self.queue_free()
