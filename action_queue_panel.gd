extends PanelContainer
var currentQueue = {}
var currentQueueArray = []

func _ready():
	EventBus.queue_increased.connect(addJobToPanelFront)
	EventBus.queue_increased_back.connect(addJobToPanel)
	EventBus.queue_decreased.connect(removeJobFromPanel)

func addJobToPanelFront(job: String):
	var currentlyQueuedJob = currentQueue.get(job)
	if currentlyQueuedJob != null:
		var jobLoc = Globals.jobQueue.find(job)
		Globals.jobQueue.pop_at(jobLoc)
		get_node("ActionMarginContainer/ActionPanelContainer").move_child(currentlyQueuedJob, 2)
		return
	var toAdd = Globals.allJobs.get(job)
	var skillContainer = VBoxContainer.new()
	skillContainer.name = job
	var skillHBox = HBoxContainer.new()
	skillContainer.add_child(skillHBox)
	var jobLabel = Label.new()
	jobLabel.text = toAdd.job_name
	jobLabel.size_flags_horizontal = Control.SIZE_EXPAND
	skillHBox.add_child(jobLabel)
	var removeButton = Button.new()
	removeButton.text = "Remove"
	removeButton.set_meta("job", toAdd.job_name)
	removeButton.pressed.connect(self.removeJobFromPanelButton.bind(removeButton.get_meta("job")))
	skillHBox.add_child(removeButton)
	get_node("ActionMarginContainer/ActionPanelContainer").add_child(skillContainer)
	currentQueue.set(job, skillContainer)
	get_node("ActionMarginContainer/ActionPanelContainer").move_child(skillContainer, 2)
	
func addJobToPanel(job: String):
	var currentlyQueuedJob = currentQueue.get(job)
	if currentlyQueuedJob != null:
		return
	var toAdd = Globals.allJobs.get(job)
	var skillContainer = VBoxContainer.new()
	skillContainer.name = job
	var skillHBox = HBoxContainer.new()
	skillContainer.add_child(skillHBox)
	var jobLabel = Label.new()
	jobLabel.text = toAdd.job_name
	jobLabel.size_flags_horizontal = Control.SIZE_EXPAND
	skillHBox.add_child(jobLabel)
	var removeButton = Button.new()
	removeButton.text = "Remove"
	removeButton.set_meta("job", toAdd.job_name)
	removeButton.pressed.connect(self.removeJobFromPanelButton.bind(removeButton.get_meta("job")))
	skillHBox.add_child(removeButton)
	get_node("ActionMarginContainer/ActionPanelContainer").add_child(skillContainer)
	currentQueue.set(job, skillContainer)

func removeJobFromPanel(jobName):
	var toBeRemoved = currentQueue.get(jobName)
	var toBeRemovedParent = currentQueue.get(jobName).get_parent()
	currentQueue.erase(jobName)
	toBeRemovedParent.remove_child(toBeRemoved)
	toBeRemoved.queue_free()
	
func removeJobFromPanelButton(jobName):
	removeJobFromPanel(jobName)
	EventBus.job_removed.emit(jobName)
