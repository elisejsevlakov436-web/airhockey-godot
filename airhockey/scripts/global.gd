extends Node

# Глобальные переменные состояния игры
var is_pvp = false # Флаг режима: true — вдвоем, false — против ИИ
var score_player = 0 # Счетчик очков первого игрока
var score_bot = 0 # Счетчик очков бота или второго игрока
var is_hard_mode: bool = true # Флаг сложного режима ИИ

# Узел для воспроизведения звуков смены экранов
var transition_sound_player: AudioStreamPlayer

func _ready():
	# Автоматическое создание и настройка аудиоузла при запуске игры
	transition_sound_player = AudioStreamPlayer.new()
	add_child(transition_sound_player)
	transition_sound_player.stream = load("res://вуш.wav") 

# Функция воспроизведения звука перехода из любого места программы
func play_transition_sound():
	if transition_sound_player and transition_sound_player.stream:
		transition_sound_player.play()
