class_name job_data

enum job_difficulty_levels {EASY = 5, MEDIUM = 15, HARD = 30, VERYHARD = 60, IMPOSSIBLE = 120}
enum job_type_values {GATHERING, CRAFTING}

@export var job_name: String
@export var job_icon: Texture2D
@export var job_difficulty: job_difficulty_levels = job_difficulty_levels.EASY
@export var add_to_inventory: String
@export var job_type: job_type_values = job_type_values.GATHERING
@export var related_dungeon: String
