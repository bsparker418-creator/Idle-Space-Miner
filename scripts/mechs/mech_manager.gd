class_name MechManager
extends Node2D
## Owns every mech: the launch pad, deploying, firing, dragging and merging.
##
## It shares the grid's coordinate system (same position as GridManager).
## Grid rows are 0..grid_height-1 (top to bottom); the launch pad is the extra
## row y = grid_height just under the grid. A mech may stand on any pad cell
## or any grid cell whose block has been cleared.

const SCRAP := "nanite_scrap"
const ATTACK_INTERVAL := 1.0
## Which neighbour a mech shoots first. UP first, so mechs push toward the gate.
const TARGET_ORDER: Array[Vector2i] = [Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
const PAD_FILL := Color(0.12, 0.15, 0.26)
const PAD_EDGE := Color(0.37, 0.88, 1.0, 0.35)
const LASER_COLOR := Color(0.37, 0.88, 1.0)

@export var grid: GridManager
## Free T1 mechs at the start of a new game.
@export var starting_mechs: int = 1

var mechs: Dictionary = {}  # Vector2i -> Mech
var dragging: Mech = null
var drag_from: Vector2i

func _ready() -> void:
	GameEvents.deploy_requested.connect(deploy)
	GameState.sector_changed.connect(func(_sector): _return_all_to_pad())
	for i in starting_mechs:
		_add_mech(_free_pad_cell(), 1)
	queue_redraw()
	call_deferred("_emit_changed")

# ---------- layout helpers ----------

func _tile() -> int:
	return grid.tile_size

func pad_row() -> int:
	return grid.grid_height

## The pad has one slot per column, which is also the mech limit.
func max_mechs() -> int:
	return grid.grid_width

func is_free(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.x >= grid.grid_width:
		return false
	if cell.y == pad_row():
		return true
	return cell.y >= 0 and cell.y < grid.grid_height and not grid.blocks.has(cell)

func _cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell * _tile()) + Vector2(_tile(), _tile()) / 2.0

func _cell_at(local_pos: Vector2) -> Vector2i:
	return Vector2i(floori(local_pos.x / _tile()), floori(local_pos.y / _tile()))

func _free_pad_cell() -> Vector2i:
	for x in grid.grid_width:
		var c := Vector2i(x, pad_row())
		if not mechs.has(c):
			return c
	return Vector2i(-1, -1)

# ---------- deploying ----------

func can_deploy() -> bool:
	return mechs.size() < max_mechs()

func deploy() -> void:
	if not can_deploy():
		return
	if not GameState.spend(SCRAP, GameState.deploy_cost()):
		return
	GameState.mechs_bought += 1
	_add_mech(_free_pad_cell(), 1)
	_emit_changed()

func _add_mech(cell: Vector2i, tier: int) -> Mech:
	var m := Mech.new()
	m.tier = tier
	# Random first shot so mechs don't all fire on the same frame.
	m.cooldown = randf_range(0.2, ATTACK_INTERVAL)
	add_child(m)
	_place(m, cell)
	return m

func _place(m: Mech, cell: Vector2i) -> void:
	mechs[cell] = m
	m.cell = cell
	m.position = _cell_center(cell)

## New sector: blocks refill the grid, so every mech goes back to the pad,
## highest tier on the left.
func _return_all_to_pad() -> void:
	if dragging:
		dragging.z_index = 0
		dragging = null
	var list: Array = mechs.values()
	list.sort_custom(func(a, b): return a.tier > b.tier)
	mechs.clear()
	for i in list.size():
		_place(list[i], Vector2i(i, pad_row()))
	_emit_changed()

func _emit_changed() -> void:
	var dps := 0.0
	for m in mechs.values():
		dps += GameState.mech_damage(m.tier) / ATTACK_INTERVAL
	GameEvents.mechs_changed.emit(mechs.size(), max_mechs(), dps)

# ---------- firing ----------

func _process(delta: float) -> void:
	for m in mechs.values():
		if m == dragging:
			continue
		m.cooldown -= delta
		if m.cooldown <= 0.0:
			# If nothing is in range, stay ready and fire as soon as something is.
			m.cooldown = ATTACK_INTERVAL if _fire(m) else 0.0

func _find_target(cell: Vector2i) -> MiningBlock:
	for dir in TARGET_ORDER:
		var c := cell + dir
		if grid.blocks.has(c):
			return grid.blocks[c]
	return null

func _fire(m: Mech) -> bool:
	var target := _find_target(m.cell)
	if target == null:
		return false
	_show_laser(_cell_center(m.cell), _cell_center(target.grid_position))
	target.take_damage(GameState.mech_damage(m.tier))
	return true

func _show_laser(from: Vector2, to: Vector2) -> void:
	var line := Line2D.new()
	line.points = PackedVector2Array([from, to])
	line.width = 4.0
	line.default_color = LASER_COLOR
	add_child(line)
	var tw := line.create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 0.15)
	tw.tween_callback(line.queue_free)

# ---------- drag, move, merge ----------

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos: Vector2 = make_input_local(event).position
		var cell := _cell_at(local_pos)
		if event.pressed and dragging == null and mechs.has(cell):
			dragging = mechs[cell]
			drag_from = cell
			dragging.z_index = 10
			get_viewport().set_input_as_handled()
		elif not event.pressed and dragging:
			_drop(cell)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and dragging:
		dragging.position = make_input_local(event).position

## Drop rules: same cell or a blocked cell -> snap back. Empty free cell -> move.
## Mech of the same tier -> merge into one mech of the next tier.
## Mech of a different tier -> swap places.
func _drop(cell: Vector2i) -> void:
	var m := dragging
	dragging = null
	m.z_index = 0
	mechs.erase(drag_from)

	if cell == drag_from or not is_free(cell):
		_place(m, drag_from)
		return

	if mechs.has(cell):
		var other: Mech = mechs[cell]
		if other.tier == m.tier:
			other.tier += 1
			m.queue_free()
			_merge_pop(other)
		else:
			_place(other, drag_from)
			_place(m, cell)
	else:
		_place(m, cell)
	_emit_changed()

func _merge_pop(m: Mech) -> void:
	m.scale = Vector2(1.4, 1.4)
	var tw := m.create_tween()
	tw.tween_property(m, "scale", Vector2.ONE, 0.2)

# ---------- launch pad visuals ----------

func _draw() -> void:
	for x in grid.grid_width:
		var r := Rect2(x * _tile() + 2, pad_row() * _tile() + 4, _tile() - 4, _tile() - 4)
		draw_rect(r, PAD_FILL)
		draw_rect(r, PAD_EDGE, false, 2.0)
