extends Node2D

var grid = IntArray([0]) # game grid
var running = false # is the simulation running
var waiting = 0
var generation = 0

const LOOPDELAY = 0.5  # seconds
const GRIDSIDE = 42 # columns and rows in grid
const GRIDSIZE = GRIDSIDE*GRIDSIDE 
const DEADCELL = 0
const LIVECELL = 1
const CELLSIZE = 12 # pixels width + height
const CELLSPACING = 2 # pixels all around
const GRIDOFFSET = Vector2(380,30)
const DEADCOLOR = Color(0.4, 0.4, 0.6) 
const LIVECOLOR = Color(1, 1, 1)


func _ready():
	set_process(true)
	grid.resize(GRIDSIZE)	
	reset_grid()
	
func _process(delta):
	if (running):
		waiting += delta
		if (waiting >= LOOPDELAY):
			waiting = 0
			update_grid()
			
func _draw():
	var i = GRIDSIZE
	var s = GRIDSIDE
	var x = 0
	var y = 0
	var newcell = Rect2(0, 0, 0, 0)
	var c = DEADCOLOR

	while i > 0:
		i -= 1
		x = floor(i / s)
		y = fmod(i, s)
		#print("x,y,i %s %s %s" % [x,y,i])
		newcell = Rect2(GRIDOFFSET.x + x * (CELLSIZE + CELLSPACING), GRIDOFFSET.y + y * (CELLSIZE + CELLSPACING), CELLSIZE, CELLSIZE)
		if (grid[i] == DEADCELL):
			c = DEADCOLOR
		else:
			c = LIVECOLOR
			
		draw_rect(newcell, c)
		
########################################

func calc_index_from_coord(x, y):
	# x and y >=0   <GRIDSIDE
	# return index in array >=0 <GRIDSIZE
	# return -1 if index is out of bounds of array
	var result = x + y*GRIDSIDE
	if (result<0 || result>GRIDSIZE-1 || x<0 || y<0 || x>=GRIDSIDE || y>=GRIDSIDE ):
		result=-1
	return result
			
			
func update_grid():
	generation += 1 
	get_node("labelGeneration").set_text("Generation: " + str(generation))
	
	var currentcell = 0
	var newgrid = grid
	var dead = 0
	var alive = 0
	
	var x = 0
	var y = 0
	
	var cell1 = 0
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
	
func reset_grid():
	var i = 0
	
	generation = 0
	get_node("labelGeneration").set_text("Generation: " + str(generation))	
	while i < GRIDSIZE:
		grid[i] = DEADCELL
		i += 1
	
	i = 0
	while i < GRIDSIZE / 2:
		grid[calc_index_from_coord(randi() % GRIDSIDE,randi() % GRIDSIDE)] = LIVECELL
		i += 1	
	

func _on_Button_pressed():
	running = not running
	
func _on_buttonQuit_pressed():
	get_tree().quit()

func _on_buttonResetGrid_pressed():
	reset_grid()
	update()

func _on_buttonStep_pressed():
	update_grid()
	


func _on_aboutButton_pressed():
	pass # replace with function body
