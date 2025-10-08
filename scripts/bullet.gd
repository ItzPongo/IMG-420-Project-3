extends Area2D

@export var speed: float = 600.0
@export var damage: int = 25
var velocity: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	if target_position != Vector2.ZERO:
		velocity = (target_position - global_position).normalized() * speed
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta: float) -> void:
	position += velocity * delta
	if not get_viewport_rect().has_point(global_position):
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("OnHit"):
			body.call("OnHit", damage)
		queue_free()
