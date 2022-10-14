extends HBoxContainer

var player_labels = {}

func _process(_delta):
	var rocks_left = $"../Rocks".get_child_count()
	if rocks_left == 0:
		var winner_name = ""
		var winner_score = 0
		for p in player_labels:
			if player_labels[p].score > winner_score:
				winner_score = player_labels[p].score
				winner_name = player_labels[p].name

		$"../Winner".set_text("THE WINNER IS:\n" + winner_name)
		$"../Winner".show()


@rpc(any_peer, call_local) 
func increase_score(for_who):
	assert(for_who in player_labels)
	var pl = player_labels[for_who]
	pl.score += 1
	pl.label.set_text(pl.name + "\n" + str(pl.score))


func add_player(id, new_player_name):
	var l := Label.new()
#	l.set_align(Label.ALIGNMENT_CENTER)
	l.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	l.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	l.set_text(new_player_name + "\n" + "0")
	l.set_h_size_flags(SIZE_EXPAND_FILL)
#	var font = FontFile.new()
#	font.set_size(18)
#	font.set_font_data(preload("res://montserrat.otf"))
#	l.add_theme_font_override("font", font)
	var font = load("res://montserrat.otf")
	l.set("custom_fonts/font", font)
	l.set("custom_fonts/font_size", 64)

	add_child(l)

	player_labels[id] = { name = new_player_name, label = l, score = 0 }


func _ready():
	$"../Winner".hide()
	set_process(true)


func _on_exit_game_pressed():
	gamestate.end_game()
