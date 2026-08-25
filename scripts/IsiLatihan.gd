extends Control

# Header Nodes
@onready var label_title: Label = $TitleBoard/LabelTitle
@onready var label_subtitle: Label = $TitleBoard/LabelSubtitle
@onready var label_question_number: Label = $HeaderBar/QuestionBoard/LabelQuestionNumber
@onready var label_timer: Label = $HeaderBar/TimerBoard/LabelTimer

# Choice Question Nodes
@onready var choice_container: Control = $ChoiceContainer
@onready var label_prompt_header: Label = $ChoiceContainer/MateriBox/ContentVBox/LabelPromptHeader
@onready var label_prompt_sub: Label = $ChoiceContainer/MateriBox/ContentVBox/LabelPromptSub
@onready var sound_section: HBoxContainer = $ChoiceContainer/MateriBox/ContentVBox/SoundSection
@onready var btn_play_sound: TextureButton = $ChoiceContainer/MateriBox/ContentVBox/SoundSection/BtnPlaySound
@onready var prompt_kata_label: Label = $ChoiceContainer/MateriBox/ContentVBox/PromptKataLabel
@onready var prompt_image: TextureRect = $ChoiceContainer/MateriBox/ContentVBox/PromptImage
@onready var label_question_text: Label = $ChoiceContainer/MateriBox/ContentVBox/LabelQuestionText
@onready var options_container: VBoxContainer = $ChoiceContainer/MateriBox/ContentVBox/OptionsContainer
@onready var btn_option1: TextureButton = $ChoiceContainer/MateriBox/ContentVBox/OptionsContainer/BtnOption1
@onready var btn_option2: TextureButton = $ChoiceContainer/MateriBox/ContentVBox/OptionsContainer/BtnOption2
@onready var btn_option3: TextureButton = $ChoiceContainer/MateriBox/ContentVBox/OptionsContainer/BtnOption3
@onready var btn_periksa_choice: TextureButton = $ChoiceContainer/BtnPeriksaChoice

# Drawing Question Nodes
@onready var drawing_container: Control = $DrawingContainer
@onready var label_instruction: Label = $DrawingContainer/InstructionBoard/LabelInstruction
@onready var drawing_area: Control = $DrawingContainer/DrawingBoard/DrawingArea
@onready var ghost_aksara: TextureRect = $DrawingContainer/DrawingBoard/DrawingArea/GhostAksara
@onready var btn_clue: TextureButton = $DrawingContainer/DrawingBoard/BtnClue
@onready var btn_hapus: TextureButton = $DrawingContainer/BtnHapus
@onready var btn_periksa_draw: TextureButton = $DrawingContainer/BtnPeriksaDraw

# Wrong Popup Layer Nodes
@onready var wrong_popup_layer: Control = $WrongPopupLayer
@onready var wrong_popup_container: Control = $WrongPopupLayer/PopupContainer
@onready var label_wrong_message: Label = $WrongPopupLayer/PopupContainer/LabelWrongMessage
@onready var btn_jawab_lagi: TextureButton = $WrongPopupLayer/PopupContainer/BtnJawabLagi
@onready var btn_lihat_materi: TextureButton = $WrongPopupLayer/PopupContainer/BtnLihatMateri

# Complete Popup Layer Nodes
@onready var complete_popup_layer: Control = $CompletePopupLayer
@onready var complete_popup_container: Control = $CompletePopupLayer/PopupContainer
@onready var btn_ulangi: TextureButton = $CompletePopupLayer/PopupContainer/BtnUlangi
@onready var btn_kembali_menu: TextureButton = $CompletePopupLayer/PopupContainer/BtnKembaliMenu

# State
var current_latihan_id: int = 1
var current_question_index: int = 0
var current_latihan_data: Dictionary = {}
var selected_option_index: int = -1
var question_fail_count: int = 0
var sound_play_count: int = 0
var is_clue_active: bool = false
var time_remaining_seconds: int = 95 # 1:35 default

# Drawing State
var drawing_lines: Array[PackedVector2Array] = []
var is_currently_drawing: bool = false

# Timer
var _timer_node: Timer = null

# Bank Soal Latihan 1 - 8 (From PDF)
const ALL_LATIHAN_DATA = {
	1: {
		"title": "LATIHAN 1",
		"subtitle": "Kelompok 1 : Aksara Wreastra (5 aksara)",
		"materi_id": 1,
		"questions": [
			{
				"type": "choice",
				"prompt_header": "Perhatikan bentuk aksara berikut:",
				"prompt_image": "res://assets/Aksara/na.png",
				"question": "Manakah pembacaan latin yang tepat untuk aksara di atas?",
				"options": [{"text": "A. Ka"}, {"text": "B. Ca"}, {"text": "C. Na"}],
				"correct": 2
			},
			{
				"type": "choice",
				"prompt_header": "Pilihlah aksara yang tepat:",
				"question": "Manakah tulisan Aksara Bali yang tepat untuk bunyi 'Ka'?",
				"options": [{"image": "res://assets/Aksara/na.png"}, {"image": "res://assets/Aksara/ra.png"}, {"image": "res://assets/Aksara/ka.png"}],
				"correct": 2
			},
			{
				"type": "choice",
				"prompt_header": "Bacalah gabungan dua aksara berikut:",
				"prompt_image": "res://assets/Aksara/ka (Ra-Ka).png",
				"question": "Manakah pembacaan kata yang tepat?",
				"options": [{"text": "A. Cara"}, {"text": "B. Hana"}, {"text": "C. Raka"}],
				"correct": 2
			},
			{
				"type": "sound",
				"sound_name": "Ha",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/na.png"}, {"image": "res://assets/Aksara/a,ha.png"}, {"image": "res://assets/Aksara/ra.png"}],
				"correct": 1
			},
			{
				"type": "sound",
				"sound_name": "Ra",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ra.png"}, {"image": "res://assets/Aksara/ka.png"}, {"image": "res://assets/Aksara/ca.png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Cara",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ca (Ca-Ca).png"}, {"image": "res://assets/Aksara/ra (Ca-Ra).png"}, {"image": "res://assets/Aksara/na (Ha-Na).png"}],
				"correct": 1
			},
			{
				"type": "draw",
				"instruction": "Ayo, coba tulis aksara Ca",
				"target_image": "res://assets/Aksara/ca.png"
			}
		]
	},
	2: {
		"title": "LATIHAN 2",
		"subtitle": "Kelompok 2 : Aksara Wreastra (5 aksara)",
		"materi_id": 2,
		"questions": [
			{
				"type": "choice",
				"prompt_header": "Perhatikan bentuk aksara Bali berikut:",
				"prompt_image": "res://assets/Aksara/ta.png",
				"question": "Manakah pembacaan Latin yang tepat untuk aksara di atas?",
				"options": [{"text": "A. Sa"}, {"text": "B. Ta"}, {"text": "C. Wa"}],
				"correct": 1
			},
			{
				"type": "choice",
				"prompt_header": "Pilihlah bentuk aksara yang tepat:",
				"question": "Manakah bentuk Aksara Bali yang tepat untuk bunyi Latin 'La'?",
				"options": [{"image": "res://assets/Aksara/la.png"}, {"image": "res://assets/Aksara/ta.png"}, {"image": "res://assets/Aksara/da.png"}],
				"correct": 0
			},
			{
				"type": "choice",
				"prompt_header": "Pilihlah tulisan aksara kata:",
				"question": "Manakah penulisan Aksara Bali yang tepat untuk kata 'Wala'?",
				"options": [{"image": "res://assets/Aksara/PaLa.png"}, {"image": "res://assets/Aksara/DaTa.png"}, {"image": "res://assets/Aksara/WaLa.png"}],
				"correct": 2
			},
			{
				"type": "sound",
				"sound_name": "Da",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/na.png"}, {"image": "res://assets/Aksara/da.png"}, {"image": "res://assets/Aksara/ra.png"}],
				"correct": 1
			},
			{
				"type": "sound",
				"sound_name": "Wa",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/na.png"}, {"image": "res://assets/Aksara/da.png"}, {"image": "res://assets/Aksara/wa.png"}],
				"correct": 2
			},
			{
				"type": "sound",
				"sound_name": "Rasa",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/RaSa.png"}, {"image": "res://assets/Aksara/DaDa.png"}, {"image": "res://assets/Aksara/SaTa.png"}],
				"correct": 0
			},
			{
				"type": "draw",
				"instruction": "Ayo, coba tulis aksara La",
				"target_image": "res://assets/Aksara/la.png"
			}
		]
	},
	3: {
		"title": "LATIHAN 3",
		"subtitle": "Kelompok 3 : Aksara Wreastra (4 aksara)",
		"materi_id": 3,
		"questions": [
			{
				"type": "choice",
				"prompt_header": "Perhatikan bentuk aksara Bali berikut:",
				"prompt_image": "res://assets/Aksara/ga.png",
				"question": "Manakah pembacaan Latin yang tepat untuk aksara di atas?",
				"options": [{"text": "A. Ma"}, {"text": "B. Ga"}, {"text": "C. Nga"}],
				"correct": 1
			},
			{
				"type": "choice",
				"prompt_header": "Pilihlah bentuk aksara yang tepat:",
				"question": "Manakah bentuk Aksara Bali yang tepat untuk bunyi Latin 'Ba'?",
				"options": [{"image": "res://assets/Aksara/ga.png"}, {"image": "res://assets/Aksara/nga.png"}, {"image": "res://assets/Aksara/ba.png"}],
				"correct": 2
			},
			{
				"type": "choice",
				"prompt_header": "Mari gabungkan aksara dari Kelompok 1 dan Kelompok 3.",
				"prompt_image": "res://assets/Aksara/NaGa.png",
				"question": "Manakah pembacaan Latin yang tepat?",
				"options": [{"text": "A. Naga"}, {"text": "B. Nana"}, {"text": "C. Nama"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Ma",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ma.png"}, {"image": "res://assets/Aksara/da.png"}, {"image": "res://assets/Aksara/la.png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Nga",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/nga.png"}, {"image": "res://assets/Aksara/da.png"}, {"image": "res://assets/Aksara/wa.png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Gama",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/RaSa.png"}, {"image": "res://assets/Aksara/GaMa.png"}, {"image": "res://assets/Aksara/SaTa.png"}],
				"correct": 1
			},
			{
				"type": "draw",
				"instruction": "Ayo, coba tulis aksara Nga",
				"target_image": "res://assets/Aksara/nga.png"
			}
		]
	},
	4: {
		"title": "LATIHAN 4",
		"subtitle": "Kelompok 4 : Aksara Wreastra (4 aksara)",
		"materi_id": 4,
		"questions": [
			{
				"type": "choice",
				"prompt_header": "Perhatikan bentuk aksara Bali berikut:",
				"prompt_image": "res://assets/Aksara/pa.png",
				"question": "Manakah pembacaan Latin yang tepat untuk aksara di atas?",
				"options": [{"text": "A. Pa"}, {"text": "B. Nya"}, {"text": "C. Ya"}],
				"correct": 0
			},
			{
				"type": "choice",
				"prompt_header": "Pilihlah bentuk aksara yang tepat:",
				"question": "Manakah bentuk Aksara Bali yang tepat untuk bunyi Latin 'Nya'?",
				"options": [{"image": "res://assets/Aksara/na.png"}, {"image": "res://assets/Aksara/nya.png"}, {"image": "res://assets/Aksara/ya.png"}],
				"correct": 1
			},
			{
				"type": "choice",
				"prompt_header": "Pilihlah penulisan aksara yang tepat:",
				"question": "Manakah penulisan Aksara Bali yang tepat untuk kata 'Jaya'?",
				"options": [{"image": "res://assets/Aksara/JaPa.png"}, {"image": "res://assets/Aksara/JaYa.png"}, {"image": "res://assets/Aksara/RaWa.png"}],
				"correct": 1
			},
			{
				"type": "sound",
				"sound_name": "Ya",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ya.png"}, {"image": "res://assets/Aksara/da.png"}, {"image": "res://assets/Aksara/la.png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Pasa",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ba (Ba-La).png"}, {"image": "res://assets/Aksara/RaSa.png"}, {"image": "res://assets/Aksara/PaSa.png"}],
				"correct": 2
			},
			{
				"type": "sound",
				"sound_name": "JaBa",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/JaBa.png"}, {"image": "res://assets/Aksara/RaMa.png"}, {"image": "res://assets/Aksara/RaGa.png"}],
				"correct": 0
			},
			{
				"type": "draw",
				"instruction": "Ayo, coba tulis aksara Ja",
				"target_image": "res://assets/Aksara/ja.png"
			}
		]
	},
	5: {
		"title": "LATIHAN 5",
		"subtitle": "Kelompok 1 : Gantungan & Gempelan (5 aksara)",
		"materi_id": 5,
		"questions": [
			{
				"type": "choice",
				"prompt_header": "Perhatikan bentuk berikut:",
				"prompt_image": "res://assets/Aksara/na (gantungan).png",
				"question": "Bentuk visual tersebut merupakan gantungan untuk aksara apa?:",
				"options": [{"text": "A. Aksara Pa"}, {"text": "B. Aksara Ca"}, {"text": "C. Aksara Na"}],
				"correct": 2
			},
			{
				"type": "choice",
				"prompt_header": "Bentuk gantungan/pasangan untuk aksara Ra:",
				"question": "Manakah simbol gantungan yang benar?",
				"options": [{"image": "res://assets/Aksara/na (gantungan).png"}, {"image": "res://assets/Aksara/ra (gantungan).png"}, {"image": "res://assets/Aksara/ka (gantungan).png"}],
				"correct": 1
			},
			{
				"type": "choice",
				"prompt_header": "Urutan simbol gantungan secara berurutan untuk deret Ha - Na - Ca:",
				"question": "Manakah urutan simbol gantungan yang benar?",
				"options": [{"image": "res://assets/Aksara/hanaca.pmg.png"}, {"image": "res://assets/Aksara/hakana.png"}, {"image": "res://assets/Aksara/rakada.png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Gantungan Ka",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ka (gantungan).png"}, {"image": "res://assets/Aksara/na (gantungan).png"}, {"image": "res://assets/Aksara/a, ha (gantungan).png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Gantungan Na",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ra (gantungan).png"}, {"image": "res://assets/Aksara/ca (gantungan).png"}, {"image": "res://assets/Aksara/na (gantungan).png"}],
				"correct": 2
			},
			{
				"type": "sound",
				"sound_name": "Cakra",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ra (cakra).png"}, {"image": "res://assets/Aksara/ka (paska).png"}, {"image": "res://assets/Aksara/na (Ratna).png"}],
				"correct": 0
			},
			{
				"type": "draw",
				"instruction": "Ayo, coba tulis Gantungan Ra",
				"target_image": "res://assets/Aksara/ra (gantungan).png"
			}
		]
	},
	6: {
		"title": "LATIHAN 6",
		"subtitle": "Kelompok 2 : Gantungan & Gempelan (5 aksara)",
		"materi_id": 6,
		"questions": [
			{
				"type": "choice",
				"prompt_header": "Perhatikan bentuk berikut:",
				"prompt_image": "res://assets/Aksara/da (gantungan).png",
				"question": "Bentuk visual tersebut merupakan gantungan untuk aksara apa?:",
				"options": [{"text": "A. Aksara Pa"}, {"text": "B. Aksara Ma"}, {"text": "C. Aksara Da"}],
				"correct": 2
			},
			{
				"type": "choice",
				"prompt_header": "Pilihlah bentuk gempelan yang tepat:",
				"question": "Manakah di antara pilihan berikut yang merupakan bentuk Gempelan dari aksara Sa?",
				"options": [{"image": "res://assets/Aksara/sa (gempelan).png"}, {"image": "res://assets/Aksara/wa (gantungan).png"}, {"image": "res://assets/Aksara/ma (gantungan) .png"}],
				"correct": 0
			},
			{
				"type": "choice",
				"prompt_header": "Urutan yang benar secara berurutan untuk deret Da - Ta - Sa:",
				"question": "Manakah urutan simbol yang benar?",
				"options": [{"image": "res://assets/Aksara/datasa.png"}, {"image": "res://assets/Aksara/sawala.png"}, {"image": "res://assets/Aksara/walasa.png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Gantungan Wa",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/wa (gantungan).png"}, {"image": "res://assets/Aksara/la (gantungan).png"}, {"image": "res://assets/Aksara/da (gantungan).png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Gantungan La",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/la (gantungan).png"}, {"image": "res://assets/Aksara/ca (gantungan).png"}, {"image": "res://assets/Aksara/sa (gempelan).png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Satwa",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/wa (satwa).png"}, {"image": "res://assets/Aksara/la (amla).png"}, {"image": "res://assets/Aksara/ta (kasta) .png"}],
				"correct": 0
			},
			{
				"type": "draw",
				"instruction": "Ayo, coba tulis Gantungan Da",
				"target_image": "res://assets/Aksara/da (gantungan).png"
			}
		]
	},
	7: {
		"title": "LATIHAN 7",
		"subtitle": "Kelompok 3 : Gantungan & Gempelan (4 aksara)",
		"materi_id": 7,
		"questions": [
			{
				"type": "choice",
				"prompt_header": "Perhatikan bentuk berikut:",
				"prompt_image": "res://assets/Aksara/ma (gantungan) .png",
				"question": "Bentuk visual tersebut merupakan gantungan untuk aksara apa?:",
				"options": [{"text": "A. Aksara La"}, {"text": "B. Aksara Ma"}, {"text": "C. Aksara Ga"}],
				"correct": 1
			},
			{
				"type": "choice",
				"prompt_header": "Pilihlah bentuk gantungan yang tepat:",
				"question": "Manakah di antara pilihan berikut yang merupakan bentuk gantungan dari aksara Ba?",
				"options": [{"image": "res://assets/Aksara/ba (gantungan).png"}, {"image": "res://assets/Aksara/na (gantungan).png"}, {"image": "res://assets/Aksara/ga (gantungan).png"}],
				"correct": 0
			},
			{
				"type": "choice",
				"prompt_header": "Pasangan gantungan untuk deret Ba - Nga secara berurutan:",
				"question": "Manakah pasangan gantungan yang tepat?",
				"options": [{"image": "res://assets/Aksara/ba-nga.png"}, {"image": "res://assets/Aksara/GaMa.png"}, {"image": "res://assets/Aksara/bama.png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Gantungan Ga",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ga (gantungan).png"}, {"image": "res://assets/Aksara/wa (gantungan).png"}, {"image": "res://assets/Aksara/nga (gantungan).png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Gantungan Nga",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ba (gantungan).png"}, {"image": "res://assets/Aksara/ra (gantungan).png"}, {"image": "res://assets/Aksara/nga (gantungan).png"}],
				"correct": 2
			},
			{
				"type": "sound",
				"sound_name": "Padma",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/nga (naknga) .png"}, {"image": "res://assets/Aksara/ba (lamba).png"}, {"image": "res://assets/Aksara/ma (padma).png"}],
				"correct": 2
			},
			{
				"type": "draw",
				"instruction": "Ayo, coba tulis Gantungan Ma",
				"target_image": "res://assets/Aksara/ma (gantungan) .png"
			}
		]
	},
	8: {
		"title": "LATIHAN 8",
		"subtitle": "Kelompok 4 : Gantungan & Gempelan (4 aksara)",
		"materi_id": 8,
		"questions": [
			{
				"type": "choice",
				"prompt_header": "Bentuk gantungan dari aksara Ya:",
				"question": "Manakah di antara pilihan berikut yang merupakan bentuk gantungan dari aksara Ya?",
				"options": [{"image": "res://assets/Aksara/nya (gantungan).png"}, {"image": "res://assets/Aksara/pa (gempelan).png"}, {"image": "res://assets/Aksara/ya (gantungan).png"}],
				"correct": 2
			},
			{
				"type": "choice",
				"prompt_header": "Perhatikan bentuk aksara berikut:",
				"prompt_image": "res://assets/Aksara/ja (gantungan).png",
				"question": "Simbol tersebut merupakan gantungan untuk aksara apa?",
				"options": [{"text": "A. Gantungan Da"}, {"text": "B. Gantungan Ga"}, {"text": "C. Gantungan Ja"}],
				"correct": 2
			},
			{
				"type": "choice",
				"prompt_header": "Pilihlah penulisan aksara kata:",
				"question": "Manakah penulisan Aksara Bali yang tepat untuk kata 'Manja'?",
				"options": [{"image": "res://assets/Aksara/ja (manja).png"}, {"image": "res://assets/Aksara/ya (satya).png"}, {"image": "res://assets/Aksara/ga (kadga).png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Gempelan Pa",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ga (gantungan).png"}, {"image": "res://assets/Aksara/wa (gantungan).png"}, {"image": "res://assets/Aksara/pa (gempelan).png"}],
				"correct": 2
			},
			{
				"type": "sound",
				"sound_name": "Gantungan Nya",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/nya (gantungan).png"}, {"image": "res://assets/Aksara/la (gantungan).png"}, {"image": "res://assets/Aksara/ba (gantungan).png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Nampa",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/da (manda).png"}, {"image": "res://assets/Aksara/pa (nampa).png"}, {"image": "res://assets/Aksara/nya (yadnya).png"}],
				"correct": 1
			},
			{
				"type": "draw",
				"instruction": "Ayo, coba tulis Gempelan Pa",
				"target_image": "res://assets/Aksara/pa (gempelan).png"
			}
		]
	}
}

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

func _ensure_nodes() -> void:
	if not label_title:
		label_title = get_node_or_null("TitleBoard/LabelTitle")
	if not label_subtitle:
		label_subtitle = get_node_or_null("TitleBoard/LabelSubtitle")
	if not label_question_number:
		label_question_number = get_node_or_null("HeaderBar/QuestionBoard/LabelQuestionNumber")
	if not label_timer:
		label_timer = get_node_or_null("HeaderBar/TimerBoard/LabelTimer")
		
	if not choice_container:
		choice_container = get_node_or_null("ChoiceContainer")
	if not label_prompt_header:
		label_prompt_header = get_node_or_null("ChoiceContainer/MateriBox/ContentVBox/LabelPromptHeader")
	if not label_prompt_sub:
		label_prompt_sub = get_node_or_null("ChoiceContainer/MateriBox/ContentVBox/LabelPromptSub")
	if not sound_section:
		sound_section = get_node_or_null("ChoiceContainer/MateriBox/ContentVBox/SoundSection")
	if not btn_play_sound:
		btn_play_sound = get_node_or_null("ChoiceContainer/MateriBox/ContentVBox/SoundSection/BtnPlaySound")
	if not prompt_kata_label:
		prompt_kata_label = get_node_or_null("ChoiceContainer/MateriBox/ContentVBox/PromptKataLabel")
	if not prompt_image:
		prompt_image = get_node_or_null("ChoiceContainer/MateriBox/ContentVBox/PromptImage")
	if not label_question_text:
		label_question_text = get_node_or_null("ChoiceContainer/MateriBox/ContentVBox/LabelQuestionText")
	if not options_container:
		options_container = get_node_or_null("ChoiceContainer/MateriBox/ContentVBox/OptionsContainer")
	if not btn_option1:
		btn_option1 = get_node_or_null("ChoiceContainer/MateriBox/ContentVBox/OptionsContainer/BtnOption1")
	if not btn_option2:
		btn_option2 = get_node_or_null("ChoiceContainer/MateriBox/ContentVBox/OptionsContainer/BtnOption2")
	if not btn_option3:
		btn_option3 = get_node_or_null("ChoiceContainer/MateriBox/ContentVBox/OptionsContainer/BtnOption3")
	if not btn_periksa_choice:
		btn_periksa_choice = get_node_or_null("ChoiceContainer/BtnPeriksaChoice")
		
	if not drawing_container:
		drawing_container = get_node_or_null("DrawingContainer")
	if not label_instruction:
		label_instruction = get_node_or_null("DrawingContainer/InstructionBoard/LabelInstruction")
	if not drawing_area:
		drawing_area = get_node_or_null("DrawingContainer/DrawingBoard/DrawingArea")
	if not ghost_aksara:
		ghost_aksara = get_node_or_null("DrawingContainer/DrawingBoard/DrawingArea/GhostAksara")
	if not btn_clue:
		btn_clue = get_node_or_null("DrawingContainer/DrawingBoard/BtnClue")
	if not btn_hapus:
		btn_hapus = get_node_or_null("DrawingContainer/BtnHapus")
	if not btn_periksa_draw:
		btn_periksa_draw = get_node_or_null("DrawingContainer/BtnPeriksaDraw")
		
	if not wrong_popup_layer:
		wrong_popup_layer = get_node_or_null("WrongPopupLayer")
	if not wrong_popup_container:
		wrong_popup_container = get_node_or_null("WrongPopupLayer/PopupContainer")
	if not label_wrong_message:
		label_wrong_message = get_node_or_null("WrongPopupLayer/PopupContainer/LabelWrongMessage")
	if not btn_jawab_lagi:
		btn_jawab_lagi = get_node_or_null("WrongPopupLayer/PopupContainer/BtnJawabLagi")
	if not btn_lihat_materi:
		btn_lihat_materi = get_node_or_null("WrongPopupLayer/PopupContainer/BtnLihatMateri")
		
	if not complete_popup_layer:
		complete_popup_layer = get_node_or_null("CompletePopupLayer")
	if not complete_popup_container:
		complete_popup_container = get_node_or_null("CompletePopupLayer/PopupContainer")
	if not btn_ulangi:
		btn_ulangi = get_node_or_null("CompletePopupLayer/PopupContainer/BtnUlangi")
	if not btn_kembali_menu:
		btn_kembali_menu = get_node_or_null("CompletePopupLayer/PopupContainer/BtnKembaliMenu")

func _ready() -> void:
	_ensure_nodes()
	
	# Determine current latihan ID from PlayerData
	var pd = _get_player_data()
	if pd and "current_latihan_index" in pd and pd.current_latihan_index > 0:
		current_latihan_id = pd.current_latihan_index
	else:
		current_latihan_id = 1
		
	var start_q = 0
	if pd and "from_latihan_retry" in pd and pd.from_latihan_retry:
		start_q = pd.latihan_return_question_idx
		pd.from_latihan_retry = false
	
	# Setup button animations
	_setup_button_effects(btn_periksa_choice)
	_setup_button_effects(btn_play_sound)
	_setup_button_effects(btn_option1)
	_setup_button_effects(btn_option2)
	_setup_button_effects(btn_option3)
	_setup_button_effects(btn_clue)
	_setup_button_effects(btn_hapus)
	_setup_button_effects(btn_periksa_draw)
	_setup_button_effects(btn_jawab_lagi)
	_setup_button_effects(btn_lihat_materi)
	_setup_button_effects(btn_ulangi)
	_setup_button_effects(btn_kembali_menu)
	
	# Connect signals safely
	if btn_periksa_choice and not btn_periksa_choice.pressed.is_connected(_on_periksa_choice_pressed):
		btn_periksa_choice.pressed.connect(_on_periksa_choice_pressed)
	if btn_play_sound and not btn_play_sound.pressed.is_connected(_on_play_sound_pressed):
		btn_play_sound.pressed.connect(_on_play_sound_pressed)
	if btn_option1 and not btn_option1.pressed.is_connected(func(): _select_option(0)):
		btn_option1.pressed.connect(func(): _select_option(0))
	if btn_option2 and not btn_option2.pressed.is_connected(func(): _select_option(1)):
		btn_option2.pressed.connect(func(): _select_option(1))
	if btn_option3 and not btn_option3.pressed.is_connected(func(): _select_option(2)):
		btn_option3.pressed.connect(func(): _select_option(2))
	if btn_clue and not btn_clue.pressed.is_connected(_on_clue_pressed):
		btn_clue.pressed.connect(_on_clue_pressed)
	if btn_hapus and not btn_hapus.pressed.is_connected(_on_hapus_draw_pressed):
		btn_hapus.pressed.connect(_on_hapus_draw_pressed)
	if btn_periksa_draw and not btn_periksa_draw.pressed.is_connected(_on_periksa_draw_pressed):
		btn_periksa_draw.pressed.connect(_on_periksa_draw_pressed)
	if btn_jawab_lagi and not btn_jawab_lagi.pressed.is_connected(_close_wrong_popup):
		btn_jawab_lagi.pressed.connect(_close_wrong_popup)
	if btn_lihat_materi and not btn_lihat_materi.pressed.is_connected(_on_lihat_materi_pressed):
		btn_lihat_materi.pressed.connect(_on_lihat_materi_pressed)
	if btn_ulangi and not btn_ulangi.pressed.is_connected(_on_ulangi_pressed):
		btn_ulangi.pressed.connect(_on_ulangi_pressed)
	if btn_kembali_menu and not btn_kembali_menu.pressed.is_connected(_on_kembali_menu_pressed):
		btn_kembali_menu.pressed.connect(_on_kembali_menu_pressed)
	
	# Setup Drawing Area input and draw hooks
	if drawing_area:
		if not drawing_area.gui_input.is_connected(_on_drawing_area_gui_input):
			drawing_area.gui_input.connect(_on_drawing_area_gui_input)
		if not drawing_area.draw.is_connected(_on_drawing_area_draw):
			drawing_area.draw.connect(_on_drawing_area_draw)
	
	# Start countdown timer
	_setup_timer()
	
	# Hide popups initially
	if wrong_popup_layer:
		wrong_popup_layer.visible = false
	if complete_popup_layer:
		complete_popup_layer.visible = false
	
	# Load latihan
	load_latihan(current_latihan_id, start_q)

func _setup_timer() -> void:
	if _timer_node:
		_timer_node.queue_free()
	_timer_node = Timer.new()
	_timer_node.wait_time = 1.0
	_timer_node.autostart = true
	_timer_node.timeout.connect(_on_timer_tick)
	add_child(_timer_node)
	_update_timer_display()

func _on_timer_tick() -> void:
	if time_remaining_seconds > 0:
		time_remaining_seconds -= 1
		_update_timer_display()

func _update_timer_display() -> void:
	var mins = time_remaining_seconds / 60
	var secs = time_remaining_seconds % 60
	if label_timer:
		label_timer.text = "Waktu %d:%02d" % [mins, secs]

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

func load_latihan(latihan_id: int, start_q_idx: int = 0) -> void:
	_ensure_nodes()
	current_latihan_id = latihan_id
	if ALL_LATIHAN_DATA.has(current_latihan_id):
		current_latihan_data = ALL_LATIHAN_DATA[current_latihan_id]
	else:
		current_latihan_data = ALL_LATIHAN_DATA[1]
	
	var questions: Array = current_latihan_data.get("questions", [])
	if start_q_idx >= 0 and start_q_idx < questions.size():
		current_question_index = start_q_idx
	else:
		current_question_index = 0
		
	question_fail_count = 0
	_render_question()

func _render_question() -> void:
	var questions: Array = current_latihan_data.get("questions", [])
	var total_questions: int = questions.size()
	if total_questions == 0:
		return
		
	if current_question_index >= total_questions:
		_show_complete_popup()
		return
		
	var q_data: Dictionary = questions[current_question_index]
	var q_type: String = q_data.get("type", "choice")
	
	# Update Titles
	label_title.text = current_latihan_data.get("title", "LATIHAN %d" % current_latihan_id)
	label_subtitle.text = current_latihan_data.get("subtitle", "")
	label_question_number.text = "%d/%d" % [current_question_index + 1, total_questions]
	
	# Reset states
	selected_option_index = -1
	sound_play_count = 0
	is_clue_active = false
	drawing_lines.clear()
	if drawing_area:
		drawing_area.queue_redraw()
	
	if q_type == "draw":
		choice_container.visible = false
		drawing_container.visible = true
		
		label_instruction.text = q_data.get("instruction", "Ayo, coba tulis aksara...")
		var target_img = q_data.get("target_image", "")
		if not target_img.is_empty() and ResourceLoader.exists(target_img):
			ghost_aksara.texture = load(target_img)
		ghost_aksara.modulate.a = 0.0 # Hidden until clue clicked
	else:
		choice_container.visible = true
		drawing_container.visible = false
		
		# Headers
		var p_header = q_data.get("prompt_header", "")
		var p_sub = q_data.get("prompt_sub", "")
		var p_kata = q_data.get("prompt_kata", "")
		var p_img = q_data.get("prompt_image", "")
		var q_text = q_data.get("question", "")
		
		if p_header.is_empty():
			label_prompt_header.visible = false
		else:
			label_prompt_header.visible = true
			label_prompt_header.text = p_header
			
		if p_sub.is_empty():
			label_prompt_sub.visible = false
		else:
			label_prompt_sub.visible = true
			label_prompt_sub.text = p_sub
		
		if q_type == "sound":
			sound_section.visible = true
		else:
			sound_section.visible = false
			
		if p_kata.is_empty():
			prompt_kata_label.visible = false
		else:
			prompt_kata_label.visible = true
			prompt_kata_label.text = p_kata
			
		if not p_img.is_empty() and ResourceLoader.exists(p_img):
			prompt_image.texture = load(p_img)
			prompt_image.visible = true
		else:
			prompt_image.visible = false
			
		label_question_text.text = q_text
		
		# Setup options
		var options: Array = q_data.get("options", [])
		var opt_buttons = [btn_option1, btn_option2, btn_option3]
		
		for i in range(opt_buttons.size()):
			var btn = opt_buttons[i]
			if i < options.size():
				btn.visible = true
				var opt = options[i]
				var opt_lbl = btn.get_node_or_null("HBox/OptLabel")
				var opt_img = btn.get_node_or_null("HBox/OptImage")
				var sel_icon = btn.get_node_or_null("HBox/SelectedIcon")
				
				if sel_icon:
					sel_icon.visible = false
				
				if opt.has("text"):
					if opt_lbl:
						opt_lbl.text = opt["text"]
						opt_lbl.visible = true
					if opt_img:
						opt_img.visible = false
				elif opt.has("image"):
					if opt_lbl:
						var letter_prefix = ["A. ", "B. ", "C. "][i]
						opt_lbl.text = letter_prefix
						opt_lbl.visible = true
					if opt_img:
						var img_path = opt["image"]
						if ResourceLoader.exists(img_path):
							opt_img.texture = load(img_path)
							opt_img.visible = true
						else:
							opt_img.visible = false
			else:
				btn.visible = false

func _select_option(index: int) -> void:
	selected_option_index = index
	var opt_buttons = [btn_option1, btn_option2, btn_option3]
	for i in range(opt_buttons.size()):
		var sel_icon = opt_buttons[i].get_node_or_null("HBox/SelectedIcon")
		if sel_icon:
			sel_icon.visible = (i == index)

func _on_play_sound_pressed() -> void:
	if sound_play_count < 3:
		sound_play_count += 1
		print("Playing question sound (placeholder). Count: %d/3" % sound_play_count)
		var tween = create_tween()
		tween.tween_property(btn_play_sound, "scale", Vector2(1.15, 1.15), 0.1)
		tween.tween_property(btn_play_sound, "scale", Vector2.ONE, 0.12)
		if sound_play_count >= 3:
			label_prompt_sub.text = "Pengulangan suara habis (3/3 kali)"
		else:
			label_prompt_sub.text = "Pengulangan suara: %d/3 kali" % sound_play_count

func _on_periksa_choice_pressed() -> void:
	if selected_option_index == -1:
		# Nothing selected
		return
		
	var questions: Array = current_latihan_data.get("questions", [])
	var q_data: Dictionary = questions[current_question_index]
	var correct_idx = q_data.get("correct", 0)
	
	if selected_option_index == correct_idx:
		_handle_answer_correct()
	else:
		_handle_answer_wrong()

func _on_clue_pressed() -> void:
	is_clue_active = !is_clue_active
	if is_clue_active:
		ghost_aksara.modulate.a = 0.32
	else:
		ghost_aksara.modulate.a = 0.0

func _on_hapus_draw_pressed() -> void:
	drawing_lines.clear()
	if drawing_area:
		drawing_area.queue_redraw()

func _on_drawing_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_currently_drawing = true
				var new_line = PackedVector2Array([event.position])
				drawing_lines.append(new_line)
				if drawing_area:
					drawing_area.queue_redraw()
			else:
				is_currently_drawing = false
	elif event is InputEventMouseMotion and is_currently_drawing:
		if drawing_lines.size() > 0:
			var last_idx = drawing_lines.size() - 1
			var line = drawing_lines[last_idx]
			if line.size() == 0 or line[line.size() - 1].distance_to(event.position) > 3.0:
				line.append(event.position)
				drawing_lines[last_idx] = line
				if drawing_area:
					drawing_area.queue_redraw()
	elif event is InputEventScreenTouch:
		if event.pressed:
			is_currently_drawing = true
			var new_line = PackedVector2Array([event.position])
			drawing_lines.append(new_line)
			if drawing_area:
				drawing_area.queue_redraw()
		else:
			is_currently_drawing = false
	elif event is InputEventScreenDrag and is_currently_drawing:
		if drawing_lines.size() > 0:
			var last_idx = drawing_lines.size() - 1
			var line = drawing_lines[last_idx]
			if line.size() == 0 or line[line.size() - 1].distance_to(event.position) > 3.0:
				line.append(event.position)
				drawing_lines[last_idx] = line
				if drawing_area:
					drawing_area.queue_redraw()

func _on_drawing_area_draw() -> void:
	if not drawing_area:
		return
	var ink_color = Color(0.12, 0.06, 0.05, 0.95)
	for line in drawing_lines:
		if line.size() >= 2:
			drawing_area.draw_polyline(line, ink_color, 18.0, true)
		elif line.size() == 1:
			drawing_area.draw_circle(line[0], 9.0, ink_color)

func _on_periksa_draw_pressed() -> void:
	var questions: Array = current_latihan_data.get("questions", [])
	var q_data: Dictionary = questions[current_question_index]
	var target_img_path = q_data.get("target_image", "")
	
	var is_match = _evaluate_drawing_match(target_img_path)
	if is_match:
		_handle_answer_correct()
	else:
		_handle_answer_wrong()

# Stroke Matching & Anti-Scribble Algorithm
func _evaluate_drawing_match(target_img_path: String) -> bool:
	if drawing_lines.is_empty():
		return false
		
	var total_points = 0
	for line in drawing_lines:
		total_points += line.size()
	if total_points < 5:
		return false
		
	if target_img_path.is_empty() or not ResourceLoader.exists(target_img_path):
		return true # Fallback if image missing
		
	var tex = load(target_img_path)
	if not tex:
		return true
		
	var ref_img: Image = tex.get_image()
	if not ref_img:
		return true
	if ref_img.is_compressed():
		ref_img.decompress()
		
	var grid_w = 64
	var grid_h = 64
	var area_size = drawing_area.size if (drawing_area and drawing_area.size.x > 0) else Vector2(840, 650)
	
	# Determine ghost target box (size 440x440 centered in drawing_area)
	var ghost_size = Vector2(440, 440)
	if ghost_aksara and ghost_aksara.size.x > 0:
		ghost_size = ghost_aksara.size
	var ghost_pos = (area_size - ghost_size) / 2.0
	
	# Determine aspect-fit bounds of glyph inside ghost box
	var img_orig_w = float(ref_img.get_width())
	var img_orig_h = float(ref_img.get_height())
	var fit_scale = min(ghost_size.x / img_orig_w, ghost_size.y / img_orig_h)
	var dest_w = img_orig_w * fit_scale
	var dest_h = img_orig_h * fit_scale
	var dest_pos = ghost_pos + Vector2((ghost_size.x - dest_w) / 2.0, (ghost_size.y - dest_h) / 2.0)
	
	# 1. Rasterize reference image into ref_grid (64x64)
	var ref_grid = []
	for y in range(grid_h):
		var row = []
		for x in range(grid_w):
			row.append(0)
		ref_grid.append(row)
		
	var ref_count = 0
	for iy in range(int(img_orig_h)):
		for ix in range(int(img_orig_w)):
			var c = ref_img.get_pixel(ix, iy)
			if c.a > 0.25:
				var px = dest_pos.x + (float(ix) / img_orig_w) * dest_w
				var py = dest_pos.y + (float(iy) / img_orig_h) * dest_h
				var gx = clamp(int((px / area_size.x) * grid_w), 0, grid_w - 1)
				var gy = clamp(int((py / area_size.y) * grid_h), 0, grid_h - 1)
				if ref_grid[gy][gx] == 0:
					ref_grid[gy][gx] = 1
					ref_count += 1

	if ref_count == 0:
		return true

	# 2. Build tolerance zone around reference strokes (radius 2)
	var tolerance_grid = []
	for y in range(grid_h):
		var row = []
		for x in range(grid_w):
			row.append(0)
		tolerance_grid.append(row)
		
	for y in range(grid_h):
		for x in range(grid_w):
			if ref_grid[y][x] == 1:
				for dy in range(-2, 3):
					for dx in range(-2, 3):
						if dx * dx + dy * dy <= 5:
							var ny = clamp(y + dy, 0, grid_h - 1)
							var nx = clamp(x + dx, 0, grid_w - 1)
							tolerance_grid[ny][nx] = 1

	# 3. Rasterize user strokes into drawn_grid (64x64) with brush radius 1
	var drawn_grid = []
	for y in range(grid_h):
		var row = []
		for x in range(grid_w):
			row.append(0)
		drawn_grid.append(row)
		
	var drawn_count = 0
	for line in drawing_lines:
		for pt in line:
			var gx = clamp(int((pt.x / area_size.x) * grid_w), 0, grid_w - 1)
			var gy = clamp(int((pt.y / area_size.y) * grid_h), 0, grid_h - 1)
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					var ny = clamp(gy + dy, 0, grid_h - 1)
					var nx = clamp(gx + dx, 0, grid_w - 1)
					if drawn_grid[ny][nx] == 0:
						drawn_grid[ny][nx] = 1
						drawn_count += 1

	# 4. Check drawn points count
	if drawn_count < 15:
		print("Draw rejected: too few strokes. Drawn=%d" % drawn_count)
		return false
		
	# 5. Calculate intersection and outside points
	var intersection_count = 0
	var outside_count = 0
	for y in range(grid_h):
		for x in range(grid_w):
			if drawn_grid[y][x] == 1:
				if tolerance_grid[y][x] == 1:
					intersection_count += 1
				else:
					outside_count += 1
					
	# Calculate matched reference points (how much of the letter was covered)
	var matched_ref_count = 0
	for y in range(grid_h):
		for x in range(grid_w):
			if ref_grid[y][x] == 1:
				var matched = false
				for dy in range(-2, 3):
					if matched:
						break
					for dx in range(-2, 3):
						if dx * dx + dy * dy <= 5:
							var ny = clamp(y + dy, 0, grid_h - 1)
							var nx = clamp(x + dx, 0, grid_w - 1)
							if drawn_grid[ny][nx] == 1:
								matched = true
								break
				if matched:
					matched_ref_count += 1

	var coverage = float(matched_ref_count) / float(ref_count)
	var accuracy = float(intersection_count) / float(max(1, drawn_count))

	print("Draw Match: coverage=%.2f, accuracy=%.2f, drawn=%d, ref=%d, outside=%d" % [
		coverage, accuracy, drawn_count, ref_count, outside_count
	])

	# Anti-cheat: Check if player just filled the board completely black or drew everywhere
	if drawn_count > ref_count * 2.5 or drawn_count > 1600 or outside_count > ref_count * 1.5:
		print("Draw rejected: scribble too dense or too far outside (anti-cheat). Drawn=%d, Outside=%d, Ref=%d" % [
			drawn_count, outside_count, ref_count
		])
		return false

	# Match criteria: coverage >= 28% and accuracy >= 35%
	return (coverage >= 0.28 and accuracy >= 0.35)

func _handle_answer_correct() -> void:
	print("Jawaban Benar!")
	question_fail_count = 0
	current_question_index += 1
	
	var questions: Array = current_latihan_data.get("questions", [])
	if current_question_index >= questions.size():
		_show_complete_popup()
	else:
		_animate_question_transition()

func _handle_answer_wrong() -> void:
	print("Jawaban Salah!")
	question_fail_count += 1
	_show_wrong_popup()

func _show_wrong_popup() -> void:
	label_wrong_message.text = "Maaf jawaban kamu masih salah"
	if question_fail_count >= 3:
		btn_lihat_materi.visible = true
		btn_jawab_lagi.offset_top = -240.0
		btn_jawab_lagi.offset_bottom = -130.0
		btn_lihat_materi.offset_top = -120.0
		btn_lihat_materi.offset_bottom = -10.0
	else:
		btn_lihat_materi.visible = false
		btn_jawab_lagi.offset_top = -180.0
		btn_jawab_lagi.offset_bottom = -70.0
		
	wrong_popup_layer.visible = true
	wrong_popup_layer.modulate.a = 0.0
	wrong_popup_container.scale = Vector2(0.7, 0.7)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(wrong_popup_layer, "modulate:a", 1.0, 0.22)
	tween.tween_property(wrong_popup_container, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _close_wrong_popup() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(wrong_popup_layer, "modulate:a", 0.0, 0.18)
	tween.tween_property(wrong_popup_container, "scale", Vector2(0.75, 0.75), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func():
		wrong_popup_layer.visible = false
	)

func _on_lihat_materi_pressed() -> void:
	print("Membuka Materi terkait dari Latihan (3x gagal)...")
	var pd = _get_player_data()
	if pd:
		pd.set_current_materi(current_latihan_id)
		pd.from_latihan_retry = true
		pd.latihan_return_question_idx = current_question_index
	get_tree().change_scene_to_file("res://scenes/Isimateri.tscn")

func _show_complete_popup() -> void:
	complete_popup_layer.visible = true
	complete_popup_layer.modulate.a = 0.0
	complete_popup_container.scale = Vector2(0.7, 0.7)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(complete_popup_layer, "modulate:a", 1.0, 0.25)
	tween.tween_property(complete_popup_container, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_ulangi_pressed() -> void:
	complete_popup_layer.visible = false
	current_question_index = 0
	question_fail_count = 0
	time_remaining_seconds = 95
	_render_question()

func _on_kembali_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Latihan.tscn")

func _animate_question_transition() -> void:
	_render_question()
	var active_container = drawing_container if drawing_container.visible else choice_container
	active_container.modulate.a = 0.3
	var tween = create_tween()
	tween.tween_property(active_container, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE)
