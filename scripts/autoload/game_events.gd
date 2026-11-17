extends Node

signal block_damaged(grid_pos: Vector2i, current_hp: float, max_hp: float)
signal block_destroyed(grid_pos: Vector2i, block_data: Resource)
signal resource_collected(resource_type: String, amount: int)

## Fired whenever the number of cleared blocks in the current sector changes.
signal sector_progress(cleared: int, total: int)
## Fired once when the last block in the sector is destroyed.
signal sector_cleared(sector: int)
