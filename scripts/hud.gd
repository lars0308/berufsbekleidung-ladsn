extends Control
## Sparsames HUD für eine Bildschirmhälfte: Name, Lebenspunkte und Spezialanzeige.

var player: Node
var _hp: ProgressBar
var _sp: ProgressBar
var _sp_fill: StyleBoxFlat


func _bar(w: float, h: float, col: Color) -> ProgressBar:
	var b := ProgressBar.new()
	b.custom_minimum_size = Vector2(w, h)
	b.show_percentage = false
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.5)
	bg.set_corner_radius_all(6)
	var fill := StyleBoxFlat.new()
	fill.bg_color = col
	fill.set_corner_radius_all(6)
	b.add_theme_stylebox_override("background", bg)
	b.add_theme_stylebox_override("fill", fill)
	return b


func setup(p: Node, title: String, color: Color) -> void:
	player = p
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := VBoxContainer.new()
	box.position = Vector2(20, 14)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 8)
	box.add_child(label)
	_hp = _bar(240, 20, Color("ff6b8a"))
	_hp.max_value = p.MAX_HP
	box.add_child(_hp)
	_sp = _bar(240, 10, color)
	_sp.max_value = 1.0
	box.add_child(_sp)


func _process(_delta: float) -> void:
	if player == null:
		return
	_hp.value = player.hp
	_sp.value = player.special_ratio()
