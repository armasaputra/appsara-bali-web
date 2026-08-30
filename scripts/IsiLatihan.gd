extends Control

# Header Nodes
@onready var label_title: Label = $TitleBoard/LabelTitle
@onready var label_subtitle: Label = $TitleBoard/LabelSubtitle
@onready var label_question_number: Label = $HeaderBar/QuestionBoard/LabelQuestionNumber
@onready var label_timer: Label = $HeaderBar/TimerBoard/LabelTimer
@onready var star_board: TextureRect = $HeaderBar/StarBoard
@onready var label_stars: Label = $HeaderBar/StarBoard/LabelStars

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
@onready var label_complete_title: Label = $CompletePopupLayer/PopupContainer/LabelCompleteTitle
@onready var label_complete_desc: Label = $CompletePopupLayer/PopupContainer/LabelCompleteDesc
@onready var btn_ulangi: TextureButton = $CompletePopupLayer/PopupContainer/BtnUlangi
@onready var label_ulangi: Label = $CompletePopupLayer/PopupContainer/BtnUlangi/LabelUlangi
@onready var btn_kembali_menu: TextureButton = $CompletePopupLayer/PopupContainer/BtnKembaliMenu
@onready var label_kembali_menu: Label = $CompletePopupLayer/PopupContainer/BtnKembaliMenu/LabelKembaliMenu

# Back Menu & Pause Popup Nodes
@onready var btn_back_menu: TextureButton = $BtnBackMenu
@onready var pause_popup_layer: Control = $PausePopupLayer
@onready var pause_popup_container: Control = $PausePopupLayer/PopupContainer
@onready var btn_lanjutkan: TextureButton = $PausePopupLayer/PopupContainer/BtnLanjutkan
@onready var btn_kembali_pause: TextureButton = $PausePopupLayer/PopupContainer/BtnKembali

# State
var current_latihan_id: int = 1
var current_question_index: int = 0
var current_latihan_data: Dictionary = {}
var selected_option_index: int = -1
var question_fail_count: int = 0
var sound_play_count: int = 0
var is_clue_active: bool = false
var time_remaining_seconds: int = 95 # 1:35 default
var is_timeout: bool = false

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
				"sound_path": "res://assets/DubSound/ha.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/na.png"}, {"image": "res://assets/Aksara/a,ha.png"}, {"image": "res://assets/Aksara/ra.png"}],
				"correct": 1
			},
			{
				"type": "sound",
				"sound_name": "Ra",
				"sound_path": "res://assets/DubSound/ra.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ra.png"}, {"image": "res://assets/Aksara/ka.png"}, {"image": "res://assets/Aksara/ca.png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Cara",
				"sound_path": "res://assets/DubSound/cara.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ca (Ca-Ca).png"}, {"image": "res://assets/Aksara/ra (Ca-Ra).png"}, {"image": "res://assets/Aksara/na (Ha-Na).png"}],
				"correct": 1
			},
			{
				"type": "draw",
				"instruction": "Tulis aksara Ca",
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
				"sound_path": "res://assets/DubSound/da.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/na.png"}, {"image": "res://assets/Aksara/da.png"}, {"image": "res://assets/Aksara/ra.png"}],
				"correct": 1
			},
			{
				"type": "sound",
				"sound_name": "Wa",
				"sound_path": "res://assets/DubSound/wa.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/na.png"}, {"image": "res://assets/Aksara/da.png"}, {"image": "res://assets/Aksara/wa.png"}],
				"correct": 2
			},
			{
				"type": "sound",
				"sound_name": "Rasa",
				"sound_path": "res://assets/DubSound/rasa.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/RaSa.png"}, {"image": "res://assets/Aksara/DaDa.png"}, {"image": "res://assets/Aksara/SaTa.png"}],
				"correct": 0
			},
			{
				"type": "draw",
				"instruction": "Tulis aksara La",
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
				"sound_path": "res://assets/DubSound/ma.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ma.png"}, {"image": "res://assets/Aksara/da.png"}, {"image": "res://assets/Aksara/la.png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Nga",
				"sound_path": "res://assets/DubSound/nga.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/nga.png"}, {"image": "res://assets/Aksara/da.png"}, {"image": "res://assets/Aksara/wa.png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Gama",
				"sound_path": "res://assets/DubSound/gama.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/RaSa.png"}, {"image": "res://assets/Aksara/ga (Ga-Ma).png"}, {"image": "res://assets/Aksara/SaTa.png"}],
				"correct": 1
			},
			{
				"type": "draw",
				"instruction": "Tulis aksara Nga",
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
				"sound_path": "res://assets/DubSound/ya.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ya.png"}, {"image": "res://assets/Aksara/da.png"}, {"image": "res://assets/Aksara/la.png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Pasa",
				"sound_path": "res://assets/DubSound/pasa.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ba (Ba-La).png"}, {"image": "res://assets/Aksara/RaSa.png"}, {"image": "res://assets/Aksara/PaSa.png"}],
				"correct": 2
			},
			{
				"type": "sound",
				"sound_name": "JaBa",
				"sound_path": "res://assets/DubSound/jaba.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/JaBa.png"}, {"image": "res://assets/Aksara/RaMa.png"}, {"image": "res://assets/Aksara/RaGa.png"}],
				"correct": 0
			},
			{
				"type": "draw",
				"instruction": "Tulis aksara Ja",
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
				"sound_path": "res://assets/DubSound/ka (gantungan).mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ka (gantungan).png"}, {"image": "res://assets/Aksara/na (gantungan).png"}, {"image": "res://assets/Aksara/a, ha (gantungan).png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Gantungan Na",
				"sound_path": "res://assets/DubSound/na (gantungan).mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ra (gantungan).png"}, {"image": "res://assets/Aksara/ca (gantungan).png"}, {"image": "res://assets/Aksara/na (gantungan).png"}],
				"correct": 2
			},
			{
				"type": "sound",
				"sound_name": "Cakra",
				"sound_path": "res://assets/DubSound/cakra.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ra (cakra).png"}, {"image": "res://assets/Aksara/ka (paska).png"}, {"image": "res://assets/Aksara/na (Ratna).png"}],
				"correct": 0
			},
			{
				"type": "draw",
				"instruction": "Tulis Gantungan Ra",
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
				"sound_path": "res://assets/DubSound/wa (gantungan).mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/wa (gantungan).png"}, {"image": "res://assets/Aksara/la (gantungan).png"}, {"image": "res://assets/Aksara/da (gantungan).png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Gantungan La",
				"sound_path": "res://assets/DubSound/la (gantungan).mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/la (gantungan).png"}, {"image": "res://assets/Aksara/ca (gantungan).png"}, {"image": "res://assets/Aksara/sa (gempelan).png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Satwa",
				"sound_path": "res://assets/DubSound/satwa.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/wa (satwa).png"}, {"image": "res://assets/Aksara/la (amla).png"}, {"image": "res://assets/Aksara/ta (kasta) .png"}],
				"correct": 0
			},
			{
				"type": "draw",
				"instruction": "Tulis Gantungan Da",
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
				"sound_path": "res://assets/DubSound/ga (gantungan).mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ga (gantungan).png"}, {"image": "res://assets/Aksara/wa (gantungan).png"}, {"image": "res://assets/Aksara/nga (gantungan).png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Gantungan Nga",
				"sound_path": "res://assets/DubSound/nga (gantungan).mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ba (gantungan).png"}, {"image": "res://assets/Aksara/ra (gantungan).png"}, {"image": "res://assets/Aksara/nga (gantungan).png"}],
				"correct": 2
			},
			{
				"type": "sound",
				"sound_name": "Padma",
				"sound_path": "res://assets/DubSound/padma.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/nga (naknga) .png"}, {"image": "res://assets/Aksara/ba (lamba).png"}, {"image": "res://assets/Aksara/ma (padma).png"}],
				"correct": 2
			},
			{
				"type": "draw",
				"instruction": "Tulis Gantungan Ma",
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
				"sound_path": "res://assets/DubSound/pa (gempelan).mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/ga (gantungan).png"}, {"image": "res://assets/Aksara/wa (gantungan).png"}, {"image": "res://assets/Aksara/pa (gempelan).png"}],
				"correct": 2
			},
			{
				"type": "sound",
				"sound_name": "Gantungan Nya",
				"sound_path": "res://assets/DubSound/nya (gantungan).mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/nya (gantungan).png"}, {"image": "res://assets/Aksara/la (gantungan).png"}, {"image": "res://assets/Aksara/ba (gantungan).png"}],
				"correct": 0
			},
			{
				"type": "sound",
				"sound_name": "Nampa",
				"sound_path": "res://assets/DubSound/nampa.mp3",
				"prompt_header": "Silahkan di Klik gambar suara berikut :",
				"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
				"question": "Manakah aksara yang sesuai dengan suara tersebut?",
				"options": [{"image": "res://assets/Aksara/da (manda).png"}, {"image": "res://assets/Aksara/pa (nampa).png"}, {"image": "res://assets/Aksara/nya (yadnya).png"}],
				"correct": 1
			},
			{
				"type": "draw",
				"instruction": "Tulis Gempelan Pa",
				"target_image": "res://assets/Aksara/pa (gempelan).png"
			}
		]
	}
}

# 25 Bank Soal Acak (From PDF Latihan Soal Acak 25 Soal)
const LATIHAN_SOAL_ACAK_25 = [
	# 1
	{
		"type": "choice",
		"question": "Manakah pasangan gantungan yang tepat untuk deret Ya - Nya secara berurutan?",
		"options": [
			{"image": "res://assets/Aksara/ya-nya.png", "is_correct": true},
			{"image": "res://assets/Aksara/nya-ya.png", "is_correct": false},
			{"image": "res://assets/Aksara/ba-nya.png", "is_correct": false}
		]
	},
	# 2
	{
		"type": "choice",
		"question": "Jika terdapat aksara mati yang diikuti oleh bunyi Ma, gantungan manakah yang harus dipasang?",
		"options": [
			{"image": "res://assets/Aksara/ja (gantungan).png", "is_correct": false},
			{"image": "res://assets/Aksara/la (gantungan).png", "is_correct": false},
			{"image": "res://assets/Aksara/ma (gantungan) .png", "is_correct": true}
		]
	},
	# 3
	{
		"type": "choice",
		"prompt_header": "Perhatikan simbol berikut:",
		"prompt_image": "res://assets/Aksara/ya (gantungan).png",
		"question": "Gantungan ini mewakili aksara apa?",
		"options": [
			{"text": "Aksara Pa", "is_correct": false},
			{"text": "Aksara Wa", "is_correct": false},
			{"text": "Aksara Ya", "is_correct": true}
		]
	},
	# 4
	{
		"type": "choice",
		"prompt_header": "Perhatikan simbol berikut:",
		"prompt_image": "res://assets/Aksara/ma (gantungan) .png",
		"question": "Gantungan ini mewakili aksara apa?",
		"options": [
			{"text": "Aksara Ma", "is_correct": true},
			{"text": "Aksara Ca", "is_correct": false},
			{"text": "Aksara Ga", "is_correct": false}
		]
	},
	# 5
	{
		"type": "choice",
		"question": "Di antara aksara di bawah ini, manakah satu-satunya yang merupakan bagian dari kelompok gantungan pertama (Ha, Na, Ca, Ra, Ka)?",
		"options": [
			{"image": "res://assets/Aksara/la (gantungan).png", "is_correct": false},
			{"image": "res://assets/Aksara/da (gantungan).png", "is_correct": false},
			{"image": "res://assets/Aksara/ca (gantungan).png", "is_correct": true}
		]
	},
	# 6
	{
		"type": "sound",
		"sound_name": "Gempelan Sa",
		"sound_path": "res://assets/DubSound/sa (gempelan).mp3",
		"prompt_header": "Silahkan di Klik gambar suara berikut :",
		"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
		"question": "Manakah aksara yang sesuai dengan suara tersebut?",
		"options": [
			{"image": "res://assets/Aksara/sa (gempelan).png", "is_correct": true},
			{"image": "res://assets/Aksara/nya (gantungan).png", "is_correct": false},
			{"image": "res://assets/Aksara/pa (gempelan).png", "is_correct": false}
		]
	},
	# 7
	{
		"type": "sound",
		"sound_name": "Manda",
		"sound_path": "res://assets/DubSound/manda.mp3",
		"prompt_header": "Silahkan di Klik gambar suara berikut :",
		"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
		"question": "Manakah aksara yang sesuai dengan suara tersebut?",
		"options": [
			{"image": "res://assets/Aksara/ma (padma).png", "is_correct": false},
			{"image": "res://assets/Aksara/da (manda).png", "is_correct": true},
			{"image": "res://assets/Aksara/nya (yadnya).png", "is_correct": false}
		]
	},
	# 8
	{
		"type": "draw",
		"instruction": "Tulis Aksara a/Ha",
		"target_image": "res://assets/Aksara/a,ha.png"
	},
	# 9
	{
		"type": "draw",
		"instruction": "Tulis gantungan a/ha",
		"target_image": "res://assets/Aksara/a, ha (gantungan).png"
	},
	# 10
	{
		"type": "choice",
		"prompt_header": "Bacalah deretan kelima aksara secara berurutan berikut:",
		"prompt_image": "res://assets/Aksara/hanacaraka.png",
		"question": "Manakah pembacaan latin yang tepat untuk deretan aksara di atas?",
		"options": [
			{"text": "Hanacaraka", "is_correct": true},
			{"text": "Nacaraha", "is_correct": false},
			{"text": "Haranaca", "is_correct": false}
		]
	},
	# 11
	{
		"type": "choice",
		"prompt_header": "Bacalah deretan kelima latin secara berurutan berikut:",
		"prompt_kata": "Ma-Ga-Ba-Nga",
		"question": "Manakah pembacaan aksara Bali yang tepat untuk deretan di atas?",
		"options": [
			{"image": "res://assets/Aksara/hanacaraka.png", "is_correct": false},
			{"image": "res://assets/Aksara/magabanga.png", "is_correct": true},
			{"image": "res://assets/Aksara/hanakata.png", "is_correct": false}
		]
	},
	# 12
	{
		"type": "choice",
		"question": "Saat menulis kata 'Bapaknya' dalam aksara Bali, 'k' di tengah kata akan mati. Secara visual, gantungan apa yang diletakkan di bawah aksara Ka?",
		"options": [
			{"text": "Gantungan Nya", "is_correct": true},
			{"text": "Gantungan Ja", "is_correct": false},
			{"text": "Gantungan Pa", "is_correct": false}
		]
	},
	# 13
	{
		"type": "choice",
		"question": "Jika aksara Ka (ka.png) dimatikan dan digabung dengan aksara La, bagaimanakah wujud susunan visual (Kla) yang tepat?",
		"options": [
			{"image": "res://assets/Aksara/nla.png", "is_correct": false},
			{"image": "res://assets/Aksara/kma.png", "is_correct": false},
			{"image": "res://assets/Aksara/kla.png", "is_correct": true}
		]
	},
	# 14
	{
		"type": "choice",
		"prompt_header": "Perhatikan aksara berikut:",
		"prompt_image": "res://assets/Aksara/malplama.png",
		"question": "Manakah bentuk bacaan yang akurat untuk aksara di atas?",
		"options": [
			{"text": "Maspala", "is_correct": false},
			{"text": "Malapala", "is_correct": false},
			{"text": "Malplama", "is_correct": true}
		]
	},
	# 15
	{
		"type": "choice",
		"prompt_header": "Perhatikan aksara berikut:",
		"prompt_image": "res://assets/Aksara/panda.png",
		"question": "Bagaimanakah pembacaan murni dari aksara di atas?",
		"options": [
			{"text": "Pluada", "is_correct": false},
			{"text": "Palana", "is_correct": false},
			{"text": "Panda", "is_correct": true}
		]
	},
	# 16
	{
		"type": "sound",
		"sound_name": "BaLa",
		"sound_path": "res://assets/DubSound/bala.mp3",
		"prompt_header": "Silahkan di Klik gambar suara berikut :",
		"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
		"question": "Manakah aksara yang sesuai dengan suara tersebut?",
		"options": [
			{"image": "res://assets/Aksara/ba (Ba-La).png", "is_correct": true},
			{"image": "res://assets/Aksara/RaSa.png", "is_correct": false},
			{"image": "res://assets/Aksara/PaSa.png", "is_correct": false}
		]
	},
	# 17
	{
		"type": "sound",
		"sound_name": "Hana",
		"sound_path": "res://assets/DubSound/hana.mp3",
		"prompt_header": "Silahkan di Klik gambar suara berikut :",
		"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
		"question": "Manakah aksara yang sesuai dengan suara tersebut?",
		"options": [
			{"image": "res://assets/Aksara/ca (Ca-Ca).png", "is_correct": false},
			{"image": "res://assets/Aksara/ra (Ca-Ra).png", "is_correct": false},
			{"image": "res://assets/Aksara/na (Ha-Na).png", "is_correct": true}
		]
	},
	# 18
	{
		"type": "sound",
		"sound_name": "Gempelan Sa",
		"sound_path": "res://assets/DubSound/sa (gempelan).mp3",
		"prompt_header": "Silahkan di Klik gambar suara berikut :",
		"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
		"question": "Manakah aksara yang sesuai dengan suara tersebut?",
		"options": [
			{"image": "res://assets/Aksara/la (gantungan).png", "is_correct": false},
			{"image": "res://assets/Aksara/ca (gantungan).png", "is_correct": false},
			{"image": "res://assets/Aksara/sa (gempelan).png", "is_correct": true}
		]
	},
	# 19
	{
		"type": "sound",
		"sound_name": "Raksa",
		"sound_path": "res://assets/DubSound/raksa.mp3",
		"prompt_header": "Silahkan di Klik gambar suara berikut :",
		"prompt_sub": "Hanya sampai tiga (3) kali pengulangan suara",
		"question": "Manakah aksara yang sesuai dengan suara tersebut?",
		"options": [
			{"image": "res://assets/Aksara/sa (raksa).png", "is_correct": true},
			{"image": "res://assets/Aksara/wa (satwa).png", "is_correct": false},
			{"image": "res://assets/Aksara/la (amla).png", "is_correct": false}
		]
	},
	# 20
	{
		"type": "draw",
		"instruction": "Tulis Gantungan Ma",
		"target_image": "res://assets/Aksara/ma (gantungan) .png"
	},
	# 21
	{
		"type": "draw",
		"instruction": "Tulis Gantungan Wa",
		"target_image": "res://assets/Aksara/wa (gantungan).png"
	},
	# 22
	{
		"type": "draw",
		"instruction": "Tulis Gantungan Ba",
		"target_image": "res://assets/Aksara/ba (gantungan).png"
	},
	# 23
	{
		"type": "choice",
		"prompt_kata": "‘Hana raka’",
		"question": "Coba terjemahkan dua kata sederhana ini: 'Hana raka'. Manakah penulisan Aksara Bali yang tepat?",
		"options": [
			{"image": "res://assets/Aksara/hanaraka.png", "is_correct": true},
			{"image": "res://assets/Aksara/haranaka.png", "is_correct": false},
			{"image": "res://assets/Aksara/hakarana.png", "is_correct": false}
		]
	},
	# 24
	{
		"type": "choice",
		"prompt_kata": "‘Jaya Mala’",
		"question": "Coba terjemahkan dua kata sederhana ini: 'Jaya Mala'. Manakah penulisan Aksara Bali yang tepat?",
		"options": [
			{"image": "res://assets/Aksara/jayamaya.png", "is_correct": false},
			{"image": "res://assets/Aksara/jayamala.png", "is_correct": true},
			{"image": "res://assets/Aksara/jayalama.png", "is_correct": false}
		]
	},
	# 25
	{
		"type": "choice",
		"prompt_kata": "‘Saptakanda’",
		"question": "Coba terjemahkan dua kata sederhana ini: 'Saptakanda'. Manakah penulisan Aksara Bali yang tepat?",
		"options": [
			{"image": "res://assets/Aksara/saptakanda.png", "is_correct": true},
			{"image": "res://assets/Aksara/ramayana.png", "is_correct": false},
			{"image": "res://assets/Aksara/saptawara.png", "is_correct": false}
		]
	}
]

# Mapping of all DubSound files for quick resolution
const SOUND_NAME_MAP = {
	"ha": "res://assets/DubSound/ha.mp3",
	"ra": "res://assets/DubSound/ra.mp3",
	"cara": "res://assets/DubSound/cara.mp3",
	"da": "res://assets/DubSound/da.mp3",
	"wa": "res://assets/DubSound/wa.mp3",
	"rasa": "res://assets/DubSound/rasa.mp3",
	"ma": "res://assets/DubSound/ma.mp3",
	"nga": "res://assets/DubSound/nga.mp3",
	"gama": "res://assets/DubSound/gama.mp3",
	"ya": "res://assets/DubSound/ya.mp3",
	"pasa": "res://assets/DubSound/pasa.mp3",
	"jaba": "res://assets/DubSound/jaba.mp3",
	"gantungan ka": "res://assets/DubSound/ka (gantungan).mp3",
	"ka (gantungan)": "res://assets/DubSound/ka (gantungan).mp3",
	"gantungan na": "res://assets/DubSound/na (gantungan).mp3",
	"na (gantungan)": "res://assets/DubSound/na (gantungan).mp3",
	"cakra": "res://assets/DubSound/cakra.mp3",
	"gantungan wa": "res://assets/DubSound/wa (gantungan).mp3",
	"wa (gantungan)": "res://assets/DubSound/wa (gantungan).mp3",
	"gantungan la": "res://assets/DubSound/la (gantungan).mp3",
	"la (gantungan)": "res://assets/DubSound/la (gantungan).mp3",
	"satwa": "res://assets/DubSound/satwa.mp3",
	"gantungan ga": "res://assets/DubSound/ga (gantungan).mp3",
	"ga (gantungan)": "res://assets/DubSound/ga (gantungan).mp3",
	"gantungan nga": "res://assets/DubSound/nga (gantungan).mp3",
	"nga (gantungan)": "res://assets/DubSound/nga (gantungan).mp3",
	"padma": "res://assets/DubSound/padma.mp3",
	"gempelan pa": "res://assets/DubSound/pa (gempelan).mp3",
	"pa (gempelan)": "res://assets/DubSound/pa (gempelan).mp3",
	"gantungan nya": "res://assets/DubSound/nya (gantungan).mp3",
	"nya (gantungan)": "res://assets/DubSound/nya (gantungan).mp3",
	"nampa": "res://assets/DubSound/nampa.mp3",
	"gempelan sa": "res://assets/DubSound/sa (gempelan).mp3",
	"sa (gempelan)": "res://assets/DubSound/sa (gempelan).mp3",
	"manda": "res://assets/DubSound/manda.mp3",
	"bala": "res://assets/DubSound/bala.mp3",
	"hana": "res://assets/DubSound/hana.mp3",
	"raksa": "res://assets/DubSound/raksa.mp3",
}

var _local_dub_player: AudioStreamPlayer = null

func _resolve_sound_path(q_data: Dictionary) -> String:
	var s_path = q_data.get("sound_path", "")
	if not s_path.is_empty() and ResourceLoader.exists(s_path):
		return s_path
		
	var s_name = str(q_data.get("sound_name", "")).strip_edges().to_lower()
	if SOUND_NAME_MAP.has(s_name):
		var mapped_path = SOUND_NAME_MAP[s_name]
		if ResourceLoader.exists(mapped_path):
			return mapped_path
			
	var direct_path = "res://assets/DubSound/%s.mp3" % s_name
	if ResourceLoader.exists(direct_path):
		return direct_path
		
	return ""

func _play_sound_clip(s_path: String) -> void:
	# Ensure Master bus is active and unmuted so quiz sound is always audible
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx != -1 and AudioServer.is_bus_mute(master_bus_idx):
		AudioServer.set_bus_mute(master_bus_idx, false)
		
	var am = _get_audio_manager()
	if am and am.has_method("play_dub"):
		am.play_dub(s_path)
		return
	if AudioManager and AudioManager.has_method("play_dub"):
		AudioManager.play_dub(s_path)
		return
		
	# Fallback if AudioManager is not present
	if not _local_dub_player:
		_local_dub_player = AudioStreamPlayer.new()
		_local_dub_player.name = "LocalDubPlayer"
		add_child(_local_dub_player)
	if _local_dub_player.playing:
		_local_dub_player.stop()
	if ResourceLoader.exists(s_path):
		var stream = load(s_path)
		if stream is AudioStreamMP3:
			stream.loop = false
		_local_dub_player.stream = stream
		_local_dub_player.volume_db = 0.0
		_local_dub_player.play()

func _stop_sound_clip() -> void:
	var am = _get_audio_manager()
	if am and am.has_method("stop_dub"):
		am.stop_dub()
	elif AudioManager and AudioManager.has_method("stop_dub"):
		AudioManager.stop_dub()
	if _local_dub_player and _local_dub_player.playing:
		_local_dub_player.stop()

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

func _get_audio_manager() -> Node:
	var root_node = null
	if is_inside_tree() and get_tree() and get_tree().root:
		root_node = get_tree().root
	else:
		var tree = Engine.get_main_loop() as SceneTree
		if tree and tree.root:
			root_node = tree.root
			
	if root_node:
		var am_node = root_node.get_node_or_null("AudioManager")
		if am_node:
			return am_node
		for child in root_node.get_children():
			if str(child.name) == "AudioManager":
				return child
	return get_node_or_null("/root/AudioManager")

func _ensure_nodes() -> void:
	if not label_title:
		label_title = get_node_or_null("TitleBoard/LabelTitle")
	if not label_subtitle:
		label_subtitle = get_node_or_null("TitleBoard/LabelSubtitle")
	if not label_question_number:
		label_question_number = get_node_or_null("HeaderBar/QuestionBoard/LabelQuestionNumber")
	if not label_timer:
		label_timer = get_node_or_null("HeaderBar/TimerBoard/LabelTimer")
	if not star_board:
		star_board = get_node_or_null("HeaderBar/StarBoard")
	if not label_stars:
		label_stars = get_node_or_null("HeaderBar/StarBoard/LabelStars")
		
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
	if not label_complete_title:
		label_complete_title = get_node_or_null("CompletePopupLayer/PopupContainer/LabelCompleteTitle")
	if not label_complete_desc:
		label_complete_desc = get_node_or_null("CompletePopupLayer/PopupContainer/LabelCompleteDesc")
	if not btn_ulangi:
		btn_ulangi = get_node_or_null("CompletePopupLayer/PopupContainer/BtnUlangi")
	if not label_ulangi:
		label_ulangi = get_node_or_null("CompletePopupLayer/PopupContainer/BtnUlangi/LabelUlangi")
	if not btn_kembali_menu:
		btn_kembali_menu = get_node_or_null("CompletePopupLayer/PopupContainer/BtnKembaliMenu")
	if not label_kembali_menu:
		label_kembali_menu = get_node_or_null("CompletePopupLayer/PopupContainer/BtnKembaliMenu/LabelKembaliMenu")
		
	if not btn_back_menu:
		btn_back_menu = get_node_or_null("BtnBackMenu")
	if not pause_popup_layer:
		pause_popup_layer = get_node_or_null("PausePopupLayer")
	if not pause_popup_container:
		pause_popup_container = get_node_or_null("PausePopupLayer/PopupContainer")
	if not btn_lanjutkan:
		btn_lanjutkan = get_node_or_null("PausePopupLayer/PopupContainer/BtnLanjutkan")
	if not btn_kembali_pause:
		btn_kembali_pause = get_node_or_null("PausePopupLayer/PopupContainer/BtnKembali")

func _update_stars_display() -> void:
	var pd = _get_player_data()
	if label_stars and pd and "total_stars" in pd:
		label_stars.text = str(pd.total_stars)

func _ready() -> void:
	_ensure_nodes()
	_update_stars_display()
	
	# Determine current latihan ID from PlayerData
	var pd = _get_player_data()
	if pd:
		if "is_gameplay_mode" in pd and pd.is_gameplay_mode:
			current_latihan_id = pd.current_stage_level
		elif "current_latihan_index" in pd and pd.current_latihan_index > 0:
			current_latihan_id = pd.current_latihan_index
		else:
			current_latihan_id = 1
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
	_setup_button_effects(btn_back_menu)
	_setup_button_effects(btn_lanjutkan)
	_setup_button_effects(btn_kembali_pause)
	
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
	if btn_back_menu and not btn_back_menu.pressed.is_connected(_on_back_menu_pressed):
		btn_back_menu.pressed.connect(_on_back_menu_pressed)
	if btn_lanjutkan and not btn_lanjutkan.pressed.is_connected(_on_lanjutkan_pressed):
		btn_lanjutkan.pressed.connect(_on_lanjutkan_pressed)
	if btn_kembali_pause and not btn_kembali_pause.pressed.is_connected(_on_kembali_pause_pressed):
		btn_kembali_pause.pressed.connect(_on_kembali_pause_pressed)
	
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
	if pause_popup_layer:
		pause_popup_layer.visible = false
	
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
	if is_timeout:
		return
	if time_remaining_seconds > 0:
		time_remaining_seconds -= 1
		_update_timer_display()
		if time_remaining_seconds <= 0:
			_handle_timeout()

func _handle_timeout() -> void:
	if is_timeout:
		return
	is_timeout = true
	
	if _timer_node:
		_timer_node.paused = true
		
	_stop_sound_clip()
	
	# Close other popups if open
	if wrong_popup_layer:
		wrong_popup_layer.visible = false
	if pause_popup_layer:
		pause_popup_layer.visible = false
		
	# Play wrong/alert SFX
	var am = _get_audio_manager()
	if am and am.has_method("play_wrong"):
		am.play_wrong()
	elif AudioManager and AudioManager.has_method("play_wrong"):
		AudioManager.play_wrong()
		
	# Setup popup as "Waktu Habis!"
	if label_complete_title:
		label_complete_title.text = "Waktu Habis!"
	if label_complete_desc:
		label_complete_desc.text = "Waktu pengerjaan latihan telah habis.\nAyo coba lagi!"
	if label_ulangi:
		label_ulangi.text = "Ulang"
	if label_kembali_menu:
		label_kembali_menu.text = "Kembali"
		
	complete_popup_layer.visible = true
	complete_popup_layer.modulate.a = 0.0
	complete_popup_container.scale = Vector2(0.7, 0.7)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(complete_popup_layer, "modulate:a", 1.0, 0.25)
	tween.tween_property(complete_popup_container, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

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

func _format_random_question(raw_q: Dictionary) -> Dictionary:
	var q = raw_q.duplicate(true)
	if q.get("type") in ["choice", "sound"] and q.has("options"):
		var raw_opts: Array = q["options"].duplicate(true)
		raw_opts.shuffle()
		var formatted_opts = []
		var correct_idx = 0
		for i in range(raw_opts.size()):
			var opt = raw_opts[i]
			var is_corr = opt.get("is_correct", false)
			if is_corr:
				correct_idx = i
			var letter = ["A. ", "B. ", "C. "][i]
			if opt.has("text"):
				var txt = str(opt["text"])
				if not (txt.begins_with("A. ") or txt.begins_with("B. ") or txt.begins_with("C. ")):
					txt = letter + txt
				else:
					txt = letter + txt.substr(3)
				formatted_opts.append({"text": txt})
			elif opt.has("image"):
				formatted_opts.append({"image": opt["image"]})
		q["options"] = formatted_opts
		q["correct"] = correct_idx
	return q

func load_latihan(latihan_id: int, start_q_idx: int = 0) -> void:
	_ensure_nodes()
	_update_stars_display()
	current_latihan_id = latihan_id
	
	if ALL_LATIHAN_DATA.has(current_latihan_id):
		current_latihan_data = ALL_LATIHAN_DATA[current_latihan_id]
	else:
		# Endless Stage (Stage 9+)
		var pd = _get_player_data()
		var q_indices: Array[int] = []
		if pd and pd.has_method("get_next_random_question_indices"):
			q_indices = pd.get_next_random_question_indices(4, LATIHAN_SOAL_ACAK_25.size())
		else:
			for i in range(4):
				q_indices.append(randi() % LATIHAN_SOAL_ACAK_25.size())
				
		var generated_questions: Array = []
		for idx in q_indices:
			if idx >= 0 and idx < LATIHAN_SOAL_ACAK_25.size():
				var q_item = _format_random_question(LATIHAN_SOAL_ACAK_25[idx])
				generated_questions.append(q_item)
				
		current_latihan_data = {
			"title": "STAGE %d" % current_latihan_id,
			"subtitle": "Latihan Soal Acak (Endless)",
			"materi_id": ((current_latihan_id - 1) % 8) + 1,
			"questions": generated_questions
		}
	
	var questions: Array = current_latihan_data.get("questions", [])
	if start_q_idx >= 0 and start_q_idx < questions.size():
		current_question_index = start_q_idx
	else:
		current_question_index = 0
		
	question_fail_count = 0
	is_timeout = false
	time_remaining_seconds = 95
	_update_timer_display()
	if _timer_node:
		_timer_node.paused = false
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
	_stop_sound_clip()
	
	if btn_play_sound:
		btn_play_sound.modulate = Color.WHITE
	
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
			if p_sub.is_empty():
				label_prompt_sub.visible = true
				label_prompt_sub.text = "Hanya sampai tiga (3) kali pengulangan suara"
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
	var questions: Array = current_latihan_data.get("questions", [])
	if current_question_index < 0 or current_question_index >= questions.size():
		return
	var q_data: Dictionary = questions[current_question_index]
	if q_data.get("type") != "sound":
		return
		
	if sound_play_count < 3:
		sound_play_count += 1
		var s_path = _resolve_sound_path(q_data)
		print("Playing question sound [%s] (%s). Count: %d/3" % [q_data.get("sound_name", ""), s_path, sound_play_count])
		
		if not s_path.is_empty():
			_play_sound_clip(s_path)
		else:
			print("Warning: sound file not found for question sound_name: %s" % q_data.get("sound_name", ""))
			
		var tween = create_tween()
		tween.tween_property(btn_play_sound, "scale", Vector2(1.18, 1.18), 0.09).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(btn_play_sound, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		if sound_play_count >= 3:
			label_prompt_sub.text = "Pengulangan suara habis (3/3 kali)"
			btn_play_sound.modulate = Color(0.65, 0.65, 0.65, 0.6)
		else:
			label_prompt_sub.text = "Pengulangan suara: %d/3 kali" % sound_play_count
	else:
		# Limit reached (already 3 times) - gentle shake feedback
		print("Sound play limit reached (3/3).")
		var original_x = btn_play_sound.position.x
		var shake_tween = create_tween()
		shake_tween.tween_property(btn_play_sound, "position:x", original_x - 6.0, 0.04)
		shake_tween.tween_property(btn_play_sound, "position:x", original_x + 6.0, 0.04)
		shake_tween.tween_property(btn_play_sound, "position:x", original_x, 0.04)


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

# Two-Way Masked Pixel Comparison Drawing Assessment
func _evaluate_drawing_match(target_img_path: String) -> bool:
	if drawing_lines.is_empty():
		return false
		
	var total_points = 0
	for line in drawing_lines:
		total_points += line.size()
	if total_points < 4:
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
	
	# Determine aspect-fit bounds of glyph inside ghost box (TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var img_orig_w = float(ref_img.get_width())
	var img_orig_h = float(ref_img.get_height())
	if img_orig_w <= 0.0 or img_orig_h <= 0.0:
		return true
		
	var fit_scale = min(ghost_size.x / img_orig_w, ghost_size.y / img_orig_h)
	var dest_w = img_orig_w * fit_scale
	var dest_h = img_orig_h * fit_scale
	var dest_pos = ghost_pos + Vector2((ghost_size.x - dest_w) / 2.0, (ghost_size.y - dest_h) / 2.0)
	
	# 1. Rasterize target reference image into target_core_mask
	var target_core_mask = []
	for y in range(grid_h):
		var row = []
		row.resize(grid_w)
		row.fill(false)
		target_core_mask.append(row)
		
	var target_core_count = 0
	for iy in range(int(img_orig_h)):
		for ix in range(int(img_orig_w)):
			var c = ref_img.get_pixel(ix, iy)
			if c.a > 0.25:
				var px = dest_pos.x + (float(ix) / img_orig_w) * dest_w
				var py = dest_pos.y + (float(iy) / img_orig_h) * dest_h
				var gx = clamp(int((px / area_size.x) * grid_w), 0, grid_w - 1)
				var gy = clamp(int((py / area_size.y) * grid_h), 0, grid_h - 1)
				if not target_core_mask[gy][gx]:
					target_core_mask[gy][gx] = true
					target_core_count += 1

	if target_core_count == 0:
		return true

	# 2. Build target silhouette mask with small stroke tolerance zone (radius ~2 cells)
	# This defines the valid stroke corridor so natural handwriting variance along the letter
	# is not penalized as outside stray ink.
	var target_silhouette_mask = []
	for y in range(grid_h):
		var row = []
		row.resize(grid_w)
		row.fill(false)
		target_silhouette_mask.append(row)
		
	for y in range(grid_h):
		for x in range(grid_w):
			if target_core_mask[y][x]:
				for dy in range(-2, 3):
					for dx in range(-2, 3):
						if dx * dx + dy * dy <= 4:
							var ny = clamp(y + dy, 0, grid_h - 1)
							var nx = clamp(x + dx, 0, grid_w - 1)
							target_silhouette_mask[ny][nx] = true

	# 3. Rasterize user strokes into drawn_mask (interpolating points to avoid gaps on fast swipes)
	var drawn_mask = []
	for y in range(grid_h):
		var row = []
		row.resize(grid_w)
		row.fill(false)
		drawn_mask.append(row)
		
	for line in drawing_lines:
		if line.size() == 1:
			_stamp_drawn_point(drawn_mask, line[0], area_size, grid_w, grid_h)
		elif line.size() >= 2:
			for i in range(line.size() - 1):
				var p1 = line[i]
				var p2 = line[i + 1]
				var dist = p1.distance_to(p2)
				var steps = max(1, int(dist / 4.0))
				for s in range(steps + 1):
					var t = float(s) / float(steps)
					var pt = p1.lerp(p2, t)
					_stamp_drawn_point(drawn_mask, pt, area_size, grid_w, grid_h)

	# 4. Count True Positives (inside target silhouette) and Outside Pixels (in empty space)
	var true_positive_count = 0
	var total_drawn_count = 0
	var outside_drawn_count = 0
	
	for y in range(grid_h):
		for x in range(grid_w):
			if drawn_mask[y][x]:
				total_drawn_count += 1
				if target_silhouette_mask[y][x]:
					pass # Inside valid silhouette
				else:
					outside_drawn_count += 1
					
			if target_core_mask[y][x] and drawn_mask[y][x]:
				true_positive_count += 1

	if total_drawn_count == 0:
		return false

	# 5. Calculate Two-Way Masked Ratios
	# True Positive Ratio: proportion of target silhouette core covered
	var true_positive_ratio = float(true_positive_count) / float(target_core_count)
	
	# Outside Penalty Ratio: proportion of drawn pixels falling into empty space outside silhouette
	var outside_penalty_ratio = float(outside_drawn_count) / float(total_drawn_count)
	
	# Final Score: percentage between 0% and 100%
	var raw_score = true_positive_ratio - outside_penalty_ratio
	var final_score = clampf(raw_score, 0.0, 1.0) * 100.0
	
	# Win condition: 60% or higher is a win
	var is_win = final_score >= 60.0

	print("Drawing Assessment: Score=%.1f%% (TPR=%.1f%%, Penalty=%.1f%%, TP=%d/%d, Outside=%d/%d) -> %s" % [
		final_score,
		true_positive_ratio * 100.0,
		outside_penalty_ratio * 100.0,
		true_positive_count,
		target_core_count,
		outside_drawn_count,
		total_drawn_count,
		"WIN" if is_win else "FAIL"
	])

	return is_win

func _stamp_drawn_point(mask: Array, pt: Vector2, area_size: Vector2, grid_w: int, grid_h: int) -> void:
	var gx = clamp(int((pt.x / area_size.x) * grid_w), 0, grid_w - 1)
	var gy = clamp(int((pt.y / area_size.y) * grid_h), 0, grid_h - 1)
	# Brush radius footprint (3x3 on 64x64 grid corresponds to ~18px brush width on 840x650 canvas)
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var ny = clamp(gy + dy, 0, grid_h - 1)
			var nx = clamp(gx + dx, 0, grid_w - 1)
			mask[ny][nx] = true

func _handle_answer_correct() -> void:
	_stop_sound_clip()
	print("Jawaban Benar!")
	var am = _get_audio_manager()
	if am and am.has_method("play_correct"):
		am.play_correct()
	elif AudioManager and AudioManager.has_method("play_correct"):
		AudioManager.play_correct()
		
	question_fail_count = 0
	current_question_index += 1
	
	var questions: Array = current_latihan_data.get("questions", [])
	if current_question_index >= questions.size():
		_show_complete_popup()
	else:
		_animate_question_transition()

func _handle_answer_wrong() -> void:
	_stop_sound_clip()
	print("Jawaban Salah!")
	var am = _get_audio_manager()
	if am and am.has_method("play_wrong"):
		am.play_wrong()
	elif AudioManager and AudioManager.has_method("play_wrong"):
		AudioManager.play_wrong()
		
	question_fail_count += 1
	_show_wrong_popup()

func _show_wrong_popup() -> void:
	_stop_sound_clip()
	label_wrong_message.text = "Maaf jawaban kamu masih salah"
	if question_fail_count >= 3:
		btn_lihat_materi.visible = true
	else:
		btn_lihat_materi.visible = false
		
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
	_stop_sound_clip()
	print("Membuka Materi terkait dari Latihan (3x gagal)...")
	var pd = _get_player_data()
	if pd:
		var target_m_id = current_latihan_id
		if target_m_id > 8:
			target_m_id = ((current_latihan_id - 1) % 8) + 1
		pd.set_current_materi(target_m_id)
		pd.from_latihan_retry = true
		pd.latihan_return_question_idx = current_question_index
		pd.set_current_latihan(current_latihan_id)
	get_tree().change_scene_to_file("res://scenes/Isimateri.tscn")

func _show_complete_popup() -> void:
	is_timeout = false
	if _timer_node:
		_timer_node.paused = true
		
	_stop_sound_clip()
	var am = _get_audio_manager()
	if am and am.has_method("play_stage_complete"):
		am.play_stage_complete()
	elif AudioManager and AudioManager.has_method("play_stage_complete"):
		AudioManager.play_stage_complete()
		
	var pd = _get_player_data()
	var is_gameplay = (pd and "is_gameplay_mode" in pd and pd.is_gameplay_mode)
	
	if is_gameplay:
		pd.add_star(1)
		pd.complete_stage(current_latihan_id)
		pd.current_stage_level = current_latihan_id + 1
		pd.save_progress()
		_update_stars_display()
		
		if label_complete_title:
			label_complete_title.text = "LEVEL SELESAI!"
		if label_complete_desc:
			label_complete_desc.text = "Selamat! Kamu mendapatkan 1 Bintang ⭐\ndan membuka level berikutnya."
		if label_ulangi:
			label_ulangi.text = "Level Selanjutnya"
		if label_kembali_menu:
			label_kembali_menu.text = "Peta Belajar"
	else:
		# Standalone Latihan mode (No stars added, Belajar Bertahap progress untouched)
		if label_complete_title:
			label_complete_title.text = "LATIHAN SELESAI!"
		if label_complete_desc:
			label_complete_desc.text = "Hebat! Kamu telah menyelesaikan seluruh soal latihan."
		if label_ulangi:
			label_ulangi.text = "Ulangi"
		if label_kembali_menu:
			label_kembali_menu.text = "Menu Latihan"
			
	complete_popup_layer.visible = true
	complete_popup_layer.modulate.a = 0.0
	complete_popup_container.scale = Vector2(0.7, 0.7)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(complete_popup_layer, "modulate:a", 1.0, 0.25)
	tween.tween_property(complete_popup_container, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_ulangi_pressed() -> void:
	_stop_sound_clip()
	complete_popup_layer.visible = false
	var pd = _get_player_data()
	var is_gameplay = (pd and "is_gameplay_mode" in pd and pd.is_gameplay_mode)
	
	if is_timeout:
		# Replay current level/latihan after timeout
		is_timeout = false
		current_question_index = 0
		question_fail_count = 0
		time_remaining_seconds = 95
		_update_timer_display()
		if _timer_node:
			_timer_node.paused = false
		load_latihan(current_latihan_id, 0)
		return
		
	if is_gameplay:
		# Advance to the next level
		current_latihan_id = pd.current_stage_level
		current_question_index = 0
		question_fail_count = 0
		time_remaining_seconds = 95
		_update_timer_display()
		if _timer_node:
			_timer_node.paused = false
		if current_latihan_id <= 8:
			pd.set_current_materi(current_latihan_id)
			pd.from_latihan_retry = false
			pd.latihan_return_question_idx = 0
			get_tree().change_scene_to_file("res://scenes/Isimateri.tscn")
		else:
			load_latihan(current_latihan_id, 0)
	else:
		# Replay current latihan
		current_question_index = 0
		question_fail_count = 0
		time_remaining_seconds = 95
		_update_timer_display()
		if _timer_node:
			_timer_node.paused = false
		_render_question()

func _on_kembali_menu_pressed() -> void:
	_stop_sound_clip()
	is_timeout = false
	var pd = _get_player_data()
	if pd and "is_gameplay_mode" in pd and pd.is_gameplay_mode:
		get_tree().change_scene_to_file("res://scenes/Gameplay.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/Latihan.tscn")

func _animate_question_transition() -> void:
	_render_question()
	var active_container = drawing_container if drawing_container.visible else choice_container
	active_container.modulate.a = 0.3
	var tween = create_tween()
	tween.tween_property(active_container, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE)

func _on_back_menu_pressed() -> void:
	_stop_sound_clip()
	if _timer_node:
		_timer_node.paused = true
	_show_pause_popup()

func _show_pause_popup() -> void:
	is_currently_drawing = false
	if not pause_popup_layer or not pause_popup_container:
		return
	pause_popup_layer.visible = true
	pause_popup_layer.modulate.a = 0.0
	pause_popup_container.scale = Vector2(0.7, 0.7)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(pause_popup_layer, "modulate:a", 1.0, 0.22)
	tween.tween_property(pause_popup_container, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_lanjutkan_pressed() -> void:
	if _timer_node and not is_timeout:
		_timer_node.paused = false
	_close_pause_popup()

func _close_pause_popup() -> void:
	if not pause_popup_layer or not pause_popup_container:
		return
	var tween = create_tween().set_parallel(true)
	tween.tween_property(pause_popup_layer, "modulate:a", 0.0, 0.18)
	tween.tween_property(pause_popup_container, "scale", Vector2(0.75, 0.75), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func():
		pause_popup_layer.visible = false
	)

func _on_kembali_pause_pressed() -> void:
	if _timer_node:
		_timer_node.paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

