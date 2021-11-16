extends Node2D

onready var nav
onready var grid 

var path 
var goal 
var goal_tile 
var speed = 500

func _ready():
	grid = get_node("navigation/grid")
	nav = get_node("navigation")
	
	$Sprite.position = grid.map_to_world(Vector2(0,0))
	$Sprite.position.x += grid.cell_size.y / sqrt(3)
	$Sprite.position.y += grid.cell_size.x / sqrt(3)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			goal = grid.map_to_world(goal_tile) 
			goal.x += grid.cell_size.y / sqrt(3)
			goal.y += grid.cell_size.x / sqrt(3)
			path = nav.get_simple_path($Sprite.position, goal, false)
			$Line2D.points = PoolVector2Array(path)
			$Line2D.show()
			
func _process(delta):
	if !path:
		$Line2D.hide()
		return
	if path.size() > 0:
		var d: float = $Sprite.position.distance_to(path[0])
		if d > 10:
			$Sprite.position = $Sprite.position.linear_interpolate(path[0], (speed * delta)/d)
		else:
			$Sprite.position = path[0]
			path.remove(0)
