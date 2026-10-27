class_name BlockData
extends Resource

enum BlockType {
ASTEROID_CRUST,
TITANIUM_BULKHEAD,
UNSTABLE_CORE,
DATA_VAULT
}

@export var block_type: BlockType = BlockType.ASTEROID_CRUST
@export var title: String = "Asteroid Crust"
@export var max_hp: float = 100.0
@export var color: Color = Color(0.4, 0.4, 0.45)

@export var drop_type: String = "nanite_scrap"
@export var drop_amount: int = 25

@export var is_explosive: bool = false
@export var explosion_damage: float = 80.0
@export var explosion_radius: int = 1
