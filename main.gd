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
		
	for dungeon in Globals.dungeonHealthBars:
		Globals.dungeonHealthBars[dungeon].value = Globals.dungeons[dungeon].current_health
	
func load_data():
	get_node("PanelContainer/VBoxContainer/DungeonPanel").addDungeonToPanel("Dungeon1")
	get_node("MapPanel").addDungeonToMap("Dungeon1")
	get_node("PanelContainer/VBoxContainer/jobPanel").addJobToPanel("Chop Poplar")
	get_node("PanelContainer/VBoxContainer/jobPanel").addJobToPanel("Mine Copper")
	get_node("PanelContainer/VBoxContainer/craftingPanel").addCraftToPanel("Craft Poplar Bow")
	get_node("PanelContainer/VBoxContainer/craftingPanel").addCraftToPanel("Smelt Copper Bar")
	get_node("PanelContainer/VBoxContainer/craftingPanel").addCraftToPanel("Forge Copper Dagger")
	get_node("PanelContainer/VBoxContainer/craftingPanel").addCraftToPanel("Forge Copper Sword")
	get_node("PanelContainer/VBoxContainer/craftingPanel").addCraftToPanel("Forge Copper Shield")
	get_node("PanelContainer/VBoxContainer/craftingPanel").addCraftToPanel("Smelt Iron Bar")

func start_now(jobName):
	var currentJob = Globals.allJobs.get(jobName)
	var itemCollected = currentJob.add_to_inventory
	if check_for_full_inventory(itemCollected):
		return
	if currentJob.job_type == 0:
		if Globals.jobQueue.size() > 0:
			Globals.activeTimer.set_paused(true)
			Globals.jobTimers.set(jobName, Globals.activeTimer)
		Globals.jobQueue.push_front(jobName)
		EventBus.action_started.emit(jobName)
		EventBus.queue_increased.emit(jobName)
	elif currentJob.job_type == 1:
		var craft_can_be_done = canBeCrafted(jobName)
		if craft_can_be_done == true:
			if Globals.jobQueue.size() > 0:
				Globals.activeTimer.set_paused(true)
				Globals.jobTimers.set(jobName, Globals.activeTimer)
			Globals.jobQueue.push_front(jobName)
			EventBus.craft_started.emit(jobName)
			EventBus.queue_increased.emit(jobName)
	elif currentJob.job_type == 2:
		var craft_can_be_done = canBeCrafted(jobName)
		if craft_can_be_done == true:
			if Globals.jobQueue.size() > 0:
				Globals.activeTimer.set_paused(true)
				Globals.jobTimers.set(jobName, Globals.activeTimer)
			Globals.jobQueue.push_front(jobName)
			EventBus.dungeon_started.emit(jobName)
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
	var jobType = Globals.allJobs.get(jobName).job_type
	var queueLength = Globals.jobQueue.size()
	if jobType == 1 or jobType == 2:
		remove_items_after_crafting(jobName)
	if check_for_full_inventory(itemCollected):
		Globals.jobQueue.pop_front()
		EventBus.queue_decreased.emit(jobName)
		queueLength = Globals.jobQueue.size()
		if queueLength > 0:
			start_next_job(Globals.jobQueue[0])
	else:
		if jobType == 0:
			EventBus.action_started.emit(jobName)
		elif jobType == 1:
			if canBeCrafted(jobName) == true:
				EventBus.craft_started.emit(jobName)
			elif queueLength > 0:
				start_next_job(Globals.jobQueue[0])
		elif jobType == 2:
			if canBeCrafted(jobName) == true:
				EventBus.dungeon_started.emit(jobName)
			elif queueLength > 0:
				start_next_job(Globals.jobQueue[0])

func start_next_job(jobName):
	var jobType = Globals.allJobs.get(Globals.jobQueue[0]).job_type
	if jobType == 0:
		EventBus.action_started.emit(Globals.jobQueue[0])
	elif jobType == 1:
		if canBeCrafted(jobName) == true:
			EventBus.craft_started.emit(jobName)
		else:
			Globals.jobQueue.pop_front()
			EventBus.queue_decreased.emit(jobName)
			if Globals.jobQueue.size() > 0:
				start_next_job(Globals.jobQueue[0])
	elif jobType == 2:
		if canBeCrafted(jobName) == true:
			EventBus.dungeon_started.emit(jobName)
		else:
			Globals.jobQueue.pop_front()
			EventBus.queue_decreased.emit(jobName)
			if Globals.jobQueue.size() > 0:
				start_next_job(Globals.jobQueue[0])
	
func add_to_queue(jobName):
	if Globals.jobQueue.has(jobName) == false:
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
		update_queue(Globals.jobQueue[0])
		
func canBeCrafted(itemName) -> bool:
	var currentJob = Globals.allJobs.get(itemName)
	var craft_can_be_done = false
	for item in currentJob.required_items:
		if Globals.inventory.has(item):
			if Globals.inventory[item] >= currentJob.required_items[item]:
				craft_can_be_done = true
	return craft_can_be_done

func remove_items_after_crafting(jobName):
	var currentJob = Globals.allJobs.get(jobName)
	for item in currentJob.required_items:
		var currentInventory = Globals.inventory[item] - currentJob.required_items[item]
		Globals.inventory.set(item, currentInventory)
		EventBus.inventory_decreased.emit(item)
		
