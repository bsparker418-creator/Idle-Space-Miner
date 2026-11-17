class_name MiningBlock
extends Area2D

signal destroyed(block_instance: MiningBlock)

## How a buried (not exposed) block is tinted.
const BURIED_TINT := Color(0.4, 0.4, 0.45)

## Shared, read-only template for this block type. Per-block values
## (HP, drop) are copied out in setup() so sector scaling never edits it.
@export var data: BlockData

var grid_position: Vector2i
var max_hp: float
var current_hp: float
var drop_amount: int
## Only exposed blocks can be tapped. Explosions hit buried blocks too.
var exposed: bool = true

@onready var sprite: ColorRect = $Visual
@onready var hp_bar: ProgressBar = $HPBar
@onready var hp_label: Label = $HPLabel

func setup(pos: Vector2i, block_data: BlockData, hp_mult: float = 1.0, drop_mult: float = 1.0) -> void:
	grid_position = pos
	data = block_data
	max_hp = data.max_hp * hp_mult
	current_hp = max_hp
	drop_amount = int(round(data.drop_amount * drop_mult))

	if sprite:
		sprite.color = data.color

	_update_ui()

func set_exposed(value: bool) -> void:
	exposed = value
	modulate = Color.WHITE if value else BURIED_TINT

func take_damage(amount: float) -> void:
	if current_hp <= 0:
		return

	current_hp = max(0.0, current_hp - amount)
	_update_ui()
	GameEvents.block_damaged.emit(grid_position, current_hp, max_hp)

	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	if current_hp <= 0:
		_die()

func _die() -> void:
	GameEvents.block_destroyed.emit(grid_position, data)
	GameEvents.resource_collected.emit(data.drop_type, drop_amount)
	destroyed.emit(self)
	queue_free()

func _update_ui() -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
	if hp_label:
		hp_label.text = str(int(ceil(current_hp)))

func _input_event(_viewport, event, _shape_idx) -> void:
	if not exposed:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		take_damage(GameState.tap_damage)
