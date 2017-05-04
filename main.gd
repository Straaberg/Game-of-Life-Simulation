extends Node2D

var grid = IntArray([0]) # game grid
var running = false # is the simulation running
var waiting = 0 # var to calculate wait time in _process 
var generation = 0 # current generation in simulation
var activebrush = 0 # number of brush, 0: no brush, clicking toggles cell

const LOOPDELAY = 0.5  # seconds, speed of simulation
const GRIDSIDE = 42 # columns and rows in grid
const GRIDSIZE = GRIDSIDE*GRIDSIDE 
const DEADCELL = 0
const LIVECELL = 1
const CELLSIZE = 12 # pixels width + height
const CELLSPACING = 2 # pixels all around
const GRIDOFFSET = Vector2(380,30) # where does the grid show on the canvas
const DEADCOLOR = Color(0.4, 0.4, 0.6) 
const LIVECOLOR = Color(1, 1, 1)
const MAXBRUSH = 3 # number of defined brushes
const OFFSET = CELLSIZE + CELLSPACING  # calc pixel offset used for brushes
const BRUSHPRESSED = Color(0.9, 0.9, 0.95, 0.6)  # color modulation on pressed button
const BRUSHRELEASED = Color(1, 1, 1, 1)  # color modulation on unpressed button


func _ready():
	set_process(true)
	set_process_input(true)
	grid.resize(GRIDSIZE)
	reset_grid(true)
	
	
func _process(delta):
	if (running):
		waiting += delta
		if (waiting >= LOOPDELAY):
			waiting = 0
			update_grid()
	
	
func _input(event):
	if (event.type == InputEvent.MOUSE_BUTTON):
		if (event.is_pressed() && !event.is_echo()):
			if (activebrush == 0):   # behaviour if no brush is selected
				change_cell(event.pos.x, event.pos.y)
			if (activebrush > 0):
				set_brush_in_grid(activebrush, event.pos.x, event.pos.y)
	
	
func _draw():
	var i = 0
	var x = 0
	var y = 0
	var newcell = Rect2(0, 0, 0, 0)
	var c = DEADCOLOR

	while i <GRIDSIZE:
		x = fmod(i, GRIDSIDE)
		y = floor(i / GRIDSIDE)
		newcell = Rect2(GRIDOFFSET.x + x * (CELLSIZE + CELLSPACING), GRIDOFFSET.y + y * (CELLSIZE + CELLSPACING), CELLSIZE, CELLSIZE)
		if (grid[i] == DEADCELL):
			c = DEADCOLOR
		else:
			c = LIVECOLOR
		draw_rect(newcell, c)
		i += 1


### FUNCTIONS ###


func change_cell(clicked_x, clicked_y):
	# clicked_x/y position 
	# transformed to match grid x, y
	# if click is on a cell in grid, cell is switched from 0 to 1 or 1 to 0
	var i = transform_clicked_pos_to_index(clicked_x, clicked_y)
		
	if (i > -1):
		if (grid[i] == LIVECELL):
			grid[i] = DEADCELL
		else:
			grid[i] = LIVECELL
		update()


func transform_clicked_pos_to_index(clicked_x, clicked_y):
	# helper function to calculate grid index from actual clicked position
	var x = -1
	var y = -1
	if (clicked_x>=GRIDOFFSET.x && clicked_y>=GRIDOFFSET.y):
		x = int((clicked_x - GRIDOFFSET.x) / (CELLSIZE+CELLSPACING))
		y = int((clicked_y - GRIDOFFSET.y) / (CELLSIZE+CELLSPACING))
	
	return calc_index_from_coord(x, y)


func calc_index_from_coord(x, y):
	# x and y >=0   <GRIDSIDE
	# return index in array >=0 <GRIDSIZE
	# return -1 if index is out of bounds of array
	var result = x + y*GRIDSIDE
	if (result<0 || result>GRIDSIZE-1 || x<0 || y<0 || x>=GRIDSIDE || y>=GRIDSIDE ):
		result=-1
	return result


func update_grid():
	# Calculates the new grid from the rules as described in Wikipedia (see _about.txt)
	generation += 1 
	get_node("labelGeneration").set_text("Generation: " + str(generation))
	
	var currentcell = 0
	var newgrid = grid
	var dead = 0 # number of dead neighbours
	var alive = 0 # number of alive neighbours
	
	var x = 0
	var y = 0
	
	var cell1 = 0 # 8 neighbour cells
	var cell2 = 0
	var cell3 = 0
	var cell4 = 0
	var cell5 = 0
	var cell6 = 0
	var cell7 = 0
	var cell8 = 0
	
	while y < GRIDSIDE:
		x = 0
		while x < GRIDSIDE:
			alive = 0
			dead = 0
			currentcell = calc_index_from_coord(x, y)
			cell1 = calc_index_from_coord(x-1, y-1)
			cell2 = calc_index_from_coord(x, y-1)
			cell3 = calc_index_from_coord(x+1, y-1)
			cell4 = calc_index_from_coord(x-1, y)
			cell5 = calc_index_from_coord(x+1, y)
			cell6 = calc_index_from_coord(x-1, y+1)
			cell7 = calc_index_from_coord(x, y+1)
			cell8 = calc_index_from_coord(x+1, y+1)
		
			if (cell1 >= 0):
				if (grid[cell1] == LIVECELL):
					alive += 1
				else:
					dead += 1	 
			if (cell2 >= 0):
				if (grid[cell2] == LIVECELL):
					alive += 1
				else:
					dead += 1	 
			if (cell3 >= 0):
				if (grid[cell3] == LIVECELL):
					alive += 1
				else:
					dead += 1	 
			if (cell4 >= 0):
				if (grid[cell4] == LIVECELL):
					alive += 1
				else:
					dead += 1	 
			if (cell5 >= 0):
				if (grid[cell5] == LIVECELL):
					alive += 1
				else:
					dead += 1	 
			if (cell6 >= 0):
				if (grid[cell6] == LIVECELL):
					alive += 1
				else:
					dead += 1	 
			if (cell7 >= 0):
				if (grid[cell7] == LIVECELL):
					alive += 1
				else:
					dead += 1	 
			if (cell8 >= 0):
				if (grid[cell8] == LIVECELL):
					alive += 1
				else:
					dead += 1
			
			if (alive < 2):
				newgrid[currentcell] = DEADCELL
			if (grid[currentcell] == LIVECELL && alive > 3):	
				newgrid[currentcell] = DEADCELL
			if (grid[currentcell] == DEADCELL && alive == 3):
				newgrid[currentcell] = LIVECELL
			
			x += 1
		y += 1
	grid = newgrid
	update()


func reset_grid(clear):
	# clear: true = empty grid, false = random new grid
	var i = 0
	
	generation = 0
	get_node("labelGeneration").set_text("Generation: " + str(generation))
	
	while i < GRIDSIZE:
		grid[i] = DEADCELL
		i += 1
	if (!clear):
		# add some random live cells
		i = 0
		while i < GRIDSIZE / 2:
			grid[calc_index_from_coord(randi() % GRIDSIDE,randi() % GRIDSIDE)] = LIVECELL
			i += 1	
	update()


func set_brush_in_grid(brush, clicked_x, clicked_y):
	# brush >0 <=MAXBRUSH: change the grid with selected brush
	# brush out of bounds: no effect
	# clicked_x, clicked_y: position clicked
	
	if (brush >0 && brush <= MAXBRUSH && transform_clicked_pos_to_index(clicked_x, clicked_y) >= 0):
		if (brush == 1):
			# .X...X.
			# X.XxX.X
			# .X...X. 
			# row 1
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 3*OFFSET, clicked_y - OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 2*OFFSET, clicked_y - OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y - OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x , clicked_y - OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 3*OFFSET, clicked_y - OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 2*OFFSET, clicked_y - OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y - OFFSET),DEADCELL)
			# row 2
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 3*OFFSET, clicked_y),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 2*OFFSET, clicked_y),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x , clicked_y),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 3*OFFSET, clicked_y),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 2*OFFSET, clicked_y),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y),LIVECELL)
			# row 3
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 3*OFFSET, clicked_y + OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 2*OFFSET, clicked_y + OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y + OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x , clicked_y + OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 3*OFFSET, clicked_y + OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 2*OFFSET, clicked_y + OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y + OFFSET),DEADCELL)
		
		if (brush == 2):
			# .XX
			# .x.
			# .X.
			# XX.
			# row 1
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y - OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x, clicked_y - OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y - OFFSET),LIVECELL)
			# row 2
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x, clicked_y),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y),DEADCELL)
			# row 3
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y + OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x, clicked_y + OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y + OFFSET),DEADCELL)
			# row 4
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y + 2*OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x, clicked_y + 2*OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y + 2*OFFSET),DEADCELL)
			
		if (brush == 3):
			# ..X..
			# .XXX.
			# X.X..
			# X.X..
			# .XxX.
			# ..X.X
			# ..X.X
			# .XXX.
			# ..X..
			# row 1
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 2*OFFSET, clicked_y - 4*OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y - 4*OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x, clicked_y - 4*OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y - 4*OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 2*OFFSET, clicked_y - 4*OFFSET),DEADCELL)
			# row 2
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 2*OFFSET, clicked_y - 3*OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y - 3*OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x, clicked_y - 3*OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y - 3*OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 2*OFFSET, clicked_y - 3*OFFSET),DEADCELL)
			# row 3
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 2*OFFSET, clicked_y - 2*OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y - 2*OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x, clicked_y - 2*OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y - 2*OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 2*OFFSET, clicked_y - 2*OFFSET),DEADCELL)
			# row 4
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 2*OFFSET, clicked_y - OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y - OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x, clicked_y - OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y - OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 2*OFFSET, clicked_y - OFFSET),DEADCELL)
			# row 5
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 2*OFFSET, clicked_y),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x, clicked_y),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 2*OFFSET, clicked_y),DEADCELL)
			# row 6
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 2*OFFSET, clicked_y + OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y + OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x, clicked_y + OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y + OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 2*OFFSET, clicked_y + OFFSET),LIVECELL)
			# row 7
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 2*OFFSET, clicked_y + 2*OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y + 2*OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x, clicked_y + 2*OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y + 2*OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 2*OFFSET, clicked_y + 2*OFFSET),LIVECELL)
			# row 8
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 2*OFFSET, clicked_y + 3*OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y + 3*OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x, clicked_y + 3*OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y + 3*OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 2*OFFSET, clicked_y + 3*OFFSET),DEADCELL)
			# row 9
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - 2*OFFSET, clicked_y + 4*OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x - OFFSET, clicked_y + 4*OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x, clicked_y + 4*OFFSET),LIVECELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + OFFSET, clicked_y + 4*OFFSET),DEADCELL)
			set_index_in_grid(transform_clicked_pos_to_index(clicked_x + 2*OFFSET, clicked_y + 4*OFFSET),DEADCELL)
			
	update()


func set_index_in_grid(i, value):
	# helper function to safely set index in array "grid"
	if (i>=0 && i<GRIDSIZE):
		grid[i] = value


func unpress():
	# helper function to unpress all other brushes
	if (activebrush != 1):
		get_node("buttonBrush1").set_pressed(false)
		get_node("buttonBrush1").set_modulate(BRUSHRELEASED)
	if (activebrush != 2):
		get_node("buttonBrush2").set_pressed(false)
		get_node("buttonBrush2").set_modulate(BRUSHRELEASED)
	if (activebrush != 3):
		get_node("buttonBrush3").set_pressed(false)
		get_node("buttonBrush3").set_modulate(BRUSHRELEASED)


### EVENTS ###


func _on_buttonStartStop_pressed():
	running = not running


func _on_buttonQuit_pressed():
	get_tree().quit()


func _on_buttonResetGrid_pressed():
	reset_grid(false)


func _on_buttonStep_pressed():
	update_grid()


func _on_aboutButton_pressed():
	var file = File.new()
	var text = ""
	if(file.open("res://_about.txt", file.READ) == 0):
		text = file.get_as_text()
		file.close()
	else:
		text = "File missing. No text to show :-("
	var textbox = get_node("popupAbout/textPopup")
	textbox.set_readonly(true)
	textbox.set_text(text)
	get_node("popupAbout").show_modal(true)


func _on_closePopup_pressed():
	get_node("popupAbout").hide()


func _on_buttonClearGrid_pressed():
	reset_grid(true)


func _on_buttonBrush1_toggled( pressed ):
	if (pressed):
		activebrush = 1
		get_node("buttonBrush1").set_modulate(BRUSHPRESSED)
		unpress()
	else:
		activebrush = 0
		get_node("buttonBrush1").set_modulate(BRUSHRELEASED)


func _on_buttonBrush2_toggled( pressed ):
	if (pressed):
		activebrush = 2
		get_node("buttonBrush2").set_modulate(BRUSHPRESSED)
		unpress()
	else:
		activebrush = 0
		get_node("buttonBrush2").set_modulate(BRUSHRELEASED)


func _on_buttonBrush3_toggled( pressed ):
	if (pressed):
		activebrush = 3
		get_node("buttonBrush3").set_modulate(BRUSHPRESSED)
		unpress()
	else:
		activebrush = 0
		get_node("buttonBrush3").set_modulate(BRUSHRELEASED)

