extends Control;


func _ready():
	

	# prepare inventory items and slots
	RPG_InventoryCommon.Prepare()

		
	# add items to inventory (for testing purpose only)
	RPG_InventoryCommon.AddItemToInventory(0,0)
	RPG_InventoryCommon.AddItemToInventory(1,1)
	RPG_InventoryCommon.AddItemToInventory(2,2)
	RPG_InventoryCommon.AddItemToInventory(4,3)
	RPG_InventoryCommon.AddItemToInventory(RPG_InventoryCommon.GetFreeSlotID(),4)
	RPG_InventoryCommon.AddItemToInventory(10,5)
	
	
	
	# item icon origin
	RPG_InventoryCommon.iconOffset = Vector2(8,8)


	pass

func _input(event):
	
	
	
	if RPG_InventoryCommon.holdingItem != null && RPG_InventoryCommon.holdingItem.picked:		
		RPG_InventoryCommon.SetHoldingItemPosition(event.position)
		pass

func _gui_input(event):
	
	# LEFT MOUSE BUTTON PRESSED
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed and RPG_InventoryCommon.disableInventory==false:
		# check item under mouse cursor
		RPG_InventoryCommon.CheckItemUnderMouse()
		
		# if item is picked ...
		if RPG_InventoryCommon.holdingItem != null:
			# put on full slot => SWAP items
			if RPG_InventoryCommon.clickedSlot.item != null: RPG_InventoryCommon.SwapItemsInSlot()
			# put on empty slot => INSERT item
			else: RPG_InventoryCommon.PutHoldingItemToSlot()
		# if item isn't picked => pickup new one
		elif RPG_InventoryCommon.clickedSlot.item != null: RPG_InventoryCommon.PickItemFromSlot()
		pass
	
	# RIGHT MOUSE BUTTON PRESSED
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
		
		RPG_InventoryCommon.CheckItemUnderMouse()
		# show button panel only for when mouse is over inventory slot with item
		if RPG_InventoryCommon.clickedSlot != null and RPG_InventoryCommon.clickedSlot.slotType == "InventorySlot":
			RPG_InventoryCommon.ShowCommands()
		
		pass