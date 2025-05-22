extends PanelContainer

func _ready():
	EventBus.inventory_increased.connect(addItemToInventoryPanel)

func addItemToInventoryPanel(item: String):
	var nodePath = "InventoryPanelContainer/" + item
	if get_node_or_null(nodePath) != null:
		var itemCountNodePath = nodePath + "/" + item + "HBox/ItemCount"
		var itemCount = get_node(itemCountNodePath)
		itemCount.text = str(Globals.inventory.get(item)) + " / " + str(Globals.maxItemCount)
	else:
		var itemContainer = VBoxContainer.new()
		itemContainer.name = item
		var itemHBox = HBoxContainer.new()
		itemHBox.name = item + "HBox"
		itemContainer.add_child(itemHBox)
		#var skillImage = TextureRect.new()
		#skillImage.size_flags_horizontal = Control.SIZE_EXPAND
		#skillImage.texture = toAdd.job_icon
		var itemNameLabel = Label.new()
		itemNameLabel.name = "ItemName"
		itemNameLabel.text = item
		itemNameLabel.size_flags_horizontal = Control.SIZE_EXPAND
		itemHBox.add_child(itemNameLabel)
		var itemCountLabel = Label.new()
		itemCountLabel.name = "ItemCount"
		var countText = str(Globals.inventory.get(item)) + " / " + str(Globals.maxItemCount)
		itemCountLabel.text = countText
		#jobLabel.text = toAdd.job_name
		itemCountLabel.size_flags_horizontal = Control.SIZE_EXPAND
		itemHBox.add_child(itemCountLabel)
		get_node("InventoryPanelContainer").add_child(itemContainer)
