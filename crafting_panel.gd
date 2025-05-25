extends PanelContainer

var activeCrafts = []
var timers = {}

func _ready():
	var loadCrafts = [
		load("res://crafting/copper_dagger.tres"),
		load("res://crafting/copper_bar.tres"),
		load("res://crafting/adamantite_bar.tres"),
		load("res://crafting/copper_shield.tres"),
		load("res://crafting/copper_sword.tres"),
		load("res://crafting/iron_bar.tres"),
		load("res://crafting/mythril_bar.tres"),
		load("res://crafting/poplar_bow.tres"),
		load("res://crafting/steel_bar.tres")
	]
	for craft in loadCrafts:
		Globals.allJobs.set(craft.job_name, craft)
		
	EventBus.craft_started.connect(startTimer)
		
func addCraftToPanel(craftName):
	var toAdd = Globals.allJobs.get(craftName)
	if Globals.activeDungeons.has(toAdd.related_dungeon) == true:
		return
	activeCrafts.append(toAdd)
	var skillContainer = VBoxContainer.new()
	skillContainer.name = craftName
	var tooltipString = createTooltipString(craftName)
	skillContainer.tooltip_text = tooltipString
	var skillHBox = HBoxContainer.new()
	skillContainer.add_child(skillHBox)
	var skillImage = TextureRect.new()
	skillImage.size_flags_horizontal = Control.SIZE_EXPAND
	skillImage.texture = toAdd.craft_icon
	skillHBox.add_child(skillImage)
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
	var skillTimer = Timer.new()
	skillTimer.name = toAdd.job_name + " Timer"
	skillTimer.set_meta("job", toAdd.job_name)
	skillTimer.timeout.connect(self.timerEnded.bind(skillTimer.get_meta("job")))
	timers.set(toAdd.job_name, skillTimer)
	skillProgress.add_child(skillTimer)
	skillContainer.add_child(skillProgress)
	get_node("CraftingMarginContainer/CraftingContainer").add_child(skillContainer)
	
func doNowPressed(craftName):
	EventBus.action_played.emit(craftName)
	
func queuePresseed(craftName):
	EventBus.action_queued.emit(craftName)
	
func startTimer(craftName):
	var activeTimer = timers.get(craftName)
	activeTimer.name = craftName
	Globals.activeTimerProgressBar = activeTimer.get_parent()
	activeTimer.one_shot = true
	if activeTimer.paused == true:
		activeTimer.set_paused(false)
	else:
		activeTimer.start(Globals.allJobs.get(craftName).job_difficulty)
	Globals.activeTimerProgressBar.max_value = activeTimer.wait_time
	Globals.activeTimer = activeTimer
	
func timerEnded(craftName):
	Globals.activeTimerProgressBar.value = 0
	Globals.activeTimerProgressBar = null
	EventBus.action_finished.emit(craftName)

func createTooltipString(craftName) -> String:
	var toolTipString = "Required Items:\n"
	for item in Globals.allJobs.get(craftName).required_items:
		toolTipString += item + ": " + str(Globals.allJobs.get(craftName).required_items[item]) + "\n"
	return toolTipString
