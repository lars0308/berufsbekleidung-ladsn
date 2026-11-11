extends Node2D
## Spielfeld: Raster-Logik, Bewegung und Zeichnen beider Figuren.
##
## Fuchs (Spieler 0) passt durch schmale Spalte, kann aber nichts schieben.
## Bär (Spieler 1) schiebt Kisten, passt aber nicht durch Spalte.

signal solved

const CELL := 64
const FOX := 0
const BEAR := 1
const MOVE_COOLDOWN := 0.16
const BLOCKED_COOLDOWN := 0.1
const SLIDE_SPEED := CELL * 10.0
## Welche Platte öffnet welche Tür
const DOOR_FOR_PLATE := {"P": "D", "Q": "E"}
const GROUP_COLOR := {
	"P": Color("4aa3ff"), "D": Color("4aa3ff"),
	"Q": Color("c77dff"), "E": Color("c77dff"),
}
const FOX_COLOR := Color("ff9b3d")
const BEAR_COLOR := Color("a9744f")
const FLOOR_A := Color("2b3350")
const FLOOR_B := Color("272e49")
const WALL := Color("12151f")
const WALL_TOP := Color("1c2132")
const BOX_COLOR := Color("c99a5b")

var grid: Array[String] = []
var width := 0
var height := 0
var boxes: Array[Vector2i] = []
var box_visual: Array[Vector2] = []
var players: Array[Vector2i] = [Vector2i.ZERO, Vector2i.ZERO]
var visual: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]
var cooldown: Array[float] = [0.0, 0.0]
var moves := 0
var done := false


func load_level(rows: Array) -> void:
	grid.clear()
	boxes.clear()
	box_visual.clear()
	height = rows.size()
	width = 0
	for row in rows:
		width = maxi(width, String(row).length())
	for y in height:
		var line := String(rows[y]).rpad(width, "#")
		var out := ""
		for x in width:
			var c := line[x]
			match c:
				"1":
					players[FOX] = Vector2i(x, y)
					c = "."
				"2":
					players[BEAR] = Vector2i(x, y)
					c = "."
				"B":
					boxes.append(Vector2i(x, y))
					c = "."
				" ":
					c = "#"
			out += c
		grid.append(out)
	for who in 2:
		visual[who] = Vector2(players[who] * CELL)
		cooldown[who] = 0.0
	for b in boxes:
		box_visual.append(Vector2(b * CELL))
	moves = 0
	done = false
	queue_redraw()


func tile(cell: Vector2i) -> String:
	if cell.x < 0 or cell.y < 0 or cell.x >= width or cell.y >= height:
		return "#"
	return grid[cell.y][cell.x]


func is_occupied(cell: Vector2i) -> bool:
	return boxes.has(cell) or players.has(cell)


func is_door_open(door: String) -> bool:
	var has_plate := false
	for y in height:
		for x in width:
			if DOOR_FOR_PLATE.get(grid[y][x], "") == door:
				has_plate = true
				if not is_occupied(Vector2i(x, y)):
					return false
	return has_plate


func _terrain_blocks(cell: Vector2i, who: int, is_box: bool) -> bool:
	var t := tile(cell)
	if t == "#":
		return true
	if t == "~":
		return is_box or who == BEAR
	if t == "D" or t == "E":
		return not is_door_open(t)
	return false


func try_move(who: int, dir: Vector2i) -> bool:
	if done:
		return false
	var target := players[who] + dir
	if _terrain_blocks(target, who, false):
		return false
	if target == players[1 - who]:
		return false
	var bi := boxes.find(target)
	if bi != -1:
		if who != BEAR:
			return false
		var beyond := target + dir
		if _terrain_blocks(beyond, who, true) or boxes.has(beyond) or beyond == players[1 - who]:
			return false
		boxes[bi] = beyond
	players[who] = target
	moves += 1
	_check_win()
	return true


func _check_win() -> void:
	if tile(players[FOX]) == "a" and tile(players[BEAR]) == "b":
		done = true
		solved.emit()


func _read_dir(who: int) -> Vector2i:
	var p := "p%d_" % who
	if Input.is_action_pressed(p + "up"):
		return Vector2i.UP
	if Input.is_action_pressed(p + "down"):
		return Vector2i.DOWN
	if Input.is_action_pressed(p + "left"):
		return Vector2i.LEFT
	if Input.is_action_pressed(p + "right"):
		return Vector2i.RIGHT
	return Vector2i.ZERO


func _process(delta: float) -> void:
	for who in 2:
		cooldown[who] -= delta
		var dir := _read_dir(who)
		if dir != Vector2i.ZERO and cooldown[who] <= 0.0:
			cooldown[who] = MOVE_COOLDOWN if try_move(who, dir) else BLOCKED_COOLDOWN
		visual[who] = visual[who].move_toward(Vector2(players[who] * CELL), SLIDE_SPEED * delta)
	for i in boxes.size():
		box_visual[i] = box_visual[i].move_toward(Vector2(boxes[i] * CELL), SLIDE_SPEED * delta)
	queue_redraw()


# ---------------------------------------------------------------- Zeichnen

func _draw() -> void:
	var font := ThemeDB.fallback_font
	for y in height:
		for x in width:
			var cell := Vector2i(x, y)
			var rect := Rect2(Vector2(cell * CELL), Vector2(CELL, CELL))
			var t := grid[y][x]
			if t == "#":
				draw_rect(rect, WALL)
				draw_rect(rect.grow(-4), WALL_TOP)
				continue
			draw_rect(rect, FLOOR_A if (x + y) % 2 == 0 else FLOOR_B)
			match t:
				"~":
					draw_rect(rect.grow(-14), Color(0, 0, 0, 0.45))
					draw_string(font, rect.position + Vector2(0, 40), "~", HORIZONTAL_ALIGNMENT_CENTER, CELL, 28, Color(1, 1, 1, 0.35))
				"P", "Q":
					var col: Color = GROUP_COLOR[t]
					var pressed := is_occupied(cell)
					draw_rect(rect.grow(-12), Color(col, 0.9 if pressed else 0.3))
					draw_rect(rect.grow(-12), col, false, 3.0)
				"D", "E":
					var col2: Color = GROUP_COLOR[t]
					if is_door_open(t):
						draw_rect(rect.grow(-3), col2, false, 3.0)
					else:
						draw_rect(rect.grow(-3), Color(col2, 0.85))
						draw_line(rect.position + Vector2(8, 8), rect.end - Vector2(8, 8), Color(0, 0, 0, 0.35), 3.0)
						draw_line(rect.position + Vector2(CELL - 8, 8), rect.position + Vector2(8, CELL - 8), Color(0, 0, 0, 0.35), 3.0)
				"a", "b":
					var gc := FOX_COLOR if t == "a" else BEAR_COLOR
					draw_rect(rect.grow(-6), Color(gc, 0.25))
					draw_rect(rect.grow(-6), gc, false, 4.0)
					draw_string(font, rect.position + Vector2(0, 42), "F" if t == "a" else "B", HORIZONTAL_ALIGNMENT_CENTER, CELL, 30, Color(gc, 0.8))
	for pos in box_visual:
		var r := Rect2(pos + Vector2(6, 6), Vector2(CELL - 12, CELL - 12))
		draw_rect(r, BOX_COLOR)
		draw_rect(r, BOX_COLOR.darkened(0.45), false, 3.0)
		draw_line(r.position, r.end, BOX_COLOR.darkened(0.45), 3.0)
		draw_line(Vector2(r.end.x, r.position.y), Vector2(r.position.x, r.end.y), BOX_COLOR.darkened(0.45), 3.0)
	_draw_fox(visual[FOX])
	_draw_bear(visual[BEAR])


func _draw_eyes(c: Vector2, spread: float) -> void:
	for sx in [-spread, spread]:
		draw_circle(c + Vector2(sx, -4), 5.0, Color.WHITE)
		draw_circle(c + Vector2(sx, -3), 2.5, Color("1a1a1a"))


func _draw_fox(pos: Vector2) -> void:
	var c := pos + Vector2(CELL, CELL) / 2.0
	draw_colored_polygon(PackedVector2Array([c + Vector2(-22, -14), c + Vector2(-20, -30), c + Vector2(-6, -20)]), FOX_COLOR)
	draw_colored_polygon(PackedVector2Array([c + Vector2(22, -14), c + Vector2(20, -30), c + Vector2(6, -20)]), FOX_COLOR)
	draw_rect(Rect2(c - Vector2(22, 22), Vector2(44, 44)), FOX_COLOR)
	draw_rect(Rect2(c + Vector2(-12, 4), Vector2(24, 18)), Color("ffe3c4"))
	draw_circle(c + Vector2(0, 8), 3.5, Color("1a1a1a"))
	_draw_eyes(c, 10.0)


func _draw_bear(pos: Vector2) -> void:
	var c := pos + Vector2(CELL, CELL) / 2.0
	draw_circle(c + Vector2(-22, -22), 8.0, BEAR_COLOR)
	draw_circle(c + Vector2(22, -22), 8.0, BEAR_COLOR)
	draw_rect(Rect2(c - Vector2(27, 27), Vector2(54, 54)), BEAR_COLOR)
	draw_rect(Rect2(c + Vector2(-13, 4), Vector2(26, 20)), Color("d9b18c"))
	draw_circle(c + Vector2(0, 8), 4.0, Color("1a1a1a"))
	_draw_eyes(c, 13.0)
