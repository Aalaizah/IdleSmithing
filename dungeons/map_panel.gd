extends PanelContainer

func _ready():
	pass
	
func addDungeonToMap(dungeonName):
	var toAdd = Globals.allJobs.get(dungeonName)
	var skillContainer = VBoxContainer.new()
	skillContainer.name = dungeonName
	var skillHBox = HBoxContainer.new()
	skillContainer.add_child(skillHBox)
	var jobLabel = Label.new()
	jobLabel.text = toAdd.job_name
	jobLabel.size_flags_horizontal = Control.SIZE_EXPAND
	skillHBox.add_child(jobLabel)
	var skillProgress = ProgressBar.new()
	skillProgress.max_value = Globals.dungeons[dungeonName].max_health
	skillProgress.value = Globals.dungeons[dungeonName].max_health
	skillContainer.add_child(skillProgress)
	get_node("MapMarginContainer/MapContainer").add_child(skillContainer)
	Globals.dungeonHealthBars[dungeonName] = skillProgress
