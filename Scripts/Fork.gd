extends Area2D

var parent_collider
var ready_to_decide = false

# Called when the node enters the scene tree for the first time.
func _ready():
	parent_collider = get_parent().get_node("CollisionPolygon2D")

func _process(delta):
	if ready_to_decide == true:
		if Input.is_action_pressed("ui_fork_down"):
			ready_to_decide = false
			parent_collider.disabled = true
		elif Input.is_action_pressed("ui_fork_up"):
			ready_to_decide = false


func _on_Fork_area_entered(area):
	if area.is_in_group("player"):
		ready_to_decide = true


func _on_Fork_area_exited(area):
	if area.is_in_group("player"):
		ready_to_decide = false
