extends TileMapLayer

# Path to the Light2D scene
const LIGHT_SCENE_PATH = "res://level_test/point_light_2d.tscn"

# Tile ID that should have a light attached
const LIGHT_TILE_ID = 1

func _ready():
	# Load the Light2D scene
	const LIGHT_SCENE = preload(LIGHT_SCENE_PATH)
	
	# Get the used cells in the TileMap
	var used_cells = get_used_cells()
	
	for cell in used_cells:
		var tile_id = get_cell_source_id(cell)
		
		# Check if the tile ID matches the specified tile ID
		if tile_id == LIGHT_TILE_ID:
			# Instance the Light2D scene
			var light_instance = LIGHT_SCENE.instantiate()
			
			# Calculate the position for the Light2D
			var cell_world_position = map_to_local(cell)
			
			# Set the position of the Light2D
			light_instance.position = cell_world_position
			
			# Add the Light2D as a child of the TileMap
			add_child(light_instance)
