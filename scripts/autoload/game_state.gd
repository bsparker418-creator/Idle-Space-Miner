extends Node
## Single source of truth for the player's progress (currencies, sector, etc.).
## Other scripts read from here and listen to `resource_changed` instead of
## keeping their own copies. Later this is what gets saved to disk.

signal resource_changed(resource_type: String, total: int)

## Currency totals, keyed by type, e.g. {"nanite_scrap": 125}.
var resources: Dictionary = {}

var sector: int = 1

func _ready() -> void:
	GameEvents.resource_collected.connect(add_resource)

func get_amount(resource_type: String) -> int:
	return resources.get(resource_type, 0)

func add_resource(resource_type: String, amount: int) -> void:
	resources[resource_type] = get_amount(resource_type) + amount
	resource_changed.emit(resource_type, resources[resource_type])

## Returns false (and spends nothing) if the player can't afford it.
func spend(resource_type: String, amount: int) -> bool:
	if get_amount(resource_type) < amount:
		return false
	resources[resource_type] = get_amount(resource_type) - amount
	resource_changed.emit(resource_type, resources[resource_type])
	return true
