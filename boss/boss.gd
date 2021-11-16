extends Node2D


var original_piece = preload("res://boss/boss_piece.tscn")
var grid


var neighbour_shifts = [
		[
			Vector2(0,-1),
			Vector2(1,0),
			Vector2(0,1),
			Vector2(-1,1),
			Vector2(-1,0),
			Vector2(-1,-1)
		],
		[
			Vector2(1,-1),
			Vector2(1,0),
			Vector2(1,1),
			Vector2(0,1),
			Vector2(-1,0),
			Vector2(0,-1)
		]
	]
var pieces
var slabs

var rng = RandomNumberGenerator.new()

func _init_pieces():
	slabs = []
	var piece_shifts = [null,0,2,1]
	var contacts = [7,12,33,56]
	var anchor = Vector2(3,2)
	var y = grid.cell_size.y
	var x = grid.cell_size.x
	
	for _i in piece_shifts.size():
		var piece = original_piece.instance()
		var shift = anchor
		
		if piece_shifts[_i] != null:
			var parity = int(anchor.y) % 2
			shift += neighbour_shifts[parity][piece_shifts[_i]] 
			
		var vec = grid.map_to_world(shift) 
		vec.x += y / sqrt(3)
		vec.y += x / sqrt(3)
		piece.position = vec
		piece.frame = _i
		piece._set_tile(shift)
		var value = grid.tile_set.find_tile_by_name("grass_fill")
		grid.set_cellv(shift, value)
		
		var gates = _to_binary(contacts[_i])
		
		for _j in gates.size():
			if gates[_j] ==  0:
				piece.get_node(str(_j)).visible = true
				piece.get_node(str(_j)).frame = 1
				var slab = {
					"parent": piece,
					"side": _j,
					"def_frame": 1
				}
				
				slabs.append(slab)
				
		$pieces.add_child(piece)
	
	rng.randomize()
	var index = floor(rng.randf_range(0, slabs.size()))
	slabs[index]["def_frame"] = 0
	slabs[index]["parent"].get_node(str(slabs[index]["side"])).frame = slabs[index]["def_frame"]
	_find_weak_spot(index)

func _to_binary(_value):
	var n = 6;
	var array = []
	var temp = _value
	
	for _i in n:
		array.append(int(temp) % 2)
		temp = floor(temp/2)
		
	return array

func _find_weak_spot(_index):
	var tile = slabs[_index]["parent"].tile
	#var mirrored_side = abs(3 - slabs[_index]["side"])
	var parity = int(tile.y) % 2
	var result = tile + neighbour_shifts[parity][slabs[_index]["side"]] 
	get_parent().goal_tile = result

func _ready():
	grid = get_parent().get_node("navigation/grid")
	
	_init_pieces()
