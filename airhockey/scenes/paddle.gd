extends CharacterBody2D

var speed = 500.0 # Базовая скорость перемещения биты игрока

func _physics_process(_delta):
	var direction = Vector2.ZERO
	# Опрос клавиш WASD для определения вектора направления движения
	if Input.is_key_pressed(KEY_W): direction.y -= 1
	if Input.is_key_pressed(KEY_S): direction.y += 1
	if Input.is_key_pressed(KEY_A): direction.x -= 1
	if Input.is_key_pressed(KEY_D): direction.x += 1
	# Нормализация вектора и расчет финальной скорости с учетом физики движка
	velocity = direction.normalized() * speed
	move_and_slide()
	# Коррекция позиции биты для предотвращения выхода за границы левой половины поля
	global_position.x = clamp(global_position.x, 50, 550)
	global_position.y = clamp(global_position.y, 40, 608)
