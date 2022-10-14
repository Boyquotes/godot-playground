extends CharacterBody2D

@rpc(call_local)
func do_explosion():
	$"AnimationPlayer".play("explode")


# Received by owner of the rock
@rpc(any_peer, call_local)
func exploded(by_who):
	if not is_multiplayer_authority():
		# Only allow master
		return
	$"../../Score".rpc("increase_score", by_who)
	rpc("do_explosion")
