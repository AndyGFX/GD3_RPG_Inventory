# --------------------------------------------------------------
# add script to ProjectSetting/Autoload as RPG_InventoryCommon 
# --------------------------------------------------------------

extends Node

#const

const SAVE_PATH = "res://ItemsDictionary.json"
const INVENTORY_SLOTS_COUNT = 24
const EQUIPMENT_SLOTS_COUNT = 6
const ItemClass 	= preload("res://RPG Inventory/Scripts/Item/RPG_Item.gd");
const ItemSlotClass = preload("res://RPG Inventory/Scripts/Slot/RPG_ItemSlot.gd");
const slotTexture 	= preload("res://RPG Inventory/Sprites/Inventory_EmptyItemSlot.png");


# item icon list
const itemImages = [
	preload("res://RPG Inventory/Sprites/item_0.png"),
	preload("res://RPG Inventory/Sprites/item_1.png"),
	preload("res://RPG Inventory/Sprites/item_2.png"),
	preload("res://RPG Inventory/Sprites/item_3.png"),
	preload("res://RPG Inventory/Sprites/item_4.png"),
	preload("res://RPG Inventory/Sprites/item_5.png"),
	preload("res://RPG Inventory/Sprites/item_6.png"),
	preload("res://RPG Inventory/Sprites/item_7.png")
];

# item definitions
const itemDictionary = {
	0: {
		"itemName": "Item_0",
		"itemValue": 456,
		"itemIcon": itemImages[0],
		"itemDesc": "MAX ARMOR +100",
		"script" : "res://RPG Inventory/Scripts/UserItemsClass/Item_0.gd"
	},
	1: {
		"itemName": "Item_1",
		"itemValue": 100,
		"itemIcon": itemImages[1],
		"itemDesc": "MAX SPEED +50",
		"script" : "res://RPG Inventory/Scripts/UserItemsClass/Item_1.gd"
	},
	2: {
		"itemName": "Item_2",
		"itemValue": 23,
		"itemIcon": itemImages[2],
		"itemDesc": "MAX ENERGY +50",
		"script" : "res://RPG Inventory/Scripts/UserItemsClass/Item_2.gd"
	},
	3: {
		"itemName": "Item_3",
		"itemValue": 56,
		"itemIcon": itemImages[3],
		"itemDesc": "MAX HP +30 or HP +100",
		"script" : "res://RPG Inventory/Scripts/UserItemsClass/Item_3.gd"
	},
	4: {
		"itemName": "Item_4",
		"itemValue": 2,
		"itemIcon": itemImages[4],
		"itemDesc": "item desc 4",
		"script" : "res://RPG Inventory/Scripts/UserItemsClass/Item_4.gd"
	},
	5: {
		"itemName": "Item_5",
		"itemValue": 78,
		"itemIcon": itemImages[5],
		"itemDesc": "item desc 5",
		"script" : "res://RPG Inventory/Scripts/UserItemsClass/Item_5.gd"
	},
};

var slotList = Array();

# list of all avaiable
var itemList = Array();

var holdingItem = null;
var clickedSlot = null;
var iconOffset = Vector2(0,0)
var commandsPanel = null
var debug = true;
var disableInventory = false;

# -------------------------------------------------------------------------------
# Prepare items data and slots
# -------------------------------------------------------------------------------
func Prepare():
	# prepare all items
	for item in self.itemDictionary:
		var itemName = self.itemDictionary[item].itemName;
		var itemIcon = self.itemDictionary[item].itemIcon;
		var itemValue = self.itemDictionary[item].itemValue;
		var itemDesc = self.itemDictionary[item].itemDesc;
		var itemClass = load(self.itemDictionary[item].script).new()
		itemClass.Init(itemName, itemIcon, null, itemValue, itemDesc)
		self.itemList.append(itemClass);
	
	# find all Inventory item slots
	for i in range(self.INVENTORY_SLOTS_COUNT):
		var slot = Utils.find_node("InventoryEmptySlot "+str(i));
		slot.slotType = "InventorySlot"
		self.slotList.append(slot);
		
	# find all Equipment item slots
	for i in range(self.EQUIPMENT_SLOTS_COUNT):
		var slot = Utils.find_node("EquipmentEmptySlot "+str(i));
		slot.slotType = "EquipmentSlot"
		self.slotList.append(slot);
		
	self.commandsPanel = Utils.find_node("ItemCommandsPanel");
	pass


# -------------------------------------------------------------------------------
# Add item[id] to inventory at slot[id]
# -------------------------------------------------------------------------------
func AddItemToInventory(slotID,itemID):
	self.slotList[slotID].SetItem(self.itemList[itemID]);
	pass


# -------------------------------------------------------------------------------
# Find item by itemName from Item definition list [itemDictionary]
# -------------------------------------------------------------------------------
func GetItemByName(name):
	var idx = -1
	for i in range(self.INVENTORY_SLOTS_COUNT):
		if self.itemDictionary[i].itemName == name : return i
	return idx
	
# -------------------------------------------------------------------------------
# Find next free slot's index
# -------------------------------------------------------------------------------
func GetFreeSlotID():
	
	var idx = -1
	
	for i in range(self.INVENTORY_SLOTS_COUNT):
		if self.slotList[i].IsFree(): return i
	return idx
	
# -------------------------------------------------------------------------------
# Set holding item to middle under mouse cursor (cursor is hiden)
# -------------------------------------------------------------------------------
func SetHoldingItemPosition(pos):
	self.holdingItem.rect_global_position = Vector2(pos.x-self.iconOffset.x, pos.y-self.iconOffset.y);
	pass
	
# -------------------------------------------------------------------------------
# Check slot under mouse cursor
# -------------------------------------------------------------------------------
func CheckItemUnderMouse():

	for slot in self.slotList:
		var slotMousePos = slot.get_local_mouse_position();
		var slotTexture = slot.texture;
		var isClicked = slotMousePos.x >= 0 && slotMousePos.x <= slotTexture.get_width() && slotMousePos.y >= 0 && slotMousePos.y <= slotTexture.get_height();

		if isClicked: 
			self.clickedSlot = slot;
	pass
	
# -------------------------------------------------------------------------------
# PUT item to slot
# -------------------------------------------------------------------------------
func PutHoldingItemToSlot():
	self.clickedSlot.PutItemToSlot(self.holdingItem);
	self.holdingItem = null;
	if debug: print("Put holding item to slot")
	pass

# -------------------------------------------------------------------------------
# PICK item from slot
# -------------------------------------------------------------------------------
func PickItemFromSlot():
	self.holdingItem = self.clickedSlot.item;
	self.clickedSlot.PickItemFromSlot();
	self.SetHoldingItemPosition(Vector2(-1000,1000))
	if debug: print("Pick item from slot")
	pass

# -------------------------------------------------------------------------------
# SWAP items between slots
# -------------------------------------------------------------------------------
func SwapItemsInSlot():
	var tempItem = self.clickedSlot.item;
	var oldSlot = self.slotList[self.slotList.find(self.holdingItem.itemSlot)];
	self.clickedSlot.PickItemFromSlot();
	self.clickedSlot.PutItemToSlot(self.holdingItem);
	self.holdingItem = null;
	oldSlot.PutItemToSlot(tempItem);	
	if debug: print("Swap items between slots")
	pass
	
# -------------------------------------------------------------------------------
# Show item commads panel
# -------------------------------------------------------------------------------
func ShowCommands():
	self.disableInventory = true
	self.commandsPanel.show()
	pass
	
# -------------------------------------------------------------------------------
# Hide item commads panel
# -------------------------------------------------------------------------------
func HideCommands():
	self.disableInventory = false
	self.commandsPanel.hide()
	pass	
	
# ---------------------------------------------------------
# Save itemDictionary data
# ---------------------------------------------------------
func Save():

	
	# Open the existing save file or create a new one in write mode
	var save_file = File.new()
	save_file.open(SAVE_PATH, File.WRITE)

	# converts to a JSON string. We store it in the save_file
	save_file.store_line(to_json(itemDictionary))
	# The change is automatically saved, so we close the file
	save_file.close()
	
	SaveSlots()
	print("Data saved.")


# ---------------------------------------------------------
# Save itemDictionary data
# ---------------------------------------------------------
func SaveSlots():

	var slots = Array()
	
	for slot in self.slotList:
		
		if slot.item!=null:			
			var slotIndex = slot.slotIndex
			var slotType = slot.slotType
			var itemName = slot.GetItem().get("itemName")
			
			var data = { 
				"slotIndex" : slotIndex,
				"slotType" : slotType,
				"itemName" : itemName,
				}
				
			slots.append(data)
		
	# Open the existing save file or create a new one in write mode
	var save_file = File.new()
	save_file.open("res://Slots.json", File.WRITE)

	# converts to a JSON string. We store it in the save_file
	save_file.store_line(to_json(slots))
	# The change is automatically saved, so we close the file
	save_file.close()
	print("Slots saved.")
	
# ---------------------------------------------------------
# Load itemDictionary data
# ---------------------------------------------------------
func Load():

	# When we load a file, we must check that it exists before we try to open it or it'll crash the game
	var load_file = File.new()
	if not load_file.file_exists(SAVE_PATH):
		print("The load file does not exist. Is created now.")
		self.Save();
		return

	load_file.open(SAVE_PATH, File.READ)
	itemDictionary = parse_json(load_file.get_as_text())
	