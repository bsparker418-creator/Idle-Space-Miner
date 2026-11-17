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

const NEIGHBORS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

## Living blocks, keyed by grid position. A missing key means that cell is cleared.
var blocks: Dictionary = {}
var total_blocks: int = 0

func _ready() -> void:
	GameState.sector_changed.connect(func(_sector): generate_sector())
	generate_sector()

func generate_sector() -> void:
	for child in get_children():
		child.queue_free()
	blocks.clear()

	var hp_mult := GameState.hp_multiplier()
	var drop_mult := GameState.reward_multiplier()
	for y in range(grid_height):
		for x in range(grid_width):
			var pos = Vector2i(x, y)
			spawn_block(pos, _get_random_block_data(), hp_mult, drop_mult)

	total_blocks = blocks.size()
	for pos in blocks:
		_refresh_exposure(pos)
	# Deferred so the HUD (which may be ready after us) receives the first update.
	call_deferred("_emit_progress")

func spawn_block(pos: Vector2i, data: BlockData, hp_mult: float = 1.0, drop_mult: float = 1.0) -> void:
	var block: MiningBlock = block_scene.instantiate()
	block.position = Vector2(pos.x * tile_size, pos.y * tile_size)
	add_child(block)

	block.setup(pos, data, hp_mult, drop_mult)
	block.destroyed.connect(_on_block_destroyed)
	blocks[pos] = block

## Mining rule: you dig upward from the launch pad. A block can be tapped if
## it is in the bottom row, or if any cell directly above, below, left or
## right of it has been cleared.
func is_exposed(pos: Vector2i) -> bool:
	if pos.y == grid_height - 1:
		return true
	for dir in NEIGHBORS:
		var n = pos + dir
		if _in_bounds(n) and not blocks.has(n):
			return true
	return false

func _refresh_exposure(pos: Vector2i) -> void:
	if blocks.has(pos):
		blocks[pos].set_exposed(is_exposed(pos))

func _in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height

func _emit_progress() -> void:
	GameEvents.sector_progress.emit(total_blocks - blocks.size(), total_blocks)

func _on_block_destroyed(block: MiningBlock) -> void:
	var dead_pos = block.grid_position
	var dead_data = block.data
	blocks.erase(dead_pos)

	for dir in NEIGHBORS:
		_refresh_exposure(dead_pos + dir)
	_emit_progress()

	if dead_data.is_explosive:
		var damage = dead_data.explosion_damage * GameState.hp_multiplier()
		_trigger_explosion(dead_pos, damage, dead_data.explosion_radius)

	if blocks.is_empty():
		GameEvents.sector_cleared.emit(GameState.sector)

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
