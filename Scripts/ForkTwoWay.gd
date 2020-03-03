extends Area2D

var parent_collider
var ready_to_switch = false
export var switch_up = true

# Called when the node enters the scene tree for the first time.
func _ready():
	parent_collider = get_parent().get_node("CollisionPolygon2D")
	
	if switch_up == false:
		parent_collider.disabled = true
		$SpriteSign/SpriteUpArrow.hide()
		$SpriteSign/SpriteDownArrow.show()

func _process(_delta):
	if ready_to_switch == true:
		if Input.is_action_just_pressed("ui_fork_down"):
			if switch_up == true:
				parent_collider.disabled = true
				$SpriteSign/SpriteUpArrow.hide()
				$SpriteSign/SpriteDownArrow.show()
				switch_up = false
			else: 
				parent_collider.disabled = false
				$SpriteSign/SpriteUpArrow.show()
				$SpriteSign/SpriteDownArrow.hide()
				switch_up = true

func _on_Fork_area_entered(area):
	if area.is_in_group("player"):
		ready_to_switch = true
		$SpriteSign/SpriteForkText.show()
		$SpriteCtrl.show()

func _on_Fork_area_exited(area):
	if area.is_in_group("player"):
		ready_to_switch = false
		$SpriteSign/SpriteForkText.hide()
		$SpriteCtrl.hide()
