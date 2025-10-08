extends CanvasLayer

signal start_game

func show_message(text: String) -> void:
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func update_score(score):
	$Score.text = str(score)

func show_game_over():
	$Message.text = "Game Over"
	$Message.show()
