class_name dungeon_data

enum job_difficulty_levels {EASY = 5, MEDIUM = 15, HARD = 30, VERYHARD = 60, IMPOSSIBLE = 120}
enum job_type_values {GATHERING, CRAFTING, ADVENTURING}

@export var job_name: String
@export var required_items: Dictionary[String, int]
@export var job_difficulty: job_difficulty_levels = job_difficulty_levels.EASY
@export var job_type: job_type_values = job_type_values.ADVENTURING
@export var add_to_inventory: String
@export var max_health: int
var current_health: int = max_health
@export var next_dungeon: String
