class_name MiningBlock
extends Area2D

signal destroyed(block_instance: MiningBlock)

@export var data: BlockData

var grid_position: Vector2i
var current_hp: float

@onready var sprite: ColorRect = $Visual
@onready var hp_bar: ProgressBar = $HPBar
@onready var hp_label: Label = $HPLabel

func setup(pos: Vector2i, block_data: BlockData) -> void:
grid_position = pos
data = block_data
current_hp = data.max_hp

if sprite:
sprite.color = data.color

_update_ui()

func take_damage(amount: float) -> void:
if current_hp <= 0:
return

current_hp = max(0.0, current_hp - amount)
_update_ui()
GameEvents.block_damaged.emit(grid_position, current_hp, data.max_hp)

var tween = create_tween()
tween.tween_property(sprite, "modulate", Color.RED, 0.05)
tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

if current_hp <= 0:
_die()

func _die() -> void:
GameEvents.block_destroyed.emit(grid_position, data)
GameEvents.resource_collected.emit(data.drop_type, data.drop_amount)
destroyed.emit(self)
queue_free()

func _update_ui() -> void:
if hp_bar:
hp_bar.max_value = data.max_hp
hp_bar.value = current_hp
if hp_label:
hp_label.text = str(ceil(current_hp))

func _input_event(_viewport, event, _shape_idx) -> void:
if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
take_damage(25.0)
