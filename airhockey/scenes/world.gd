extends Node2D

# --- Игровые параметры и переменные состояния ---
var score_player = 0 # Текущее количество очков левого игрока (Игрок 1)
var score_enemy = 0  # Текущее количество очков правого игрока (Игрок 2 / Бот)
var max_score = 10   # Лимит набранных очков, необходимый для завершения матча

# --- Ссылки на узлы графического интерфейса пользователя (UI) ---
@onready var pause_menu = %PauseMenu  # Ссылка на уникальный узел меню внутриигровой паузы
@onready var win_menu = %WinMenu      # Ссылка на уникальный узел экрана победы/поражения
@onready var win_label = $CanvasLayer2/WinMenu/WinLabel # Текстовый узел для вывода финального статуса

# --- Ссылки на узлы воспроизведения аудиоэффектов ---
@onready var goal_sound = $GoalSound                  # Звук фиксации пересечения линии ворот
@onready var score_sound = $ScoreSound                # Звук обновления счета на табло
@onready var menu_open_sound = $MenuOpenSound          # Звук развертывания интерфейса паузы
@onready var menu_close_sound = $MenuCloseSound        # Звук сворачивания интерфейса паузы
@onready var button_click_sound = $ButtonClickSound    # Звук нажатия на интерактивные кнопки

# --- Компоненты визуальных переходов ---
@onready var fade_player = $TransitionLayer/FadePlayer # Аниматор плавного затемнения/осветления экрана
var is_transitioning: bool = false # Блокиратор интерфейса для защиты от повторных нажатий (спама)

func _ready():
	# Аппаратное скрытие системного указателя мыши внутри игрового процесса
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Безопасный перевод окон интерфейса в скрытое состояние при запуске сцены
	if pause_menu: pause_menu.hide()
	if win_menu: win_menu.hide()
	
	# Инициализация воспроизведения анимации плавного проявления сцены из черного цвета
	if fade_player: fade_player.play("fade_in")

func _input(event):
	# Перехват системного прерывания по нажатию клавиши Escape (действие ui_cancel)
	if event.is_action_pressed("ui_cancel"):
		# Если игра уже завершена и отображен экран победы, вызов паузы блокируется
		if win_menu and win_menu.visible: return
		
		if pause_menu:
			# Инверсия текущего состояния паузы глобального дерева сцен
			var is_paused = get_tree().paused
			get_tree().paused = not is_paused
			pause_menu.visible = not is_paused
			
			# Динамическое управление видимостью курсора и аудиоэффектами в зависимости от состояния паузы
			if pause_menu.visible:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Отображаем мышь для работы с меню
				if menu_open_sound: menu_open_sound.play()
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)  # Скрываем мышь при возврате в игру
				if menu_close_sound: menu_close_sound.play()

func _on_goal_left_body_entered(body):
	# Обработка триггера взятия левых ворот (гол забил правый участник / бот)
	if body.name == "Puck":
		if goal_sound: goal_sound.play()
		
		score_enemy += 1 # Начисление очка оппоненту
		update_ui()      # Синхронизация графического табло счета
		
		if score_sound: score_sound.play()
		
		# Проверка выполнения условия победы правым участником
		if score_enemy >= max_score:
			_show_win_screen("ENEMY")
		else:
			body.reset_puck(true) # Сброс позиции шайбы с передачей подачи левому игроку

func _on_goal_right_body_entered(body):
	# Обработка триггера взятия правых ворот (гол забил левый игрок)
	if body.name == "Puck":
		if goal_sound: goal_sound.play()
		
		score_player += 1 # Начисление очка первому игроку
		update_ui()       # Синхронизация графического табло счета
		
		if score_sound: score_sound.play()
		
		# Проверка выполнения условия победы левым игроком
		if score_player >= max_score:
			_show_win_screen("PLAYER")
		else:
			body.reset_puck(false) # Сброс позиции шайбы с передачей подачи правому участнику

func update_ui():
	# Форматирование и вывод текущего счета матча на экранный узел Label
	var label = $CanvasLayer/Label
	if label: label.text = str(score_player) + " : " + str(score_enemy)

func _show_win_screen(winner_code: String):
	# Принудительная остановка физического симулирования и игрового таймера
	get_tree().paused = true
	
	# Восстановление видимости курсора мыши для взаимодействия с финальным интерфейсом
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var final_text = ""      # Буфер для итогового текста
	var text_color = Color.WHITE # Буфер для цвета текста
	
	# Дифференциация текстовых сообщений на основе режима игры (PvP или против ИИ)
	if Global.is_pvp:
		if winner_code == "PLAYER":
			final_text = "PLAYER 1 WIN"
			text_color = Color(0.2, 0.8, 0.2) # Зеленый цвет для первого игрока
		else:
			final_text = "PLAYER 2 WIN"
			text_color = Color(0.2, 0.6, 1.0) # Синий цвет для второго игрока
	else:
		if winner_code == "PLAYER":
			final_text = "WIN"
			text_color = Color(0.2, 0.8, 0.2) # Зеленый цвет при победе над ИИ
		else:
			final_text = "LOSS"
			text_color = Color(0.9, 0.2, 0.2) # Красный цвет при поражении от ИИ
			
	# Применение рассчитанных параметров к графическому текстовому компоненту
	if win_label:
		win_label.text = final_text
		win_label.modulate = text_color
		
	# Визуальное отображение корневого узла победного меню
	if win_menu: win_menu.show()

func _on_restart_button_pressed():
	# Обработчик нажатия кнопки "Играть снова" на финальном экране
	if is_transitioning: return
	is_transitioning = true
	if button_click_sound: button_click_sound.play()
	
	# Деактивация заморозки и полная перезагрузка текущей игровой сцены матча
	var tree = get_tree()
	if tree:
		tree.paused = false
		tree.reload_current_scene()

func _on_button_pressed() -> void:
	# Обработчик нажатия кнопки "Продолжить" в меню внутриигровой паузы
	if is_transitioning: return
	is_transitioning = true
	if button_click_sound: button_click_sound.play()
	
	# Снятие режима паузы с игрового процесса
	var tree = get_tree()
	if tree: tree.paused = false
	
	# Закрытие графического окна паузы
	if pause_menu: pause_menu.hide()
	
	# Повторное скрытие курсора мыши при возвращении к активному управлению битой
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	is_transitioning = false

func _on_menu_button_pressed() -> void:
	# Обработчик нажатия кнопки "Выйти в меню" из состояния паузы
	if is_transitioning: return
	is_transitioning = true
	if button_click_sound: button_click_sound.play()
	
	# Запуск сквозного глобального звука перехода между сценами
	Global.play_transition_sound()
	
	# Асинхронное выполнение анимации перехода (плавное затемнение экрана)
	if fade_player:
		fade_player.play("fade_out")
		await fade_player.animation_finished # Приостановка потока до полного затухания
		
	# Валидация дерева сцен и безопасный переход к сцене главного меню
	var final_tree = get_tree()
	if final_tree:
		final_tree.paused = false # Снятие флага паузы непосредственно перед переходом
		final_tree.change_scene_to_file("res://scenes/main_menu.tscn")

func _on_button_2_pressed() -> void:
	# Обработчик нажатия кнопки "Начать заново" внутри меню паузы
	if is_transitioning: return
	is_transitioning = true
	if button_click_sound: button_click_sound.play()
	
	# Снятие блокировок и экстренная перезагрузка игровой сессии
	var tree = get_tree()
	if tree:
		tree.paused = false
		tree.reload_current_scene()
