class_name Mech
extends Node2D
## One mining mech. Drawn in code (placeholder art) and centred on its cell.
## MechManager owns where it is, when it fires and how it merges.

var tier: int = 1:
	set(value):
		tier = value
		queue_redraw()
var cell: Vector2i
## Seconds until the next shot.
var cooldown: float = 1.0

func tier_color() -> Color:
	# Each tier gets its own hue so merged mechs are easy to tell apart.
	return Color.from_hsv(fmod(0.52 + (tier - 1) * 0.13, 1.0), 0.6, 0.95)

func _draw() -> void:
	var c := tier_color()
	# Legs
	draw_rect(Rect2(-14, 8, 10, 20), c.darkened(0.5))
	draw_rect(Rect2(4, 8, 10, 20), c.darkened(0.5))
	# Arms
	draw_rect(Rect2(-28, -10, 8, 18), c.darkened(0.35))
	draw_rect(Rect2(20, -10, 8, 18), c.darkened(0.35))
	# Body
	draw_rect(Rect2(-20, -12, 40, 24), c.darkened(0.2))
	# Head and visor
	draw_rect(Rect2(-11, -28, 22, 16), c)
	draw_rect(Rect2(-7, -23, 14, 5), Color(0.37, 0.88, 1.0))
	# Tier tag
	draw_string(ThemeDB.fallback_font, Vector2(16, 31), "T%d" % tier,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
