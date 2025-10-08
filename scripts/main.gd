extends Node2D

var enemy_scene = preload("res://scenes/Enemy.tscn")
@onready var player = $Player
var score := 0
var game_started := false

@onready var hud = $HUD

func _ready():
	player.hide()
	get_tree().call_group("enemies", "queue_free")
	hud.show_message("Press SPACE to Start")

func _process(_delta):
	if not game_started and Input.is_action_just_pressed("start"):
		start_game()

# --- Game flow ---
func start_game():
	game_started = true
	score = 0
	hud.update_score(score)
	hud.show_message("Get Ready!")

	var viewport_size = get_viewport_rect().size
	player.start(viewport_size / 2)
	player.show()

	# Spawn initial enemies
	for i in range(5):
		spawn_enemy()

func player_died():
	game_over()

func game_over():
	game_started = false
	hud.show_game_over()
	player.hide()
	
	# Clean up enemies
	get_tree().call_group("enemies", "queue_free")
	
	# Show restart message
	hud.show_message("Press SPACE to Restart")

# --- Enemy management ---
func spawn_enemy():
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		var viewport_rect = get_viewport_rect()
		enemy.global_position = Vector2(
			randf() * viewport_rect.size.x,
			randf() * viewport_rect.size.y
		)
		
		if enemy.has_method("SetTarget"):
			enemy.call("SetTarget", player)

		if enemy.has_signal("EnemyDied"):
			enemy.connect("EnemyDied", Callable(self, "_on_enemy_died"))

		add_child(enemy)

func _on_enemy_died(_enemy):
	# Increment score
	score += 1
	hud.update_score(score)

	# Spawn 0-3 new enemies
	var count = randi() % 4
	for i in range(count):
		spawn_enemy()
