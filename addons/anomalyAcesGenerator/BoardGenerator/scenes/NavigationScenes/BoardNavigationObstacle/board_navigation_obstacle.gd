class_name BoardNavigationObstacle extends StaticBody3D


static func get_obstacle_scene():
	var scene: PackedScene = load("res://addons/anomalyAcesGenerator/BoardGenerator/scenes/NavigationScenes/BoardNavigationObstacle/BoardNavigationObstacle.tscn")
	return scene.instantiate()
