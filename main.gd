extends Node
var jobPanel


func _ready() -> void:
	load_data()
	EventBus.action_played.connect(start_now)
	EventBus.action_queued.connect(add_to_queue)
	EventBus.action_finished.connect(collect_item)
	
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
		Globals.activeTimer.stop()
		Globals.jobTimers.set(jobName, Globals.activeTimer)
	#start job timer
	Globals.jobQueue.push_front(jobName)
	EventBus.action_started.emit(jobName)
	
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
		if Globals.jobQueue.size() > 0:
			EventBus.action_started.emit(Globals.jobQueue[0])
	else:
		EventBus.action_started.emit(jobName)
	
func add_to_queue(jobName):
	Globals.jobQueue.push_back(jobName)
	update_queue(jobName)
	
func check_for_full_inventory(itemName) -> bool:
	var currentItemCount = Globals.inventory.get(itemName)
	if currentItemCount == null:
		return false
	elif currentItemCount < Globals.maxItemCount:
		return false
	return true
