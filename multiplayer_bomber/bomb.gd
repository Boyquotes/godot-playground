extends Area2D

var in_area = []
var from_player

# Called from the animation.
func explode():
	if not is_multiplayer_authority():
		# Explode only checked master.
		return
	for p in in_area:
		if p.has_method("exploded"):
			# Bombs are always owned by server by default
			p.rpc("exploded", from_player)


func done():
	queue_free()


func _on_bomb_body_enter(body):
	if not body in in_area:
		in_area.append(body)


func _on_bomb_body_exit(body):
	in_area.erase(body)
