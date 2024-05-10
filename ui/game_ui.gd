extends CanvasLayer


@onready var timer_label:Label = %Timer

func _process(delta):
	timer_label.text = GameManager.time_elapsed_string
