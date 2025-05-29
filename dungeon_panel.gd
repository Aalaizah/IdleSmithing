extends PanelContainer
var timers = {}

func _ready():
	var loadDungeons = [
		load("res://dungeons/dungeon1.tres"),
		load("res://dungeons/dungeon2.tres"),
		load("res://dungeons/dungeon3.tres"),
		load("res://dungeons/dungeon4.tres"),
		load("res://dungeons/dungeon5.tres")
	]
	for dungeon in loadDungeons:
		Globals.allJobs.set(dungeon.job_name, dungeon)
		
	EventBus.dungeon_started.connect(startTimer)
		
func addDungeonToPanel(dungeon_name):
	Globals.activeDungeons.append(dungeon_name)
	var toAdd = Globals.allJobs.get(dungeon_name)
	#activeDungeons.append(toAdd)
	var skillContainer = VBoxContainer.new()
	skillContainer.name = dungeon_name
	var tooltipString = createTooltipString(dungeon_name)
	skillContainer.tooltip_text = tooltipString
	var skillHBox = HBoxContainer.new()
	skillContainer.add_child(skillHBox)
	var jobLabel = Label.new()
	jobLabel.text = toAdd.job_name
	jobLabel.size_flags_horizontal = Control.SIZE_EXPAND
	skillHBox.add_child(jobLabel)
	var buttonsContainer = HBoxContainer.new()
	skillHBox.add_child(buttonsContainer)
	var doNowButton = Button.new()
	doNowButton.text = "Do Now"
	doNowButton.set_meta("job", toAdd.job_name)
	doNowButton.pressed.connect(self.doNowPressed.bind(doNowButton.get_meta("job")))
	buttonsContainer.add_child(doNowButton)
	var queueButton = Button.new()
	queueButton.text = "Queue"
	queueButton.set_meta("job", toAdd.job_name)
	queueButton.pressed.connect(self.queuePresseed.bind(queueButton.get_meta("job")))
	buttonsContainer.add_child(queueButton)
	var skillProgress = ProgressBar.new()
	skillProgress.show_percentage = false
	var skillTimer = Timer.new()
	skillTimer.name = toAdd.job_name + " Timer"
	skillTimer.set_meta("job", toAdd.job_name)
	skillTimer.timeout.connect(self.timerEnded.bind(skillTimer.get_meta("job")))
	timers.set(toAdd.job_name, skillTimer)
	skillProgress.add_child(skillTimer)
	skillContainer.add_child(skillProgress)
	get_node("DungeonMarginContainer/DungeonContainer").add_child(skillContainer)
	toAdd.current_health = toAdd.max_health
	Globals.dungeons.set(dungeon_name, toAdd)
	
func doNowPressed(dungeonName):
	EventBus.action_played.emit(dungeonName)
	
func queuePresseed(dungeonName):
	EventBus.action_queued.emit(dungeonName)
	
func startTimer(dungeonName):
	var activeTimer = timers.get(dungeonName)
	activeTimer.name = dungeonName
	Globals.activeTimerProgressBar = activeTimer.get_parent()
	activeTimer.one_shot = true
	if activeTimer.paused == true:
		activeTimer.set_paused(false)
	else:
		activeTimer.start(Globals.allJobs.get(dungeonName).job_difficulty)
	Globals.activeTimerProgressBar.max_value = activeTimer.wait_time
	Globals.activeTimer = activeTimer
	
func timerEnded(dungeonName):
	var dungeonDefeated = Globals.dungeons[dungeonName]
	var newHealth = dungeonDefeated.current_health - 5
	Globals.dungeons[dungeonName].current_health = newHealth
	Globals.activeTimerProgressBar.value = 0
	Globals.activeTimerProgressBar = null
	var nextDungeon = Globals.dungeons[dungeonName].next_dungeon
	if nextDungeon.is_empty() == false and Globals.activeDungeons.has(nextDungeon) == false:
		addDungeonToPanel(nextDungeon)
		EventBus.dungeon_added.emit(nextDungeon)
	EventBus.dungeon_finished.emit(dungeonName)
	EventBus.action_finished.emit(dungeonName)

func createTooltipString(dungeonName) -> String:
	var toolTipString = "Required Items:\n"
	for item in Globals.allJobs.get(dungeonName).required_items:
		toolTipString += item + ": " + str(Globals.allJobs.get(dungeonName).required_items[item]) + "\n"
	return toolTipString
