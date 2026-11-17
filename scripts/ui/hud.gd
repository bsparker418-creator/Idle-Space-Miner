extends CanvasLayer
## On-screen HUD. Only displays values and forwards button presses;
## GameState and MechManager own the actual numbers.

const SCRAP := "nanite_scrap"
const GATE_LOCKED := Color(0.16, 0.12, 0.26)
const GATE_LOCKED_EDGE := Color(0.71, 0.55, 1.0, 0.5)
const GATE_ONLINE := Color(0.12, 0.35, 0.22)
const GATE_ONLINE_EDGE := Color(0.35, 0.85, 0.55)

@onready var sector_label: Label = %SectorLabel
@onready var scrap_label: Label = %ScrapLabel
@onready var progress_bar: ProgressBar = %SectorProgress
@onready var warp_gate: Button = %WarpGate
@onready var mech_label: Label = %MechLabel
@onready var deploy_button: Button = %DeployButton

var mech_count: int = 0
var mech_max: int = 0

func _ready() -> void:
	GameState.resource_changed.connect(_on_resource_changed)
	GameState.sector_changed.connect(_on_sector_changed)
	GameEvents.sector_progress.connect(_on_sector_progress)
	GameEvents.sector_cleared.connect(_on_sector_cleared)
	GameEvents.mechs_changed.connect(_on_mechs_changed)
	warp_gate.pressed.connect(_on_warp_pressed)
	deploy_button.pressed.connect(func(): GameEvents.deploy_requested.emit())

	_show_scrap(GameState.get_amount(SCRAP))
	_on_sector_changed(GameState.sector)

# ---------- scrap ----------

func _on_resource_changed(resource_type: String, total: int) -> void:
	if resource_type == SCRAP:
		_show_scrap(total)

func _show_scrap(total: int) -> void:
	scrap_label.text = "Scrap: %d" % total
	_refresh_deploy()

# ---------- sector and warp gate ----------

func _on_sector_changed(sector: int) -> void:
	sector_label.text = "Sector %d" % sector
	_set_gate_online(false)

func _on_sector_progress(cleared: int, total: int) -> void:
	progress_bar.max_value = total
	progress_bar.value = cleared

func _on_sector_cleared(_sector: int) -> void:
	_set_gate_online(true)

func _set_gate_online(online: bool) -> void:
	warp_gate.disabled = not online
	if online:
		warp_gate.text = "WARP GATE ONLINE\nTap to jump to Sector %d  (+%d scrap)" % [GameState.sector + 1, GameState.clear_bonus()]
	else:
		warp_gate.text = "WARP GATE OFFLINE\nClear every block to power it up"
	var fill := GATE_ONLINE if online else GATE_LOCKED
	var edge := GATE_ONLINE_EDGE if online else GATE_LOCKED_EDGE
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var box := StyleBoxFlat.new()
		box.bg_color = fill.lightened(0.1) if state == "hover" else fill
		box.border_color = edge
		box.set_border_width_all(3)
		box.set_corner_radius_all(10)
		if state == "focus":
			box.draw_center = false
		warp_gate.add_theme_stylebox_override(state, box)

func _on_warp_pressed() -> void:
	_set_gate_online(false)
	GameState.advance_sector()

# ---------- mechs ----------

func _on_mechs_changed(count: int, max_count: int, total_dps: float) -> void:
	mech_count = count
	mech_max = max_count
	mech_label.text = "Mechs %d/%d   ·   %.1f DPS" % [count, max_count, total_dps]
	_refresh_deploy()

func _refresh_deploy() -> void:
	if not is_node_ready():
		return
	var cost := GameState.deploy_cost()
	if mech_max > 0 and mech_count >= mech_max:
		deploy_button.text = "Launch pad full\nMerge mechs to free a slot"
		deploy_button.disabled = true
	else:
		deploy_button.text = "Deploy mech\n%d scrap" % cost
		deploy_button.disabled = GameState.get_amount(SCRAP) < cost
