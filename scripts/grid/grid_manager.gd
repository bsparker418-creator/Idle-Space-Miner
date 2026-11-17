class_name GridManager
extends Node2D

@export var grid_width: int = 7
@export var grid_height: int = 9
@export var tile_size: int = 68
@export var block_scene: PackedScene
## Block types that can spawn. Edit their stats in data/blocks/*.tres.
@export var block_types: Array[BlockData] = [
	preload("res://data/blocks/asteroid_crust.tres"),
	preload("res://data/blocks/titanium_bulkhead.tres"),
	preload("res://data/blocks/unstable_core.tres"),
]

var blocks: Dictionary = {}

func _ready() -> void:
	generate_sector()

func generate_sector() -> void:
	for child in get_children():
		child.queue_free()
	blocks.clear()

	for y in range(grid_height):
		for x in range(grid_width):
			var pos = Vector2i(x, y)
			spawn_block(pos, _get_random_block_data())

func spawn_block(pos: Vector2i, data: BlockData) -> void:
	var block: MiningBlock = block_scene.instantiate()
	block.position = Vector2(pos.x * tile_size, pos.y * tile_size)
	add_child(block)

	block.setup(pos, data)
	block.destroyed.connect(_on_block_destroyed)
	blocks[pos] = block

func _on_block_destroyed(block: MiningBlock) -> void:
	var dead_pos = block.grid_position
	var dead_data = block.data
	blocks.erase(dead_pos)

	if dead_data.is_explosive:
		_trigger_explosion(dead_pos, dead_data.explosion_damage, dead_data.explosion_radius)

func _trigger_explosion(center: Vector2i, damage: float, radius: int) -> void:
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			if dx == 0 and dy == 0:
				continue
			var target_pos = center + Vector2i(dx, dy)
			if blocks.has(target_pos):
				get_tree().create_timer(0.08).timeout.connect(func():
					if blocks.has(target_pos):
						blocks[target_pos].take_damage(damage)
				)

## Picks a block type at random, weighted by each type's spawn_weight.
## The resources are shared, read-only templates: each block keeps its own HP.
func _get_random_block_data() -> BlockData:
	var total := 0.0
	for t in block_types:
		total += t.spawn_weight

	var roll := randf() * total
	for t in block_types:
		roll -= t.spawn_weight
		if roll < 0.0:
			return t
	return block_types.back()
