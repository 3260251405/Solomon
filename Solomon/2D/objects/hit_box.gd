extends Area2D

class_name HitBox

signal hit(hurtbox)

func _on_area_entered(area: HurtBox):
	hit.emit(area)
	area.hurt.emit(self)
