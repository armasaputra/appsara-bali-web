extends Control

# Nodes
@onready var label_title: Label = $TitleBoard/LabelTitle
@onready var label_subtitle: Label = $TitleBoard/LabelSubtitle
@onready var label_page: Label = $SmallBoard/LabelPage
@onready var btn_info: TextureButton = $BtnInfo

@onready var content_container: Control = $MateriBox/ContentContainer
@onready var single_char_container: Control = $MateriBox/ContentContainer/SingleCharContainer
@onready var aksara_char_image: TextureRect = $MateriBox/ContentContainer/SingleCharContainer/AksaraCharImage

@onready var dual_char_container: HBoxContainer = $MateriBox/ContentContainer/DualCharContainer
@onready var label_base_title: Label = $MateriBox/ContentContainer/DualCharContainer/LeftBox/LabelBaseTitle
@onready var base_char_image: TextureRect = $MateriBox/ContentContainer/DualCharContainer/LeftBox/BaseCharImage
@onready var label_base_name: Label = $MateriBox/ContentContainer/DualCharContainer/LeftBox/LabelBaseName
@onready var label_gantungan_title: Label = $MateriBox/ContentContainer/DualCharContainer/RightBox/LabelGantunganTitle
@onready var gantungan_char_image: TextureRect = $MateriBox/ContentContainer/DualCharContainer/RightBox/GantunganCharImage
@onready var label_gantungan_name: Label = $MateriBox/ContentContainer/DualCharContainer/RightBox/LabelGantunganName

@onready var label_dibaca_prefix: Label = $MateriBox/ContentContainer/DibacaContainer/LabelPrefix
@onready var label_dibaca_highlight: Label = $MateriBox/ContentContainer/DibacaContainer/LabelHighlight
@onready var label_keterangan: Label = $MateriBox/ContentContainer/LabelKeterangan
@onready var label_kata: Label = $MateriBox/ContentContainer/LabelKata
@onready var aksara_kata_image: TextureRect = $MateriBox/ContentContainer/AksaraKataImage

@onready var btn_top: TextureButton = $BtnTop
@onready var label_top: Label = $BtnTop/LabelTop
@onready var btn_bottom: TextureButton = $BtnBottom
@onready var label_bottom: Label = $BtnBottom/LabelBottom

# Info Popup Layer Nodes
@onready var info_popup_layer: Control = $InfoPopupLayer
@onready var info_popup_container: Control = $InfoPopupLayer/PopupContainer
@onready var btn_close_info: TextureButton = $InfoPopupLayer/PopupContainer/PopupFrame/BtnCloseInfo
@onready var label_info_title: Label = $InfoPopupLayer/PopupContainer/PopupFrame/LabelInfoTitle
@onready var label_info_desc: Label = $InfoPopupLayer/PopupContainer/PopupFrame/LabelInfoDesc
@onready var info_image: TextureRect = $InfoPopupLayer/PopupContainer/PopupFrame/InfoImage
@onready var label_info_note: Label = $InfoPopupLayer/PopupContainer/PopupFrame/LabelInfoNote
@onready var btn_tutup_info: TextureButton = $InfoPopupLayer/PopupContainer/BtnTutupInfo

# State
var current_materi_id: int = 1
var current_page_index: int = 0
var current_materi_data: Dictionary = {}
var _is_info_open: bool = false

# 8 Materi Data Definition (From PDF)
const ALL_MATERI_DATA = {
	1: {
		"title": "MATERI 1",
		"subtitle": "Kelompok 1 : Aksara Wreastra (5 aksara)",
		"type": "wreastra",
		"pages": [
			{
				"highlight": "Ha",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ha-Ha’",
				"char_image": "res://assets/Aksara/a,ha.png",
				"word_image": "res://assets/Aksara/a,ha (Ha-Ha).png"
			},
			{
				"highlight": "Na",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ha-Na’",
				"char_image": "res://assets/Aksara/na.png",
				"word_image": "res://assets/Aksara/na (Ha-Na).png"
			},
			{
				"highlight": "Ca",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ca-Ca’",
				"char_image": "res://assets/Aksara/ca.png",
				"word_image": "res://assets/Aksara/ca (Ca-Ca).png"
			},
			{
				"highlight": "Ra",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ca-Ra’",
				"char_image": "res://assets/Aksara/ra.png",
				"word_image": "res://assets/Aksara/ra (Ca-Ra).png"
			},
			{
				"highlight": "Ka",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ra-Ka’",
				"char_image": "res://assets/Aksara/ka.png",
				"word_image": "res://assets/Aksara/ka (Ra-Ka).png"
			}
		]
	},
	2: {
		"title": "MATERI 2",
		"subtitle": "Kelompok 2 : Aksara Wreastra (5 aksara)",
		"type": "wreastra",
		"pages": [
			{
				"highlight": "Da",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Na-Da’",
				"char_image": "res://assets/Aksara/da.png",
				"word_image": "res://assets/Aksara/da (Na-Da).png"
			},
			{
				"highlight": "Ta",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ta-Ta’",
				"char_image": "res://assets/Aksara/ta.png",
				"word_image": "res://assets/Aksara/ta (Ta-Ta).png"
			},
			{
				"highlight": "Sa",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Da-Sa’",
				"char_image": "res://assets/Aksara/sa.png",
				"word_image": "res://assets/Aksara/sa (Da-Sa).png"
			},
			{
				"highlight": "Wa",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Wa-Na’",
				"char_image": "res://assets/Aksara/wa.png",
				"word_image": "res://assets/Aksara/wa (Wa-Na).png"
			},
			{
				"highlight": "La",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ka-La’",
				"char_image": "res://assets/Aksara/la.png",
				"word_image": "res://assets/Aksara/la (Ka-La).png"
			}
		]
	},
	3: {
		"title": "MATERI 3",
		"subtitle": "Kelompok 3 : Aksara Wreastra (4 aksara)",
		"type": "wreastra",
		"pages": [
			{
				"highlight": "Ma",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ma-Da’",
				"char_image": "res://assets/Aksara/ma.png",
				"word_image": "res://assets/Aksara/ma (Ma-Da).png"
			},
			{
				"highlight": "Ga",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ga-Ma’",
				"char_image": "res://assets/Aksara/ga.png",
				"word_image": "res://assets/Aksara/ga (Ga-Ma).png"
			},
			{
				"highlight": "Ba",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ba-La’",
				"char_image": "res://assets/Aksara/ba.png",
				"word_image": "res://assets/Aksara/ba (Ba-La).png"
			},
			{
				"highlight": "Nga",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Nga-Nga’",
				"char_image": "res://assets/Aksara/nga.png",
				"word_image": "res://assets/Aksara/nga (Nga-Nga).png"
			}
		]
	},
	4: {
		"title": "MATERI 4",
		"subtitle": "Kelompok 4 : Aksara Wreastra (4 aksara)",
		"type": "wreastra",
		"pages": [
			{
				"highlight": "Pa",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Pa-Pa’",
				"char_image": "res://assets/Aksara/pa.png",
				"word_image": "res://assets/Aksara/pa (Pa-Pa).png"
			},
			{
				"highlight": "Ja",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ja-La’",
				"char_image": "res://assets/Aksara/ja.png",
				"word_image": "res://assets/Aksara/ja (Ja-La).png"
			},
			{
				"highlight": "Ya",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Ya-Na’",
				"char_image": "res://assets/Aksara/ya.png",
				"word_image": "res://assets/Aksara/ya (Ya-Na).png"
			},
			{
				"highlight": "Nya",
				"prefix": "Dibaca : ",
				"keterangan": "kata sederhana (2 suku kata)",
				"kata": "‘Nya-Pa’",
				"char_image": "res://assets/Aksara/nya.png",
				"word_image": "res://assets/Aksara/nya (Nya-Pa).png"
			}
		]
	},
	5: {
		"title": "MATERI 5",
		"subtitle": "Kelompok 1 : Gantungan & Gempelan (5 aksara)",
		"type": "gantungan",
		"intro": {
			"title": "CARA MENGGUNAKAN GANTUNGAN",
			"description": "Fungsi Gantungan adalah untuk mematikan suara huruf agar tidak dibaca dengan akhiran 'a'. Gantungan letaknya selalu ada di bawah huruf yang dimatikan.",
			"image": "res://assets/Aksara/1. Materi pembuka Bakta.png",
			"note": "Perhatikan contoh di atas! Agar huruf 'Ka' kehilangan suara 'a' (berubah menjadi huruf mati 'k'), maka kita harus menempelkan Gantungan 'Ta' tepat di bawahnya."
		},
		"pages": [
			{
				"aksara_name": "Ha",
				"pair_name": "Gantungan Ha",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Ha’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘PanHara’",
				"kata": "‘PanHara’",
				"char_image": "res://assets/Aksara/a,ha.png",
				"gantungan_image": "res://assets/Aksara/a, ha (gantungan).png",
				"word_image": "res://assets/Aksara/a,h (panhara).png"
			},
			{
				"aksara_name": "Na",
				"pair_name": "Gantungan Na",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Na’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Ratna’",
				"kata": "‘Ratna’",
				"char_image": "res://assets/Aksara/na.png",
				"gantungan_image": "res://assets/Aksara/na (gantungan).png",
				"word_image": "res://assets/Aksara/na (Ratna).png"
			},
			{
				"aksara_name": "Ca",
				"pair_name": "Gantungan Ca",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Ca’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Pasca’",
				"kata": "‘Pasca’",
				"char_image": "res://assets/Aksara/ca.png",
				"gantungan_image": "res://assets/Aksara/ca (gantungan).png",
				"word_image": "res://assets/Aksara/ca (pasca).png"
			},
			{
				"aksara_name": "Ra",
				"pair_name": "Gantungan Ra",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Ra’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Cakra’",
				"kata": "‘Cakra’",
				"char_image": "res://assets/Aksara/ra.png",
				"gantungan_image": "res://assets/Aksara/ra (gantungan).png",
				"word_image": "res://assets/Aksara/ra (cakra).png"
			},
			{
				"aksara_name": "Ka",
				"pair_name": "Gantungan Ka",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Ka’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Paska’",
				"kata": "‘Paska’",
				"char_image": "res://assets/Aksara/ka.png",
				"gantungan_image": "res://assets/Aksara/ka (gantungan).png",
				"word_image": "res://assets/Aksara/ka (paska).png"
			}
		]
	},
	6: {
		"title": "MATERI 6",
		"subtitle": "Kelompok 2 : Gantungan & Gempelan (5 aksara)",
		"type": "gantungan",
		"intro": {
			"title": "CARA MENGGUNAKAN GEMPELAN",
			"description": "Sama seperti Gantungan, Gempelan juga berfungsi untuk mematikan suara huruf. Bedanya, Gempelan letaknya ada di samping kanan huruf yang dimatikan.",
			"image": "res://assets/Aksara/ja (manja).png",
			"note": "Perhatikan contoh di atas! Agar huruf 'Na' kehilangan suara 'a' (berubah menjadi huruf mati 'n'), maka kita harus menempelkan Gantungan 'Ja' tepat di bawahnya."
		},
		"pages": [
			{
				"aksara_name": "Da",
				"pair_name": "Gantungan Da",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Da’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Manda’",
				"kata": "‘Manda’",
				"char_image": "res://assets/Aksara/da.png",
				"gantungan_image": "res://assets/Aksara/da (gantungan).png",
				"word_image": "res://assets/Aksara/da (manda).png"
			},
			{
				"aksara_name": "Ta",
				"pair_name": "Gantungan Ta",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Ta’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Kasta’",
				"kata": "‘Kasta’",
				"char_image": "res://assets/Aksara/ta.png",
				"gantungan_image": "res://assets/Aksara/ta (gantungan).png",
				"word_image": "res://assets/Aksara/ta (kasta) .png"
			},
			{
				"aksara_name": "Sa",
				"pair_name": "Gempelan Sa",
				"pair_type": "Wujud Gempelan",
				"highlight": "Gempelan ‘Sa’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Raksa’",
				"kata": "‘Raksa’",
				"char_image": "res://assets/Aksara/sa.png",
				"gantungan_image": "res://assets/Aksara/sa (gempelan).png",
				"word_image": "res://assets/Aksara/sa (raksa).png"
			},
			{
				"aksara_name": "Wa",
				"pair_name": "Gantungan Wa",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Wa’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Satwa’",
				"kata": "‘Satwa’",
				"char_image": "res://assets/Aksara/wa.png",
				"gantungan_image": "res://assets/Aksara/wa (gantungan).png",
				"word_image": "res://assets/Aksara/wa (satwa).png"
			},
			{
				"aksara_name": "La",
				"pair_name": "Gantungan La",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘La’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Amla’",
				"kata": "‘Amla’",
				"char_image": "res://assets/Aksara/la.png",
				"gantungan_image": "res://assets/Aksara/la (gantungan).png",
				"word_image": "res://assets/Aksara/la (amla).png"
			}
		]
	},
	7: {
		"title": "MATERI 7",
		"subtitle": "Kelompok 3 : Gantungan & Gempelan (4 aksara)",
		"type": "gantungan",
		"pages": [
			{
				"aksara_name": "Ma",
				"pair_name": "Gantungan Ma",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Ma’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Padma’",
				"kata": "‘Padma’",
				"char_image": "res://assets/Aksara/ma.png",
				"gantungan_image": "res://assets/Aksara/ma (gantungan) .png",
				"word_image": "res://assets/Aksara/ma (padma).png"
			},
			{
				"aksara_name": "Ga",
				"pair_name": "Gantungan Ga",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Ga’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Kadga’",
				"kata": "‘Kadga’",
				"char_image": "res://assets/Aksara/ga.png",
				"gantungan_image": "res://assets/Aksara/ga (gantungan).png",
				"word_image": "res://assets/Aksara/ga (kadga).png"
			},
			{
				"aksara_name": "Ba",
				"pair_name": "Gantungan Ba",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Ba’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Lamba’",
				"kata": "‘Lamba’",
				"char_image": "res://assets/Aksara/ba.png",
				"gantungan_image": "res://assets/Aksara/ba (gantungan).png",
				"word_image": "res://assets/Aksara/ba (lamba).png"
			},
			{
				"aksara_name": "Nga",
				"pair_name": "Gantungan Nga",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Nga’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Naknga’",
				"kata": "‘Naknga’",
				"char_image": "res://assets/Aksara/nga.png",
				"gantungan_image": "res://assets/Aksara/nga (gantungan).png",
				"word_image": "res://assets/Aksara/nga (naknga) .png"
			}
		]
	},
	8: {
		"title": "MATERI 8",
		"subtitle": "Kelompok 4 : Gantungan & Gempelan (4 aksara)",
		"type": "gantungan",
		"pages": [
			{
				"aksara_name": "Pa",
				"pair_name": "Gempelan Pa",
				"pair_type": "Wujud Gempelan",
				"highlight": "Gempelan ‘Pa’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Nampa’",
				"kata": "‘Nampa’",
				"char_image": "res://assets/Aksara/pa.png",
				"gantungan_image": "res://assets/Aksara/pa (gempelan).png",
				"word_image": "res://assets/Aksara/pa (nampa).png"
			},
			{
				"aksara_name": "Ja",
				"pair_name": "Gantungan Ja",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Ja’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Manja’",
				"kata": "‘Manja’",
				"char_image": "res://assets/Aksara/ja.png",
				"gantungan_image": "res://assets/Aksara/ja (gantungan).png",
				"word_image": "res://assets/Aksara/ja (manja).png"
			},
			{
				"aksara_name": "Ya",
				"pair_name": "Gantungan Ya",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Ya’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Satya’",
				"kata": "‘Satya’",
				"char_image": "res://assets/Aksara/ya.png",
				"gantungan_image": "res://assets/Aksara/ya (gantungan).png",
				"word_image": "res://assets/Aksara/ya (satya).png"
			},
			{
				"aksara_name": "Nya",
				"pair_name": "Gantungan Nya",
				"pair_type": "Wujud Gantungan",
				"highlight": "Gantungan ‘Nya’",
				"prefix": "Wujud : ",
				"keterangan": "Kata sederhana ‘Yadnya’",
				"kata": "‘Yadnya’",
				"char_image": "res://assets/Aksara/nya.png",
				"gantungan_image": "res://assets/Aksara/nya (gantungan).png",
				"word_image": "res://assets/Aksara/nya (yadnya).png"
			}
		]
	}
}

func _ready() -> void:
	# Hide info popup layer initially
	if info_popup_layer:
		info_popup_layer.visible = false
		_is_info_open = false

	# Determine current materi ID from PlayerData autoload
	var pd = _get_player_data()
	if pd and "current_materi_index" in pd and pd.current_materi_index > 0:
		current_materi_id = pd.current_materi_index
	else:
		current_materi_id = 1
	
	# Setup button animations
	_setup_button_effects(btn_top)
	_setup_button_effects(btn_bottom)
	_setup_button_effects(btn_info)
	_setup_button_effects(btn_close_info)
	_setup_button_effects(btn_tutup_info)
	
	btn_top.pressed.connect(_on_btn_top_pressed)
	btn_bottom.pressed.connect(_on_btn_bottom_pressed)
	btn_info.pressed.connect(_on_info_pressed)
	btn_close_info.pressed.connect(_close_info_popup)
	btn_tutup_info.pressed.connect(_close_info_popup)
	
	# Load current materi
	load_materi(current_materi_id)

func load_materi(materi_id: int) -> void:
	_ensure_nodes()
	current_materi_id = materi_id
	if ALL_MATERI_DATA.has(current_materi_id):
		current_materi_data = ALL_MATERI_DATA[current_materi_id]
	else:
		current_materi_data = ALL_MATERI_DATA[1]
	current_page_index = 0
	_render_page()

func _ensure_nodes() -> void:
	if not label_title:
		label_title = get_node_or_null("TitleBoard/LabelTitle")
		label_subtitle = get_node_or_null("TitleBoard/LabelSubtitle")
		label_page = get_node_or_null("SmallBoard/LabelPage")
		btn_info = get_node_or_null("BtnInfo")
		content_container = get_node_or_null("MateriBox/ContentContainer")
		single_char_container = get_node_or_null("MateriBox/ContentContainer/SingleCharContainer")
		aksara_char_image = get_node_or_null("MateriBox/ContentContainer/SingleCharContainer/AksaraCharImage")
		dual_char_container = get_node_or_null("MateriBox/ContentContainer/DualCharContainer")
		label_base_title = get_node_or_null("MateriBox/ContentContainer/DualCharContainer/LeftBox/LabelBaseTitle")
		base_char_image = get_node_or_null("MateriBox/ContentContainer/DualCharContainer/LeftBox/BaseCharImage")
		label_base_name = get_node_or_null("MateriBox/ContentContainer/DualCharContainer/LeftBox/LabelBaseName")
		label_gantungan_title = get_node_or_null("MateriBox/ContentContainer/DualCharContainer/RightBox/LabelGantunganTitle")
		gantungan_char_image = get_node_or_null("MateriBox/ContentContainer/DualCharContainer/RightBox/GantunganCharImage")
		label_gantungan_name = get_node_or_null("MateriBox/ContentContainer/DualCharContainer/RightBox/LabelGantunganName")
		label_dibaca_prefix = get_node_or_null("MateriBox/ContentContainer/DibacaContainer/LabelPrefix")
		label_dibaca_highlight = get_node_or_null("MateriBox/ContentContainer/DibacaContainer/LabelHighlight")
		label_keterangan = get_node_or_null("MateriBox/ContentContainer/LabelKeterangan")
		label_kata = get_node_or_null("MateriBox/ContentContainer/LabelKata")
		aksara_kata_image = get_node_or_null("MateriBox/ContentContainer/AksaraKataImage")
		btn_top = get_node_or_null("BtnTop")
		if btn_top:
			label_top = btn_top.get_node_or_null("LabelTop")
		btn_bottom = get_node_or_null("BtnBottom")
		if btn_bottom:
			label_bottom = btn_bottom.get_node_or_null("LabelBottom")
		info_popup_layer = get_node_or_null("InfoPopupLayer")
		if info_popup_layer:
			info_popup_container = info_popup_layer.get_node_or_null("PopupContainer")
			btn_close_info = get_node_or_null("InfoPopupLayer/PopupContainer/PopupFrame/BtnCloseInfo")
			label_info_title = get_node_or_null("InfoPopupLayer/PopupContainer/PopupFrame/LabelInfoTitle")
			label_info_desc = get_node_or_null("InfoPopupLayer/PopupContainer/PopupFrame/LabelInfoDesc")
			info_image = get_node_or_null("InfoPopupLayer/PopupContainer/PopupFrame/InfoImage")
			label_info_note = get_node_or_null("InfoPopupLayer/PopupContainer/PopupFrame/LabelInfoNote")
			btn_tutup_info = get_node_or_null("InfoPopupLayer/PopupContainer/BtnTutupInfo")

func _setup_button_effects(btn: TextureButton) -> void:
	if not btn:
		return
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
		tween.tween_property(btn, "scale", Vector2(1.03, 1.03), 0.15).set_trans(Tween.TRANS_SINE)
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
	var materi_type: String = current_materi_data.get("type", "wreastra")
	
	# Update Title & Subtitle
	label_title.text = current_materi_data.get("title", "MATERI %d" % current_materi_id)
	label_subtitle.text = current_materi_data.get("subtitle", "")
	
	# Update Page indicator (e.g. 1/5 or 1/4)
	label_page.text = "%d/%d" % [current_page_index + 1, total_pages]
	
	# Show or hide info button based on whether intro data exists
	if current_materi_data.has("intro"):
		btn_info.visible = true
	else:
		btn_info.visible = false
	
	# Render based on Materi Type
	if materi_type == "gantungan":
		single_char_container.visible = false
		dual_char_container.visible = true
		
		# Base character
		var char_img_path = page_data.get("char_image", "")
		if not char_img_path.is_empty() and ResourceLoader.exists(char_img_path):
			base_char_image.texture = load(char_img_path)
		label_base_name.text = "‘%s’" % page_data.get("aksara_name", "")
		
		# Gantungan / Gempelan character
		var gantungan_img_path = page_data.get("gantungan_image", "")
		if not gantungan_img_path.is_empty() and ResourceLoader.exists(gantungan_img_path):
			gantungan_char_image.texture = load(gantungan_img_path)
		label_gantungan_title.text = page_data.get("pair_type", "Wujud Gantungan")
		label_gantungan_name.text = "‘%s’" % page_data.get("pair_name", "")
	else:
		# Single Wreastra Character
		single_char_container.visible = true
		dual_char_container.visible = false
		
		var char_img_path = page_data.get("char_image", "")
		if not char_img_path.is_empty() and ResourceLoader.exists(char_img_path):
			aksara_char_image.texture = load(char_img_path)
	
	# Update Text Info
	label_dibaca_prefix.text = page_data.get("prefix", "Dibaca : ")
	label_dibaca_highlight.text = page_data.get("highlight", "")
	label_keterangan.text = page_data.get("keterangan", "kata sederhana (2 suku kata)")
	label_kata.text = page_data.get("kata", "")
	
	# Update Aksara word image
	var word_img_path = page_data.get("word_image", "")
	if not word_img_path.is_empty() and ResourceLoader.exists(word_img_path):
		aksara_kata_image.texture = load(word_img_path)
		aksara_kata_image.visible = true
	else:
		aksara_kata_image.visible = false
	
	# Update Button States & Labels
	_update_buttons(total_pages)

func _get_player_data() -> Node:
	var root_node = null
	if is_inside_tree() and get_tree() and get_tree().root:
		root_node = get_tree().root
	else:
		var tree = Engine.get_main_loop() as SceneTree
		if tree and tree.root:
			root_node = tree.root
			
	if root_node:
		var pd_node = root_node.get_node_or_null("PlayerData")
		if pd_node:
			return pd_node
		for child in root_node.get_children():
			if str(child.name) == "PlayerData":
				return child
		for child in root_node.get_children():
			if "from_latihan_retry" in child and child != self:
				return child
	return get_node_or_null("/root/PlayerData")

func _update_buttons(total_pages: int) -> void:
	_ensure_nodes()
	var pd = _get_player_data()
	var is_from_latihan = false
	var is_gameplay = false
	if pd != null:
		if "from_latihan_retry" in pd:
			is_from_latihan = bool(pd.from_latihan_retry)
		if "is_gameplay_mode" in pd:
			is_gameplay = bool(pd.is_gameplay_mode)

	if not label_top or not label_bottom:
		return

	if current_page_index == 0:
		# Page 1
		label_top.text = "Lanjut"
		label_top.label_settings.font_size = 64
		
		label_bottom.text = "Kembali"
		label_bottom.label_settings.font_size = 64
	elif current_page_index >= total_pages - 1:
		# Last Page
		if is_from_latihan:
			label_top.text = "Jawab Lagi"
			label_top.label_settings.font_size = 56
		elif is_gameplay:
			label_top.text = "Coba Latihan"
			label_top.label_settings.font_size = 52
		else:
			label_top.text = "Kembali"
			label_top.label_settings.font_size = 64
		
		label_bottom.text = "Materi sebelumnya"
		label_bottom.label_settings.font_size = 42
	else:
		# Middle Pages (e.g. 2, 3, 4)
		label_top.text = "Lanjut"
		label_top.label_settings.font_size = 64
		
		label_bottom.text = "Materi sebelumnya"
		label_bottom.label_settings.font_size = 42

func _on_btn_top_pressed() -> void:
	var pages: Array = current_materi_data.get("pages", [])
	var total_pages: int = pages.size()
	
	if current_page_index >= total_pages - 1:
		# Last page
		var pd = _get_player_data()
		if pd and "from_latihan_retry" in pd and pd.from_latihan_retry:
			print("Kembali ke IsiLatihan (Jawab Lagi)...")
			get_tree().change_scene_to_file("res://scenes/IsiLatihan.tscn")
		elif pd and "is_gameplay_mode" in pd and pd.is_gameplay_mode:
			print("Memulai Latihan dari Materi (Coba Latihan)...")
			pd.set_current_latihan(current_materi_id)
			pd.from_latihan_retry = false
			pd.latihan_return_question_idx = 0
			get_tree().change_scene_to_file("res://scenes/IsiLatihan.tscn")
		else:
			_go_back_to_materi()
	else:
		# Next page
		current_page_index += 1
		_animate_page_transition()

func _on_btn_bottom_pressed() -> void:
	if current_page_index == 0:
		# Page 1: Bottom button functions as "Kembali"
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
	var pd = _get_player_data()
	if pd and "is_gameplay_mode" in pd and pd.is_gameplay_mode:
		if "from_latihan_retry" in pd and pd.from_latihan_retry:
			get_tree().change_scene_to_file("res://scenes/IsiLatihan.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/Gameplay.tscn")
	else:
		print("Kembali ke daftar Materi...")
		get_tree().change_scene_to_file("res://scenes/Materi.tscn")

# ==========================================
# INFO / PEMBUKAAN POPUP LOGIC
# ==========================================

func _on_info_pressed() -> void:
	if not current_materi_data.has("intro"):
		return
	
	var intro: Dictionary = current_materi_data["intro"]
	label_info_title.text = intro.get("title", "CARA PENGGUNAAN")
	label_info_desc.text = intro.get("description", "")
	label_info_note.text = intro.get("note", "")
	
	var intro_img = intro.get("image", "")
	if not intro_img.is_empty() and ResourceLoader.exists(intro_img):
		info_image.texture = load(intro_img)
		info_image.visible = true
	else:
		info_image.visible = false
	
	_is_info_open = true
	info_popup_layer.visible = true
	info_popup_layer.modulate.a = 0.0
	info_popup_container.scale = Vector2(0.7, 0.7)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(info_popup_layer, "modulate:a", 1.0, 0.22)
	tween.tween_property(info_popup_container, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _close_info_popup() -> void:
	_is_info_open = false
	var tween = create_tween().set_parallel(true)
	tween.tween_property(info_popup_layer, "modulate:a", 0.0, 0.18)
	tween.tween_property(info_popup_container, "scale", Vector2(0.75, 0.75), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func():
		if not _is_info_open:
			info_popup_layer.visible = false
	)
