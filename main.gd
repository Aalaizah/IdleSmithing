extends Node
var jobPanel


func _ready() -> void:
	load_data()
	EventBus.action_played.connect(start_now)
	EventBus.action_queued.connect(add_to_queue)
	EventBus.action_finished.connect(collect_item)
	EventBus.job_removed.connect(pause_timer_after_queue_removal)
	
func _process(_delta: float) -> void:
	if Globals.activeTimerProgressBar != null:
		Globals.activeTimerProgressBar.value = Globals.activeTimer.wait_time - Globals.activeTimer.time_left
	
func load_data():
	get_node("jobPanel").addJobToPanel("Mine Coal")
	get_node("jobPanel").addJobToPanel("Mine Copper")

func start_now(jobName):
	var itemCollected = Globals.allJobs.get(jobName).add_to_inventory
	if check_for_full_inventory(itemCollected):
		return
	if Globals.jobQueue.size() > 0:
		Globals.activeTimer.set_paused(true)
		Globals.jobTimers.set(jobName, Globals.activeTimer)
	#start job timer
	Globals.jobQueue.push_front(jobName)
	EventBus.action_started.emit(jobName)
	EventBus.queue_increased.emit(jobName)
	
func collect_item(jobName):
	var itemCollected = Globals.allJobs.get(jobName).add_to_inventory
	var currentItemCount = Globals.inventory.get(itemCollected)
	if currentItemCount == null:
		currentItemCount = 0
	currentItemCount += 1
	Globals.inventory.set(itemCollected, currentItemCount)
	EventBus.inventory_increased.emit(itemCollected)
	update_queue(jobName)

func update_queue(jobName):
	var itemCollected = Globals.allJobs.get(jobName).add_to_inventory
	if check_for_full_inventory(itemCollected):
		Globals.jobQueue.pop_front()
		EventBus.queue_decreased.emit(jobName)
		if Globals.jobQueue.size() > 0:
			EventBus.action_started.emit(Globals.jobQueue[0])
	else:
		EventBus.action_started.emit(jobName)
	
func add_to_queue(jobName):
	Globals.jobQueue.push_back(jobName)
	EventBus.queue_increased_back.emit(jobName)
	
func check_for_full_inventory(itemName) -> bool:
	var currentItemCount = Globals.inventory.get(itemName)
	if currentItemCount == null:
		return false
	elif currentItemCount < Globals.maxItemCount:
		return false
	return true
	
func pause_timer_after_queue_removal(jobName):
	if Globals.activeTimer.name == jobName:
		Globals.jobQueue.erase(jobName)
		Globals.activeTimer.set_paused(true)
		Globals.activeTimerProgressBar = null
		Globals.activeTimer = null
	else:
		Globals.jobQueue.erase(jobName)
		return
	if Globals.jobQueue.size() > 0:
		update_queue(jobName)
