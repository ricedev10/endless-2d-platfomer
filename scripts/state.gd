class_name character_state
extends Node

enum STATES {IDLE, CROUCH, SLIDE, JUMP, RUN}

@export var state: STATES:
	set(value):
		if not state == value:
			state_changed.emit(value)
		state = value

signal state_changed

func _ready() -> void:
	state = STATES.IDLE
