extends HitBox

var speed := 320
var direction := Vector2.RIGHT:
	set(v):
		direction = v
		rotation = direction.angle()
		

func _ready():
	if owner == null:
		owner = get_onwer(get_parent())
		
	await get_tree().create_timer(5).timeout
	queue_free()


func get_onwer(body):
	if body is People:
		return body
	return get_onwer(body.get_parent())


func _physics_process(delta):
	#position += (Vector2.RIGHT * speed).rotated(rotation) * delta
	position += direction * speed * delta


func _on_hit(hurtbox):
	if hurtbox.owner == owner:
		return
		
	if owner is NPC and !owner.hateBodies.has(hurtbox.owner):
		return
		
	queue_free()
