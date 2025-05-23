class_name World
extends Node3D

@export var load_level_distance = 100 # load _ amount of levels ahead and unload _ levels behind
@export var start_position = Vector3.ZERO
@export var player: Player
@export var current_biome: Biome
@export var auto_load_levels: bool = false
@export var noise: FastNoiseLite
@export var timer_label: Label

@onready var biomes = $Biomes

var chunk_position: int = 0

var time_started: int

var level_position: int = 0

class RandomSeed:
	var _random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()
	var seed = randi()
	
	func get_randi(index: int, from: int, to: int) -> int:
		_random_number_generator.seed = seed + index
		return _random_number_generator.randi_range(from, to)
	
	func randomize() -> void:
		_random_number_generator.randomize()

class LevelLoader:
	var rng = RandomSeed.new()
	var loaded_levels: Dictionary = {} #{int: int}
	var levels: Dictionary = {} #{int: Level}
	var current_index: int = 0
	
	var min_int: int
	var max_int: int
	var ahead: int
	var behind: int
	var biome: Biome
	
	signal on_loading_level
	signal on_unloading_level
	
	
	func _init(minimum_int: int, maximum_int: int, behind_count: int, ahead_count: int, new_biome: Biome) -> void:
		min_int = minimum_int
		max_int = maximum_int
		ahead = ahead_count
		behind = behind_count
		biome = new_biome
		
	func generate_levels(index: int) -> Dictionary:
		var levels: Dictionary = {}
		var size: int = ahead + behind + 1
		for i in size:
			i -= behind
			levels[i] = rng.get_randi(i, min_int, max_int)
			print(i)
		print(levels)
		return levels
	
	func load_levels(parent: Object) -> Vector3:
		loaded_levels = generate_levels(0)
		
		var levels_to_load: int = loaded_levels.size()
		var end_position: Vector3 = Vector3.ZERO
		var last_end_position: Vector3
		print(ahead, behind)
		for i in levels_to_load:
			i -= behind 
			var level: Level = biome.levels[loaded_levels[i]].instantiate()
			level.name = "Level_" + str(i)
			level.global_position = end_position - level.start_marker.position
			end_position += (level.end_marker.position - level.start_marker.position)
			parent.add_child(level)
			last_end_position = end_position
		
		return last_end_position
	
	func initiate_end(parent: Object) -> Vector3:
		#loaded_levels = generate_levels(0)
		#
		#var levels_to_load: int = loaded_levels.size()
		#var end_position: Vector3 = Vector3.ZERO
		#var last_end_position: Vector3
		#for i in levels_to_load:
			#i -= behind 
			#var level: Level = biome.levels[loaded_levels[i]].instantiate()
			#level.name = "Level_" + str(i)
			#level.global_position = end_position - level.start_marker.position
			#end_position += (level.end_marker.position - level.start_marker.position)
			#parent.add_child(level)
			#last_end_position = end_position
		
		#return last_end_position
		return Vector3()
	
	func refresh_at(index: int) -> void:
		var length: int = (index + ahead) - (index - behind)
		
		var new_levels = generate_levels(index)
		
		# find removed levels
		for i in loaded_levels:
			var level_value = new_levels.get(i)
			if level_value:
				continue
			  
			var level: Level = levels[i]
			level.unload_level()
			on_unloading_level.emit(i, level_value)
		
		# find missing levels that were "added"
		for i in new_levels:
			var level_value = loaded_levels.get(i)
			if level_value:
				continue
			
			var new_level: Level = biome.levels[i].instantiate()
			new_level.load_level(i)
			levels[i] = new_level
			on_loading_level.emit(i, level_value)
		
		loaded_levels = new_levels
		return


var rng = RandomSeed.new()
var level_loader: LevelLoader
var level_end_position: Vector3

func initialize_level():
	select_random_biome()
	player.position = start_position + Vector3(0.0, 3.0, 0.0)
	load_levels()
	level_loader = LevelLoader.new(0, current_biome.levels.size()-1, -2, load_level_distance, current_biome)
	level_end_position = level_loader.load_levels(self)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_level()
	await get_tree().create_timer(1.0).timeout
	player.active = true
	time_started = Time.get_ticks_msec()
	print(time_started, "start")
	
func select_random_biome() -> void:
	var max_biomes = biomes.get_child_count()
	var random_number = randi() % max_biomes
	var selected_biome = biomes.get_child(random_number)
	if not selected_biome is Biome:
		push_error("not a biome?")
	current_biome = selected_biome

func get_random_level() -> PackedScene:
	level_position += 1
	
	# Convert noise_value to an integer within [min_value, max_value].
	var max_levels: int = current_biome.levels.size()
	var min_levels:int = 1
	var random_int = rng.get_randi(level_position, min_levels, max_levels) - 1

	# get level from randomized noise value
	var random_level: PackedScene = current_biome.levels[random_int]
	return random_level

func load_levels() -> void:
	if auto_load_levels:
		return
	
	var levels_to_load: int = 30
	var end_position: Vector3 = Vector3.ZERO
	for i in levels_to_load:
		var level: Level = get_random_level().instantiate()
		level.name = "Level_" + str(i)
		level.global_position = end_position - level.start_marker.position
		end_position += (level.end_marker.position - level.start_marker.position)
		#self.add_child(level)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var distance_travelled = start_position.x - player.position.x
	
	# is player getting close to end?
	if player.position.x > (level_end_position.x - 5.0):
		print("passed!")
		level_loader.initiate_end(self)
	
	# Timer
	if timer_label and time_started != 0:
		var time_passed_in_seconds: float = (Time.get_ticks_msec() - time_started) / 1000.0
		time_passed_in_seconds = floor(time_passed_in_seconds * 100) / 100
		timer_label.text = "time:  " + str(time_passed_in_seconds)
