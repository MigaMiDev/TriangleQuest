extends CanvasLayer

signal finished(upgrade: String)

const NOMBRES := {3: "Triángulo", 4: "Cuadrado", 5: "Pentágono",
		6: "Hexágono", 7: "Heptágono", 8: "Octágono"}

const MEJORAS := {
	"explosivo": "Flechas explosivas (daño en área)",
	"triple": "Disparo múltiple (+2 flechas)",
	"dano": "Más daño (+1)",
}

const CRITERIOS := {
	"LLL": "LLL (Lado-Lado-Lado)",
	"LAL": "LAL (Lado-Ángulo-Lado)",
	"ALA": "ALA (Ángulo-Lado-Ángulo)",
}
const AAA := "AAA (no es criterio de congruencia)"

const EXPLICACIONES := {
	"LLL": "LLL: los tres lados de un triángulo miden lo mismo que los tres lados del otro.",
	"LAL": "LAL: dos lados y el ángulo comprendido ENTRE ellos son iguales en ambos triángulos.",
	"ALA": "ALA: dos ángulos y el lado comprendido ENTRE ellos son iguales en ambos triángulos.",
	"AAA": "AAA: tener los mismos ángulos solo asegura que los triángulos son semejantes (misma forma), no congruentes (mismo tamaño).",
}

const TOTAL_TIPOS := 11   # number of question types in _new_question

var title_label: Label
var shape_area: CenterContainer
var answers_box: VBoxContainer
var correct_answer: String = ""
var explanation: String = ""

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
	title_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title_label)

	shape_area = CenterContainer.new()
	vbox.add_child(shape_area)

	answers_box = VBoxContainer.new()
	answers_box.add_theme_constant_override("separation", 8)
	vbox.add_child(answers_box)

# ---------- QUESTIONS ----------

func _new_question() -> void:
	_clear(shape_area)
	explanation = ""
	var sides: int = NOMBRES.keys().pick_random()
	var options: Array = []

	match randi() % TOTAL_TIPOS:
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

		# ----- CONGRUENCIA: LLL, LAL, ALA -----
		5: # picture: which criterion?
			var k: String = CRITERIOS.keys().pick_random()
			title_label.text = "Las partes marcadas con el mismo color son iguales en los dos triángulos.\n¿Qué criterio de congruencia se cumple?"
			_draw_congruent_pair(k)
			correct_answer = CRITERIOS[k]
			explanation = EXPLICACIONES[k]
			options = CRITERIOS.values()
			options.append(AAA)
		6: # description: which criterion?
			var k: String = CRITERIOS.keys().pick_random()
			var desc := {
				"LLL": "los tres lados",
				"LAL": "dos lados y el ángulo comprendido entre ellos",
				"ALA": "dos ángulos y el lado comprendido entre ellos",
			}
			title_label.text = "Dos triángulos tienen iguales %s.\n¿Qué criterio de congruencia se cumple?" % desc[k]
			correct_answer = CRITERIOS[k]
			explanation = EXPLICACIONES[k]
			options = CRITERIOS.values()
			options.append(AAA)
		7: # numbers: which criterion?
			var k: String = CRITERIOS.keys().pick_random()
			var d := _triangle_data(k)
			title_label.text = "El triángulo 1 tiene %s.\nEl triángulo 2 tiene %s.\n¿Qué criterio permite decir que son congruentes?" % [d[0], d[1]]
			correct_answer = CRITERIOS[k]
			explanation = EXPLICACIONES[k]
			options = CRITERIOS.values()
			options.append(AAA)
		8: # are they congruent?
			options = ["Sí, por LLL", "Sí, por LAL", "Sí, por ALA", "No se puede asegurar"]
			var variant := randi() % 3
			if variant == 0:
				var k: String = CRITERIOS.keys().pick_random()
				var d := _triangle_data(k)
				title_label.text = "El triángulo 1 tiene %s.\nEl triángulo 2 tiene %s.\n¿Son congruentes?" % [d[0], d[1]]
				correct_answer = "Sí, por " + k
				explanation = EXPLICACIONES[k]
			elif variant == 1:
				var a: int = 5 * randi_range(6, 16)
				var b: int = 5 * randi_range(6, 16)
				var c: int = 180 - a - b
				title_label.text = "El triángulo 1 tiene ángulos de %d°, %d° y %d°.\nEl triángulo 2 tiene ángulos de %d°, %d° y %d°.\n¿Son congruentes?" % [a, b, c, a, b, c]
				correct_answer = "No se puede asegurar"
				explanation = EXPLICACIONES["AAA"]
			else:
				var a: int = randi_range(4, 10)
				var b: int = randi_range(4, 10)
				var ang: int = 5 * randi_range(6, 24)
				title_label.text = "El triángulo 1 tiene lados de %d cm y %d cm, y un ángulo de %d° que NO está entre ellos.\nEl triángulo 2 tiene los mismos dos lados y el mismo ángulo, también sin estar entre ellos.\n¿Son congruentes?" % [a, b, ang]
				correct_answer = "No se puede asegurar"
				explanation = "Con dos lados y un ángulo que NO está entre ellos no se puede asegurar la congruencia. En LAL el ángulo debe estar comprendido entre los dos lados."
		9: # missing value
			if randi() % 2 == 0:
				var a: int = randi_range(4, 10)
				var b: int = randi_range(4, 10)
				var ang: int = 5 * randi_range(6, 24)
				title_label.text = "Dos triángulos son congruentes por LAL.\nEl triángulo 1 tiene lados de %d cm y %d cm con un ángulo de %d° entre ellos.\nEl triángulo 2 tiene lados de %d cm y x cm con un ángulo de %d° entre ellos.\n¿Cuánto vale x?" % [a, b, ang, a, ang]
				correct_answer = str(b) + " cm"
				explanation = "Si son congruentes, los lados correspondientes miden lo mismo, así que x = %d cm." % b
				options = _numeric_options(b, 1, " cm")
			else:
				var a: int = 5 * randi_range(6, 16)
				var b: int = 5 * randi_range(6, 16)
				var c: int = 180 - a - b
				title_label.text = "Dos triángulos son congruentes por ALA.\nEl triángulo 1 tiene ángulos de %d° y %d°.\n¿Cuánto mide el tercer ángulo del triángulo 2?" % [a, b]
				correct_answer = str(c) + "°"
				explanation = "Los ángulos de un triángulo suman 180°: 180° − %d° − %d° = %d°." % [a, b, c]
				options = _numeric_options(c, 10, "°")
		10: # where must the angle / side be?
			var k: String = ["LAL", "ALA"].pick_random()
			if k == "LAL":
				title_label.text = "En el criterio LAL, ¿dónde debe estar el ángulo?"
				correct_answer = "Entre los dos lados"
				options = ["Entre los dos lados", "No importa dónde esté", "Debe ser un ángulo recto", "Debe ser el ángulo mayor"]
			else:
				title_label.text = "En el criterio ALA, ¿dónde debe estar el lado?"
				correct_answer = "Entre los dos ángulos"
				options = ["Entre los dos ángulos", "No importa dónde esté", "Debe ser el lado más largo", "Debe ser el lado más corto"]
			explanation = EXPLICACIONES[k]

	_set_options(options)

# Returns [description of triangle 1, description of triangle 2] that satisfy criterion k
func _triangle_data(k: String) -> Array:
	match k:
		"LLL":
			var a: int = randi_range(4, 8)
			var b: int = randi_range(4, 8)
			var c: int = randi_range(absi(a - b) + 1, a + b - 1)
			return ["lados de %d, %d y %d cm" % [a, b, c],
					"lados de %d, %d y %d cm" % [c, a, b]]
		"LAL":
			var a: int = randi_range(4, 10)
			var b: int = randi_range(4, 10)
			var ang: int = 5 * randi_range(6, 24)
			return ["lados de %d cm y %d cm con un ángulo de %d° entre ellos" % [a, b, ang],
					"lados de %d cm y %d cm con un ángulo de %d° entre ellos" % [b, a, ang]]
		_: # ALA
			var a1: int = 5 * randi_range(6, 16)
			var a2: int = 5 * randi_range(6, 16)
			var s: int = randi_range(4, 10)
			return ["ángulos de %d° y %d° con un lado de %d cm entre ellos" % [a1, a2, s],
					"ángulos de %d° y %d° con un lado de %d cm entre ellos" % [a2, a1, s]]

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

# ---------- DRAWING ----------

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

# Two congruent triangles with the parts of criterion "mode" marked in matching colors
func _draw_congruent_pair(mode: String) -> void:
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(460, 180)
	shape_area.add_child(holder)

	var base := [Vector2(30, 150), Vector2(190, 150), Vector2(80, 30)]  # A, B, C
	var c1 := Color.RED
	var c2 := Color.LIME_GREEN
	var c3 := Color.GOLD

	for t in 2:
		var pts: Array = []
		for p in base:
			pts.append(p if t == 0 else Vector2(460.0 - p.x, p.y))  # 2nd one is mirrored

		var poly := Polygon2D.new()
		poly.polygon = PackedVector2Array(pts)
		poly.color = Color(0.39, 0.58, 0.93, 0.35)
		holder.add_child(poly)

		# gray outline
		_line(holder, pts[0], pts[1], Color.GRAY, 2.0)
		_line(holder, pts[1], pts[2], Color.GRAY, 2.0)
		_line(holder, pts[2], pts[0], Color.GRAY, 2.0)

		match mode:
			"LLL":
				_line(holder, pts[0], pts[1], c1, 5.0)
				_line(holder, pts[1], pts[2], c2, 5.0)
				_line(holder, pts[2], pts[0], c3, 5.0)
			"LAL":
				_line(holder, pts[0], pts[1], c1, 5.0)
				_line(holder, pts[2], pts[0], c2, 5.0)
				_arc(holder, pts[0], pts[1], pts[2], c3)
			"ALA":
				_arc(holder, pts[0], pts[1], pts[2], c1)
				_arc(holder, pts[1], pts[0], pts[2], c2)
				_line(holder, pts[0], pts[1], c3, 5.0)

func _line(parent: Control, a: Vector2, b: Vector2, color: Color, width: float) -> void:
	var l := Line2D.new()
	l.width = width
	l.default_color = color
	l.add_point(a)
	l.add_point(b)
	parent.add_child(l)

# Draws an arc marking the angle at vertex v between the directions toward p and q
func _arc(parent: Control, v: Vector2, p: Vector2, q: Vector2, color: Color) -> void:
	var a1: float = (p - v).angle()
	var delta: float = wrapf((q - v).angle() - a1, -PI, PI)
	var l := Line2D.new()
	l.width = 5.0
	l.default_color = color
	for i in 13:
		var ang: float = a1 + delta * i / 12.0
		l.add_point(v + Vector2(cos(ang), sin(ang)) * 26.0)
	parent.add_child(l)

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
		if explanation != "":
			title_label.text += "\n\n" + explanation
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
