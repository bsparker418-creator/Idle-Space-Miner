extends CanvasLayer
## Top-of-screen HUD. Only displays values; GameState owns them.

const SCRAP := "nanite_scrap"

@onready var scrap_label: Label = %ScrapLabel

func _ready() -> void:
	GameState.resource_changed.connect(_on_resource_changed)
	_show_scrap(GameState.get_amount(SCRAP))

func _on_resource_changed(resource_type: String, total: int) -> void:
	if resource_type == SCRAP:
		_show_scrap(total)

func _show_scrap(total: int) -> void:
	scrap_label.text = "Scrap: %d" % total
