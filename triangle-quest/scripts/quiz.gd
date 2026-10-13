extends CanvasLayer

signal finished(upgrade: String)

const NOMBRES := {3: "Triángulo", 4: "Cuadrado", 5: "Pentágono",
		6: "Hexágono", 7: "Heptágono", 8: "Octágono"}

const MEJORAS := {
	"explosivo": "Flechas explosivas (daño en área)",
	"triple": "Disparo múltiple (+2 flechas)",
	"dano": "Más daño (+1)",
}

var title_label: Label
var shape_area: CenterContainer
var answers_box: VBoxContainer
var correct_answer: String = ""

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS   # keeps working while the game is paused
	get_tree().paused = true
	_build_ui()
	_new_question()

func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	title_label = Label.new()
	title_label.custom_minimum_size = Vector2(470, 0)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title_label)

	shape_area = CenterContainer.new()
	vbox.add_child(shape_area)

	answers_box = VBoxContainer.new()
	answers_box.add_theme_constant_override("separation", 8)
	vbox.add_child(answers_box)

# ---------- QUESTIONS ----------

func _new_question() -> void:
	_clear(shape_area)
	var sides: int = NOMBRES.keys().pick_random()
	var options: Array = []

	match randi() % 5:
		0: # polygon name
			title_label.text = "¿Qué polígono es este?"
			_draw_polygon(sides)
			correct_answer = NOMBRES[sides]
			var wrong: Array = NOMBRES.values().filter(func(x): return x != correct_answer)
			wrong.shuffle()
			options = wrong.slice(0, 3)
			options.append(correct_answer)
		1: # number of sides
			title_label.text = "¿Cuántos lados tiene esta figura?"
			_draw_polygon(sides)
			correct_answer = str(sides)
			options = _numeric_options(sides, 1)
		2: # interior angle sum
			title_label.text = "¿Cuánto suman los ángulos interiores de esta figura?\n(Pista: (lados − 2) × 180°)"
			_draw_polygon(sides)
			correct_answer = str((sides - 2) * 180) + "°"
			options = _numeric_options((sides - 2) * 180, 180, "°")
		3: # missing triangle angle
			var a: int = 5 * randi_range(4, 16)
			var b: int = 5 * randi_range(4, 16)
			var c: int = 180 - a - b
			title_label.text = "Un triángulo tiene ángulos de %d° y %d°.\n¿Cuánto mide el tercer ángulo?" % [a, b]
			correct_answer = str(c) + "°"
			options = _numeric_options(c, 10, "°")
		4: # triangle area
			var base: int = 2 * randi_range(2, 10)
			var altura: int = randi_range(2, 10)
			var area: int = base * altura / 2
			title_label.text = "Un triángulo tiene base %d cm y altura %d cm.\n¿Cuál es su área?\n(Pista: base × altura ÷ 2)" % [base, altura]
			correct_answer = str(area) + " cm²"
			options = _numeric_options(area, 2, " cm²")

	_set_options(options)

# returns 4 unique answers (the correct one + 3 near it)
func _numeric_options(correct: int, step: int, suffix: String = "") -> Array:
	var seen := {correct: true}
	var tries := 0
	while seen.size() < 4 and tries < 100:
		tries += 1
		var candidate: int = correct + step * randi_range(-3, 3)
		if candidate > 0:
			seen[candidate] = true
	var result: Array = []
	for v in seen.keys():
		result.append(str(v) + suffix)
	return result

func _draw_polygon(sides: int) -> void:
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(200, 200)
	shape_area.add_child(holder)

	var poly := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in sides:
		var ang := TAU * i / sides - PI / 2.0
		pts.append(Vector2(cos(ang), sin(ang)) * 85.0)
	poly.polygon = pts
	poly.color = Color.CORNFLOWER_BLUE
	poly.position = Vector2(100, 100)
	holder.add_child(poly)

# ---------- UI FLOW ----------

func _set_options(options: Array) -> void:
	_clear(answers_box)
	options.shuffle()
	for opt in options:
		var b := Button.new()
		b.text = str(opt)
		b.custom_minimum_size = Vector2(0, 44)
		b.pressed.connect(_on_answer.bind(str(opt)))
		answers_box.add_child(b)

func _on_answer(chosen: String) -> void:
	if chosen == correct_answer:
		_show_upgrades()
	else:
		_clear(shape_area)
		_clear(answers_box)
		title_label.text = "Incorrecto.\nLa respuesta correcta era: %s" % correct_answer
		var b := Button.new()
		b.text = "Continuar"
		b.custom_minimum_size = Vector2(0, 44)
		b.pressed.connect(_finish.bind(""))
		answers_box.add_child(b)

func _show_upgrades() -> void:
	_clear(shape_area)
	_clear(answers_box)
	title_label.text = "¡Correcto! Elige tu mejora:"
	for key in MEJORAS:
		var b := Button.new()
		b.text = MEJORAS[key]
		b.custom_minimum_size = Vector2(0, 44)
		b.pressed.connect(_finish.bind(key))
		answers_box.add_child(b)

func _finish(upgrade: String) -> void:
	get_tree().paused = false
	finished.emit(upgrade)
	queue_free()

func _clear(node: Node) -> void:
	for c in node.get_children():
		node.remove_child(c)
		c.queue_free()
