extends PanelContainer
var activeJobs = []
var timers = {}

func _ready():
	var loadJobs = [
		load("res://jobResources/mine_copper.tres"),
		load("res://jobResources/mine_coal.tres")
	]
	for job in loadJobs:
		Globals.allJobs.set(job.job_name, job)
		
	EventBus.action_started.connect(startTimer)

func addJobToPanel(job: String):
	var toAdd = Globals.allJobs.get(job)
	activeJobs.append(toAdd)
	var skillContainer = VBoxContainer.new()
	skillContainer.name = job
	var skillHBox = HBoxContainer.new()
	skillContainer.add_child(skillHBox)
	var skillImage = TextureRect.new()
	skillImage.size_flags_horizontal = Control.SIZE_EXPAND
	skillImage.texture = toAdd.job_icon
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
	get_node("JobMarginContainer/JobPanelContainer").add_child(skillContainer)
	
	
func doNowPressed(jobName):
	EventBus.action_played.emit(jobName)
	
func queuePresseed(jobName):
	EventBus.action_queued.emit(jobName)

func startTimer(jobName):
	var activeTimer = timers.get(jobName)
	activeTimer.name = jobName
	Globals.activeTimerProgressBar = activeTimer.get_parent()
	activeTimer.one_shot = true
	if activeTimer.paused == true:
		activeTimer.set_paused(false)
	else:
		activeTimer.start(Globals.allJobs.get(jobName).job_difficulty)
	Globals.activeTimerProgressBar.max_value = activeTimer.wait_time
	Globals.activeTimer = activeTimer
	
func timerEnded(jobName):
	Globals.activeTimerProgressBar.value = 0
	Globals.activeTimerProgressBar = null
	EventBus.action_finished.emit(jobName)
