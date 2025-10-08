extends Area2D

signal hit
signal died

@export var speed := 400
@export var max_health := 100
var current_health := 100

var screen_size

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	screen_size = get_viewport_rect().size
	current_health = max_health
	$HealthBar.max_value = max_health
	$HealthBar.value = current_health

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		get_node("Pistol").shoot()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		take_damage(10)
		if body.has_method("LinearVelocity"):
			var knockback = (global_position - body.global_position).normalized() * 50
			position += knockback

func take_damage(amount: int) -> void:
	current_health -= amount
	$HealthBar.value = current_health

	if current_health <= 0:
		die()

func die() -> void:
	hide()
	hit.emit()
	died.emit()
	$PlayerCollision.set_deferred("disabled", true)
	get_parent().player_died()


func start(pos: Vector2):
	position = pos
	show()
	$PlayerCollision.disabled = false
	current_health = max_health
	$HealthBar.value = current_health
