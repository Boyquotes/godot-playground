extends CharacterBody2D

const MOTION_SPEED = 90.0

# puppet var puppet_pos = Vector2()
# puppet var puppet_motion = Vector2()
var puppet_pos = Vector2()
var puppet_motion = Vector2()

@export var stunned = false

# Use sync because it will be called everywhere
@rpc(any_peer, call_local) 
func setup_bomb(bomb_name, pos, by_who):
	var bomb = preload("res://bomb.tscn").instantiate()
	bomb.set_name(bomb_name) # Ensure unique name for the bomb
	bomb.position = pos
	bomb.from_player = by_who
	# No need to set network master to bomb, will be owned by server by default
	get_node("../..").add_child(bomb)

var current_anim = ""
var prev_bombing = false
var bomb_index = 0


func _physics_process(_delta):
	var motion = Vector2()

	if is_multiplayer_authority():
		if Input.is_action_pressed("move_left"):
			motion += Vector2(-1, 0)
		if Input.is_action_pressed("move_right"):
			motion += Vector2(1, 0)
		if Input.is_action_pressed("move_up"):
			motion += Vector2(0, -1)
		if Input.is_action_pressed("move_down"):
			motion += Vector2(0, 1)

		var bombing = Input.is_action_pressed("set_bomb")

		if stunned:
			bombing = false
			motion = Vector2()

		if bombing and not prev_bombing:
			var bomb_name = String(get_name()) + str(bomb_index)
			var bomb_pos = position
			rpc("setup_bomb", bomb_name, bomb_pos, multiplayer.get_unique_id())

		prev_bombing = bombing

		# rset("puppet_motion", motion)
		# rset("puppet_pos", position)
		rpc("set_puppet_motion_and_position", motion, position)
	else:
		position = puppet_pos
		motion = puppet_motion

	var new_anim = "standing"
	if motion.y < 0:
		new_anim = "walk_up"
	elif motion.y > 0:
		new_anim = "walk_down"
	elif motion.x < 0:
		new_anim = "walk_left"
	elif motion.x > 0:
		new_anim = "walk_right"

	if stunned:
		new_anim = "stunned"

	if new_anim != current_anim:
		current_anim = new_anim
		get_node("anim").play(current_anim)

	# FIXME: Use move_and_slide
	set_velocity(motion * MOTION_SPEED)
	move_and_slide()
	# if not is_multiplayer_authority():
	# 	puppet_pos = position # To avoid jitter


@rpc(call_local) 
func stun():
	stunned = true


# The master and mastersync rpc behavior is not officially supported anymore. Try using another keyword or making custom logic using get_multiplayer().get_remote_sender_id()
# @rpc(any_peer) 
@rpc(any_peer, call_local)
func exploded(_by_who):
	if not is_multiplayer_authority():
		# Only allow master
		return
	if stunned:
		return
	rpc("stun") # Stun puppets
	# stun() # Stun master - could use sync to do both at once


@rpc(unreliable)
func set_puppet_motion_and_position(motion, pos):
	puppet_motion = motion
	puppet_pos = pos
	# $Debug.text = "Id %d\n Motion: %s, Position: %s \n Called by %d" % [get_multiplayer_authority(), puppet_motion, puppet_pos, multiplayer.get_remote_sender_id()]


func set_player_name(new_name):
	get_node("label").set_text(new_name)


func _ready():
	stunned = false
	puppet_pos = position
