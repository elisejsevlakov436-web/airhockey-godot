extends CharacterBody2D

@export var speed_hard = 350.0 # Скорость бота в сложном режиме
@export var acceleration_hard = 5.0 # Разгон бота в сложном режиме
@export var speed_easy = 240.0 # Скорость бота в легком режиме
@export var acceleration_easy = 3.5 # Разгон бота в легком режиме
@export var speed_pvp = 500.0 # Скорость второго игрока в PvP (равна первому игроку)

@onready var puck = $"../Puck"

var home_position = Vector2.ZERO # Стартовая позиция биты
var center_line_x = 0.0 # Координата центральной линии поля

func _ready():
	home_position = global_position
	if puck:
		center_line_x = (puck.min_x + puck.max_x) / 2.0

func _physics_process(delta):
	# Если включен режим на двоих, передаем управление второму игроку
	if Global.is_pvp:
		_handle_player_2_input(delta)
		return
	if not puck: return
	# Выбор режима работы искусственного интеллекта
	if Global.is_hard_mode:
		_run_hard_ai(delta)
	else:
		_run_easy_ai(delta)

func _run_hard_ai(delta):
	var target_position = home_position
	# Логика атаки: бот идет к шайбе, если она на его половине поля и движется к нему
	if puck.global_position.x > center_line_x and (puck.velocity == Vector2.ZERO or puck.velocity.x > 0):
		target_position = puck.global_position
		if target_position.x > puck.max_x - 120:
			target_position.x = puck.max_x - 120
		target_position.y = clamp(target_position.y, puck.min_y + 80, puck.max_y - 80)
	else:
		target_position = home_position
	# Расчет вектора движения к цели
	var direction = (target_position - global_position)
	var target_velocity = Vector2.ZERO
	if direction.length() > 15:
		target_velocity = direction.normalized() * speed_hard
	velocity = velocity.move_toward(target_velocity, speed_hard * delta * acceleration_hard)
	move_and_slide()
	_apply_field_limits_hard()

func _run_easy_ai(delta):
	var target_position = home_position
	# Аналогичная логика преследования, но с измененными ограничениями отступов
	if puck.global_position.x > center_line_x and (puck.velocity == Vector2.ZERO or puck.velocity.x > 0):
		target_position = puck.global_position
		if target_position.x > puck.max_x - 130:
			target_position.x = puck.max_x - 130
		target_position.y = clamp(target_position.y, puck.min_y + 80, puck.max_y - 80)
	else:
		target_position = home_position
	var direction = (target_position - global_position)
	var target_velocity = Vector2.ZERO
	# Увеличенная мертвая зона (25 пикселей) для симуляции задержки реакции бота
	if direction.length() > 25:
		target_velocity = direction.normalized() * speed_easy
	velocity = velocity.move_toward(target_velocity, speed_easy * delta * acceleration_easy)
	move_and_slide()
	_apply_field_limits_easy()

func _handle_player_2_input(_delta):
	# Обработка ввода клавиш-стрелок для второго игрока с симметричной физикой движения
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("ui_up"): input_dir.y -= 1
	if Input.is_action_pressed("ui_down"): input_dir.y += 1
	if Input.is_action_pressed("ui_left"): input_dir.x -= 1
	if Input.is_action_pressed("ui_right"): input_dir.x += 1
	# Прямое присвоение нормализованной скорости для ликвидации задержек управления
	velocity = input_dir.normalized() * speed_pvp
	move_and_slide()
	_apply_field_limits_hard()

func _apply_field_limits_hard():
	# Блокировка выхода за пределы правой половины поля в сложном режиме и PvP
	if not puck: return
	if global_position.x < center_line_x:
		global_position.x = center_line_x
		velocity.x = 0
	if global_position.x > puck.max_x - 120:
		global_position.x = puck.max_x - 120
		velocity.x = 0
	global_position.y = clamp(global_position.y, puck.min_y + 75, puck.max_y - 75)

func _apply_field_limits_easy():
	# Блокировка выхода за пределы поля в легком режиме с увеличенным безопасным буфером
	if not puck: return
	if global_position.x < center_line_x:
		global_position.x = center_line_x
		velocity.x = 0
	if global_position.x > puck.max_x - 130:
		global_position.x = puck.max_x - 130
		velocity.x = 0
	global_position.y = clamp(global_position.y, puck.min_y + 80, puck.max_y - 80)
