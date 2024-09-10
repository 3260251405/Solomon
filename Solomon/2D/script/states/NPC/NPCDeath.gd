extends State


func enter():
	owner.call_deferred("queue_free")
