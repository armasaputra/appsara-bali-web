extends Control

# Nodes
@onready var label_title: Label = $TitleBoard/LabelTitle
@onready var label_subtitle: Label = $TitleBoard/LabelSubtitle
@onready var label_page: Label = $SmallBoard/LabelPage

@onready var aksara_char_image: TextureRect = $MateriBox/ContentContainer/AksaraCharImage
@onready var label_dibaca_prefix: Label = $MateriBox/ContentContainer/DibacaContainer/LabelPrefix
@onready var label_dibaca_highlight: Label = $MateriBox/ContentContainer/DibacaContainer/LabelHighlight
@onready var label_keterangan: Label = $MateriBox/ContentContainer/LabelKeterangan
@onready var label_kata: Label = $MateriBox/ContentContainer/LabelKata
@onready var aksara_kata_image: TextureRect = $MateriBox/ContentContainer/AksaraKataImage
@onready var content_container: Control = $MateriBox/ContentContainer

@onready var btn_top: TextureButton = $BtnTop
@onready var label_top: Label = $BtnTop/LabelTop
@onready var btn_bottom: TextureButton = $BtnBottom
@onready var label_bottom: Label = $BtnBottom/LabelBottom

# State
var current_materi_id: int = 1
var current_page_index: int = 0
var current_materi_data: Dictionary = {}

# Materi Data Definition
const ALL_MATERI_DATA = {
	1: {
		"title": "MATERI 1",
		"subtitle": "Kelompok 1 : Aksara Wreastra (5 aksara)",
		"pages": [
			{
				"highlight": "Ha",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ha-Ha’",
				"char_image": "res://assets/Aksara/ha.png",
				"word_image": "res://assets/Aksara/ha_ha.png"
			},
			{
				"highlight": "Na",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Na-Na’",
				"char_image": "res://assets/Aksara/na.png",
				"word_image": "res://assets/Aksara/na_na.png"
			},
			{
				"highlight": "Ca",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ca-Ca’",
				"char_image": "res://assets/Aksara/ca.png",
				"word_image": "res://assets/Aksara/ca_ca.png"
			},
			{
				"highlight": "Ra",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ra-Ra’",
				"char_image": "res://assets/Aksara/ra.png",
				"word_image": "res://assets/Aksara/ra_ra.png"
			},
			{
				"highlight": "Ka",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ka-Ka’",
				"char_image": "res://assets/Aksara/ka.png",
				"word_image": "res://assets/Aksara/ka_ka.png"
			}
		]
	},
	2: {
		"title": "MATERI 2",
		"subtitle": "Kelompok 2 : Aksara Wreastra (5 aksara)",
		"pages": [
			{"highlight": "Da", "keterangan": "kata sederhana (2 suku kata)", "kata": "‘Da-Da’", "char_image": "", "word_image": ""},
			{"highlight": "Ta", "keterangan": "kata sederhana (2 suku kata)", "kata": "‘Ta-Ta’", "char_image": "", "word_image": ""},
			{"highlight": "Sa", "keterangan": "kata sederhana (2 suku kata)", "kata": "‘Sa-Sa’", "char_image": "", "word_image": ""},
			{"highlight": "Wa", "keterangan": "kata sederhana (2 suku kata)", "kata": "‘Wa-Wa’", "char_image": "", "word_image": ""},
			{"highlight": "La", "keterangan": "kata sederhana (2 suku kata)", "kata": "‘La-La’", "char_image": "", "word_image": ""}
		]
	},
	3: {
		"title": "MATERI 3",
		"subtitle": "Kelompok 3 : Aksara Wreastra (4 aksara)",
		"pages": [
			{"highlight": "Ma", "keterangan": "kata sederhana (2 suku kata)", "kata": "‘Ma-Ma’", "char_image": "", "word_image": ""},
			{"highlight": "Ga", "keterangan": "kata sederhana (2 suku kata)", "kata": "‘Ga-Ga’", "char_image": "", "word_image": ""},
			{"highlight": "Ba", "keterangan": "kata sederhana (2 suku kata)", "kata": "‘Ba-Ba’", "char_image": "", "word_image": ""},
			{"highlight": "Nga", "keterangan": "kata sederhana (2 suku kata)", "kata": "‘Nga-Nga’", "char_image": "", "word_image": ""}
		]
	},
	4: {
		"title": "MATERI 4",
		"subtitle": "Kelompok 4 : Aksara Wreastra (4 aksara)",
		"pages": [
			{"highlight": "Pa", "keterangan": "kata sederhana (2 suku kata)", "kata": "‘Pa-Pa’", "char_image": "", "word_image": ""},
			{"highlight": "Ja", "keterangan": "kata sederhana (2 suku kata)", "kata": "‘Ja-Ja’", "char_image": "", "word_image": ""},
			{"highlight": "Ya", "keterangan": "kata sederhana (2 suku kata)", "kata": "‘Ya-Ya’", "char_image": "", "word_image": ""},
			{"highlight": "Nya", "keterangan": "kata sederhana (2 suku kata)", "kata": "‘Nya-Nya’", "char_image": "", "word_image": ""}
		]
	},
	5: {
		"title": "MATERI 5",
		"subtitle": "Gantungan Aksara (Bagian 1)",
		"pages": [
			{"highlight": "Gantungan Ha", "keterangan": "contoh gantungan", "kata": "‘Subaha’", "char_image": "", "word_image": ""},
			{"highlight": "Gantungan Na", "keterangan": "contoh gantungan", "kata": "‘Bikna’", "char_image": "", "word_image": ""},
			{"highlight": "Gantungan Ca", "keterangan": "contoh gantungan", "kata": "‘Pakca’", "char_image": "", "word_image": ""},
			{"highlight": "Gantungan Ra", "keterangan": "contoh gantungan", "kata": "‘Cakra’", "char_image": "", "word_image": ""},
			{"highlight": "Gantungan Ka", "keterangan": "contoh gantungan", "kata": "‘Pekka’", "char_image": "", "word_image": ""}
		]
	},
	6: {
		"title": "MATERI 6",
		"subtitle": "Gantungan Aksara (Bagian 2)",
		"pages": [
			{"highlight": "Gantungan Da", "keterangan": "contoh gantungan", "kata": "‘Bedda’", "char_image": "", "word_image": ""},
			{"highlight": "Gantungan Ta", "keterangan": "contoh gantungan", "kata": "‘Katta’", "char_image": "", "word_image": ""},
			{"highlight": "Gantungan Sa", "keterangan": "contoh gantungan", "kata": "‘Paksa’", "char_image": "", "word_image": ""},
			{"highlight": "Gantungan Wa", "keterangan": "contoh gantungan", "kata": "‘Dewa’", "char_image": "", "word_image": ""},
			{"highlight": "Gantungan La", "keterangan": "contoh gantungan", "kata": "‘Sukla’", "char_image": "", "word_image": ""}
		]
	},
	7: {
		"title": "MATERI 7",
		"subtitle": "Pengangge Suara (Vokal)",
		"pages": [
			{"highlight": "Tedung (a)", "keterangan": "pengangge suara", "kata": "‘Bapa’", "char_image": "", "word_image": ""},
			{"highlight": "Ulu (i)", "keterangan": "pengangge suara", "kata": "‘Bibi’", "char_image": "", "word_image": ""},
			{"highlight": "Suku (u)", "keterangan": "pengangge suara", "kata": "‘Buku’", "char_image": "", "word_image": ""},
			{"highlight": "Taleng (e)", "keterangan": "pengangge suara", "kata": "‘Lele’", "char_image": "", "word_image": ""},
			{"highlight": "Pepet (e')", "keterangan": "pengangge suara", "kata": "‘Beras’", "char_image": "", "word_image": ""}
		]
	},
	8: {
		"title": "MATERI 8",
		"subtitle": "Pengangge Tengenan (Konsonan Akhir)",
		"pages": [
			{"highlight": "Cecek (ng)", "keterangan": "pengangge tengenan", "kata": "‘Wayang’", "char_image": "", "word_image": ""},
			{"highlight": "Surang (r)", "keterangan": "pengangge tengenan", "kata": "‘Pasar’", "char_image": "", "word_image": ""},
			{"highlight": "Bisah (h)", "keterangan": "pengangge tengenan", "kata": "‘Gajah’", "char_image": "", "word_image": ""},
			{"highlight": "Adeg-adeg (paten)", "keterangan": "pengangge tengenan", "kata": "‘Anak’", "char_image": "", "word_image": ""}
		]
	}
}

func _ready() -> void:
	# Determine current materi ID from PlayerData
	if PlayerData and PlayerData.current_materi_index > 0:
		current_materi_id = PlayerData.current_materi_index
	else:
		current_materi_id = 1
	
	if ALL_MATERI_DATA.has(current_materi_id):
		current_materi_data = ALL_MATERI_DATA[current_materi_id]
	else:
		current_materi_data = ALL_MATERI_DATA[1]
	
	current_page_index = 0
	
	# Setup button animations
	_setup_button_effects(btn_top)
	_setup_button_effects(btn_bottom)
	
	btn_top.pressed.connect(_on_btn_top_pressed)
	btn_bottom.pressed.connect(_on_btn_bottom_pressed)
	
	# Render initial page
	_render_page()

func _setup_button_effects(btn: TextureButton) -> void:
	btn.button_down.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(0.94, 0.94), 0.08).set_trans(Tween.TRANS_QUAD)
	)
	btn.button_up.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)
	btn.mouse_entered.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.025, 1.025), 0.15).set_trans(Tween.TRANS_SINE)
	)
	btn.mouse_exited.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE)
	)

func _render_page() -> void:
	var pages: Array = current_materi_data.get("pages", [])
	var total_pages: int = pages.size()
	if total_pages == 0:
		return
		
	var page_data: Dictionary = pages[current_page_index]
	
	# Update Title & Subtitle
	label_title.text = current_materi_data.get("title", "MATERI %d" % current_materi_id)
	label_subtitle.text = current_materi_data.get("subtitle", "")
	
	# Update Page indicator (e.g. 1/5)
	label_page.text = "%d/%d" % [current_page_index + 1, total_pages]
	
	# Update Content
	label_dibaca_prefix.text = "Dibaca : "
	label_dibaca_highlight.text = page_data.get("highlight", "")
	label_keterangan.text = page_data.get("keterangan", "kata sederhana (2 suku kata)")
	label_kata.text = page_data.get("kata", "")
	
	# Update Aksara character image if available
	var char_img_path = page_data.get("char_image", "")
	if not char_img_path.is_empty() and ResourceLoader.exists(char_img_path):
		aksara_char_image.texture = load(char_img_path)
		aksara_char_image.visible = true
	else:
		aksara_char_image.visible = true # Keeps placeholder space intact
	
	# Update Aksara word image if available
	var word_img_path = page_data.get("word_image", "")
	if not word_img_path.is_empty() and ResourceLoader.exists(word_img_path):
		aksara_kata_image.texture = load(word_img_path)
		aksara_kata_image.visible = true
	else:
		aksara_kata_image.visible = true # Keeps placeholder space intact
	
	# Update Button States & Labels
	_update_buttons(total_pages)

func _update_buttons(total_pages: int) -> void:
	if current_page_index == 0:
		# Page 1
		label_top.text = "Lanjut"
		label_top.label_settings.font_size = 64
		
		label_bottom.text = "Kembali"
		label_bottom.label_settings.font_size = 64
	elif current_page_index >= total_pages - 1:
		# Last Page
		label_top.text = "Kembali"
		label_top.label_settings.font_size = 64
		
		label_bottom.text = "Materi sebelumnya"
		label_bottom.label_settings.font_size = 42
	else:
		# Middle Pages (2, 3, 4)
		label_top.text = "Lanjut"
		label_top.label_settings.font_size = 64
		
		label_bottom.text = "Materi sebelumnya"
		label_bottom.label_settings.font_size = 42

func _on_btn_top_pressed() -> void:
	var pages: Array = current_materi_data.get("pages", [])
	var total_pages: int = pages.size()
	
	if current_page_index >= total_pages - 1:
		# Last page: Top button functions as "Kembali" to Materi menu
		_go_back_to_materi()
	else:
		# Next page
		current_page_index += 1
		_animate_page_transition()

func _on_btn_bottom_pressed() -> void:
	if current_page_index == 0:
		# Page 1: Bottom button functions as "Kembali" to Materi menu
		_go_back_to_materi()
	else:
		# Previous page
		current_page_index -= 1
		_animate_page_transition()

func _animate_page_transition() -> void:
	_render_page()
	var tween = create_tween()
	content_container.modulate.a = 0.3
	tween.tween_property(content_container, "modulate:a", 1.0, 0.15).set_trans(Tween.TRANS_SINE)

func _go_back_to_materi() -> void:
	print("Kembali ke daftar Materi...")
	get_tree().change_scene_to_file("res://scenes/Materi.tscn")
