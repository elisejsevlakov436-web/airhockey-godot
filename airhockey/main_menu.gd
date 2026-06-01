extends Control

# --- Ссылки на внутренние компоненты сцены ---
@onready var button_click_sound = $ButtonClickSound # Воспроизведение звукового эффекта клика
var is_transitioning: bool = false # Флаг защиты от повторной отправки сигналов с кнопок

func _ready():
	# Гарантированное восстановление видимости мыши при загрузке интерфейса главного меню
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Первоначальное форматирование корректного текста на кнопке уровня сложности ИИ
	_update_difficulty_button_text()

func _on_button_pressed() -> void:
	# Нажатие кнопки: Активация одиночного режима игры против компьютера
	if is_transitioning: return
	is_transitioning = true
	if button_click_sound: button_click_sound.play()
	
	Global.play_transition_sound() # Воспроизведение глобального звукового перехода
	Global.is_pvp = false          # Выключение режима локального мультиплеера
	
	# Безопасная смена текущей активной сцены на игровое пространство матча
	var tree = get_tree()
	if tree: tree.change_scene_to_file("res://scenes/world.tscn")

func _on_button_2_pressed() -> void:
	# Нажатие кнопки: Активация соревновательного режима на двоих игроков (PvP)
	if is_transitioning: return
	is_transitioning = true
	if button_click_sound: button_click_sound.play()
	
	Global.play_transition_sound() # Воспроизведение глобального звукового перехода
	Global.is_pvp = true           # Включение режима локального мультиплеера
	
	# Безопасная смена текущей активной сцены на игровое пространство матча
	var tree = get_tree()
	if tree: tree.change_scene_to_file("res://scenes/world.tscn")

func _on_button_3_pressed() -> void:
	# Нажатие кнопки: Корректное завершение работы приложения (выход)
	if is_transitioning: return
	is_transitioning = true
	if button_click_sound: button_click_sound.play()
	
	# Искусственная асинхронная задержка для завершения проигрывания аудиоэффекта клика
	await get_tree().create_timer(0.15).timeout
	
	# Программное закрытие и выгрузка приложения из памяти устройства
	var tree = get_tree()
	if tree: tree.quit()

func _on_button_4_pressed() -> void:
	# Нажатие кнопки: Циклическое изменение уровня сложности искусственного интеллекта
	if button_click_sound: button_click_sound.play()
	
	# Логическая инверсия флага сложности бота через оператор отрицания not
	Global.is_hard_mode = not Global.is_hard_mode
	
	# Динамическое обновление надписи на кнопке в соответствии с измененным значением
	_update_difficulty_button_text()

func _update_difficulty_button_text():
	# Безопасная проверка физического существования узла кнопки в дереве перед изменением свойств
	if has_node("Button4"):
		if Global.is_hard_mode:
			$Button4.text = "Сложность: Сложно"
		else:
			$Button4.text = "Сложность: Легко"
