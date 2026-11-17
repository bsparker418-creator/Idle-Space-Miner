extends CanvasLayer
## On-screen HUD. Only displays values and forwards button presses;
## GameState owns the actual numbers.

const SCRAP := "nanite_scrap"

@onready var sector_label: Label = %SectorLabel
@onready var scrap_label: Label = %ScrapLabel
@onready var progress_bar: ProgressBar = %SectorProgress
@onready var warp_button: Button = %WarpButton

func _ready() -> void:
	GameState.resource_changed.connect(_on_resource_changed)
	GameState.sector_changed.connect(_on_sector_changed)
	GameEvents.sector_progress.connect(_on_sector_progress)
	GameEvents.sector_cleared.connect(_on_sector_cleared)
	warp_button.pressed.connect(_on_warp_pressed)

	warp_button.hide()
	_show_scrap(GameState.get_amount(SCRAP))
	_on_sector_changed(GameState.sector)

func _on_resource_changed(resource_type: String, total: int) -> void:
	if resource_type == SCRAP:
		_show_scrap(total)

func _show_scrap(total: int) -> void:
	scrap_label.text = "Scrap: %d" % total

func _on_sector_changed(sector: int) -> void:
	sector_label.text = "Sector %d" % sector

func _on_sector_progress(cleared: int, total: int) -> void:
	progress_bar.max_value = total
	progress_bar.value = cleared

func _on_sector_cleared(sector: int) -> void:
	warp_button.text = "Power up warp gate\n+%d scrap  →  Sector %d" % [GameState.clear_bonus(), sector + 1]
	warp_button.show()

func _on_warp_pressed() -> void:
	warp_button.hide()
	GameState.advance_sector()
