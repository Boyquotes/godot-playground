# Created by sh1n24

extends Node2D

export (float) var impact_time = .6

var direction: Vector2

func _ready():
	play_anim()
	$ImpactWave.material = $ImpactWave.material.duplicate(true)
	$Tween.interpolate_method(self, "impact", 0, 1, impact_time, Tween.TRANS_LINEAR, Tween.EASE_IN);
	$Tween.start()
	$Timer.start()

func play_anim():
	var anim = "up";
	if direction.y < 0:
		if direction.x < 0:
			anim = "upleft"
		elif direction.x > 0:
			anim = "upright"
		else:
			anim = "up"
	elif direction.y > 0:
		if direction.x < 0:
			anim = "downleft"
		elif direction.x > 0:
			anim = "downright"
		else:
			anim = "down"
	else:
		if direction.x < 0:
			anim = "left"
		elif direction.x > 0:
			anim = "right"
	$ImpactAnim.play(anim)
	pass

func impact(value: float):
	$ImpactWave.material.set_shader_param("u_radius", value)

func _on_Timer_timeout():
	queue_free()
