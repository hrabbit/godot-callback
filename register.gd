@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("CallbackHelper", "Node", preload("callbackhelper.gd"), preload("res://addons/callbackhelper/icon.svg"))
	# Initialization of the plugin goes here.
	pass

func _exit_tree():
	remove_custom_type("CallbackHelper")
	# Clean-up of the plugin goes here.
	pass
