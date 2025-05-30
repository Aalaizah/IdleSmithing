extends PanelContainer
var currentQueueArray = []

func _ready():
	EventBus.queue_increased.connect(addJobToPanelFront)
	EventBus.queue_increased_back.connect(addJobToPanel)
	EventBus.queue_decreased.connect(removeJobFromPanel)

func addJobToPanelFront(job: String):
	if currentQueueArray.size() > 0:
		var currentlyQueuedJob = currentQueueArray[0]
		var jobLoc = Globals.jobQueue.find(job)
		get_node("ActionMarginContainer/ActionPanelContainer").move_child(currentlyQueuedJob, 2)
	var toAdd = Globals.allJobs.get(job)
	var skillContainer = VBoxContainer.new()
	skillContainer.name = job
	skillContainer.set_meta("job", job)
	var skillHBox = HBoxContainer.new()
	skillContainer.add_child(skillHBox)
	var jobLabel = Label.new()
	jobLabel.text = toAdd.job_name
	jobLabel.size_flags_horizontal = Control.SIZE_EXPAND
	skillHBox.add_child(jobLabel)
	var removeButton = Button.new()
	removeButton.text = "Remove"
	removeButton.set_meta("job", toAdd.job_name)
	removeButton.set_meta("parent", skillContainer)
	removeButton.pressed.connect(self.removeJobFromPanelButton.bind(removeButton.get_meta("job"), 
		removeButton.get_meta("parent")))
	skillHBox.add_child(removeButton)
	get_node("ActionMarginContainer/ActionPanelContainer").add_child(skillContainer)
	currentQueueArray.push_front(skillContainer)
	get_node("ActionMarginContainer/ActionPanelContainer").move_child(skillContainer, 2)
	
func addJobToPanel(job: String):
	var toAdd = Globals.allJobs.get(job)
	var skillContainer = VBoxContainer.new()
	skillContainer.name = job
	skillContainer.set_meta("job", job)
	var skillHBox = HBoxContainer.new()
	skillContainer.add_child(skillHBox)
	var jobLabel = Label.new()
	jobLabel.text = toAdd.job_name
	jobLabel.size_flags_horizontal = Control.SIZE_EXPAND
	skillHBox.add_child(jobLabel)
	var removeButton = Button.new()
	removeButton.text = "Remove"
	removeButton.set_meta("job", toAdd.job_name)
	removeButton.set_meta("parent", skillContainer)
	removeButton.pressed.connect(self.removeJobFromPanelButton.bind(removeButton.get_meta("job"), 
		removeButton.get_meta("parent")))
	skillHBox.add_child(removeButton)
	get_node("ActionMarginContainer/ActionPanelContainer").add_child(skillContainer)
	currentQueueArray.append(skillContainer)

func removeJobFromPanel(jobName):
	if currentQueueArray.size() > 0:
		var parentNode = currentQueueArray[0]
		if parentNode.get_meta("job") == jobName:
			parentNode.queue_free()
			currentQueueArray.pop_front()
	
func removeJobFromPanelButton(jobName, parentNode):
	parentNode.queue_free()
	EventBus.job_removed.emit(jobName)
