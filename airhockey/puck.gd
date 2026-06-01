extends CharacterBody2D

@export var min_x: float = 30.0  # Минимальная граница поля по оси X
@export var max_x: float = 1248.0 # Максимальная граница поля по оси X
@export var min_y: float = -20.0  # Минимальная граница поля по оси Y
@export var max_y: float = 628.0  # Максимальная граница поля по оси Y
@export var speed: float = 600.0  # Базовая скорость перемещения шайбы

@onready var hit_sound_player: AudioStreamPlayer2D = $HitSoundPlayer
@onready var wall_sound_player: AudioStreamPlayer2D = $WallSoundPlayer

func _ready():
	# Вычисление начального случайного вектора движения снаряда при старте
	var random_dir = Vector2(randf_range(-1, 1), randf_range(-0.6, 0.6)).normalized()
	velocity = random_dir * speed

func _physics_process(delta):
	# Выполнение итерации перемещения с получением параметров столкновения
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is CharacterBody2D:
			# Расчет вектора отражения от биты с динамическим ускорением
			var push_dir = (global_position - collider.global_position).normalized()
			velocity = push_dir * max(velocity.length(), speed * 1.2)
			global_position += push_dir * 15.0
			if hit_sound_player: hit_sound_player.play()
		else:
			# Зеркальное отражение вектора скорости относительно нормали поверхности стены
			velocity = velocity.bounce(collision.get_normal())
			global_position += collision.get_normal() * 5.0
			if wall_sound_player: wall_sound_player.play()
	# Принудительная программная фильтрация координат объекта в границах арены
	global_position.x = clamp(global_position.x, min_x, max_x)
	global_position.y = clamp(global_position.y, min_y, max_y)

func reset_puck(to_left_player: bool):
	# Сброс кинетической энергии снаряда и репозиционирование на поле после гола
	velocity = Vector2.ZERO
	var screen_center = Vector2((min_x + max_x) / 2.0, (min_y + max_y) / 2.0)
	if to_left_player:
		global_position = Vector2(screen_center.x - 250, screen_center.y)
	else:
		global_position = Vector2(screen_center.x + 250, screen_center.y)
