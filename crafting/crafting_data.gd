class_name crafting_data

enum job_difficulty_levels {EASY = 5, MEDIUM = 60, HARD = 120, VERYHARD = 240}
enum job_type_values {GATHERING, CRAFTING}

@export var job_name: String
@export var add_to_inventory: String
@export var required_items: Dictionary
@export var craft_icon: Texture2D
@export var job_difficulty: job_difficulty_levels
@export var job_type: job_type_values = job_type_values.CRAFTING
