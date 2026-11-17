extends Node
## Single source of truth for the player's progress (currencies, sector, etc.).
## Other scripts read from here and listen to `resource_changed` instead of
## keeping their own copies. Later this is what gets saved to disk.

signal resource_changed(resource_type: String, total: int)
signal sector_changed(sector: int)

## Each sector multiplies block HP by this (1.25 = +25% per sector).
const HP_GROWTH := 1.25
## Each sector multiplies scrap drops and the clear bonus by this.
const REWARD_GROWTH := 1.2
## Scrap paid out for powering up the warp gate in sector 1.
const CLEAR_BONUS := 200

## Currency totals, keyed by type, e.g. {"nanite_scrap": 125}.
var resources: Dictionary = {}

var sector: int = 1

## Damage per tap. Kept here so upgrades can raise it later.
var tap_damage: float = 25.0

func hp_multiplier() -> float:
	return pow(HP_GROWTH, sector - 1)

func reward_multiplier() -> float:
	return pow(REWARD_GROWTH, sector - 1)

func clear_bonus() -> int:
	return int(round(CLEAR_BONUS * reward_multiplier()))

## Pays the clear bonus for the current sector and moves to the next one.
func advance_sector() -> void:
	add_resource("nanite_scrap", clear_bonus())
	sector += 1
	sector_changed.emit(sector)

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
