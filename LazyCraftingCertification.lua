LazyCraftingCertification = {}
 
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
LazyCraftingCertification.name = "Lazy Crafting Certification"
 
-- Next we create a function that will initialize our addon
function LazyCraftingCertification.Initialize()
  -- ...but we don't have anything to initialize yet. We'll come back to this.
end
 
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function LazyCraftingCertification.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == LazyCraftingCertification.name then
    LazyCraftingCertification.Initialize()
    --unregister the event again as our addon was loaded now and we do not need it anymore to be run for each other addon that will load
    EVENT_MANAGER:UnregisterForEvent(LazyCraftingCertification.name, EVENT_ADD_ON_LOADED)
  end
end
function LazyCraftingCertification.InventoryChange(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
  local link = GetItemLink(bagId, slotIndex)
  if (link == "|H0:item:55462:3:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h") then 
    local count = GetNumJournalQuests()
    for i = 1, count do
      local name = GetJournalQuestName(i)
      if (string.find(name,"Certification")) then
        CallSecureProtected("UseItem", bagId, slotIndex) -- learn the roast pig
      end
    end 
  end
end
local function LCCGetBackbackSlotByItemName(name)
  -- TODO: lazy - only checks backpack, returns first match so if you have an epic iron dagger with tri-stat on it ... why?
  local bagToScan = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)

  for index, slot in pairs(bagToScan) do
    if (slot.name == name) then
      return slot.slotIndex
    end
  end
  return nil
end
local function LCCGetCurrentPlayerRacialStyleId()
  -- we need the pattern ID for the current character race since it'll know that pattern by default
  -- TODO: this will probably break for imperials = imperial raceId = 10
  local characterId = GetCurrentCharacterId()
  for i = 1, GetNumCharacters() do
    local name, gender, level, classId, raceId, alliance, id, locationId = GetCharacterInfo(i)
    if (characterId == id) then
      if raceId == 10 then; return 34; end -- imperial
      return raceId
    end
 end
end

function LazyCraftingCertification.CraftingStation(eventCode, craftSkill, sameStation)
  -- d("opened crafting station sameStation:" .. tostring(sameStation))
  local count = GetNumJournalQuests()
  for i = 1, count do
    local name = GetJournalQuestName(i)
    if (string.find(name,"Certification")) then
      local questName, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText, completed, tracked, questLevel, pushed, questType,_ = GetJournalQuestInfo(i)
      -- d("questName:" .. questName .. " activeStepType:" .. activeStepType .. " activeStepText:" .. activeStepText)

      if craftSkill == CRAFTING_TYPE_PROVISIONING then
        LLC_Global:CraftProvisioningItemByRecipeId(45911) -- roast pig
      end
      if craftSkill == CRAFTING_TYPE_ENCHANTING then
        LLC_Global:CraftEnchantingItemId(45855, 45831, 45850) -- jora, oko, ta
      end
      if craftSkill == CRAFTING_TYPE_ALCHEMY then
        LLC_Global:CraftAlchemyItemId(883, 30164,30163,nil, 1, true,'1')
      end
      if craftSkill == CRAFTING_TYPE_CLOTHIER then
        if (string.find(activeStepText,"craft")) then
          LLC_Global:CraftSmithingItemByLevel(4, false, 1,LCCGetCurrentPlayerRacialStyleId() ,1 ,false, CRAFTING_TYPE_CLOTHIER, 0, 1,true) 
        end
        if (string.find(activeStepText,"deconstruct")) then
          slotIndex = LCCGetBackbackSlotByItemName("Homespun Gloves")
          PrepareDeconstructMessage()
          AddItemToDeconstructMessage(BAG_BACKPACK,slotIndex,1)
          SendDeconstructMessage()
        end
      end
      
      if craftSkill == CRAFTING_TYPE_BLACKSMITHING then
        if (string.find(activeStepText,"craft")) then
          LLC_Global:CraftSmithingItemByLevel(7, false, 1,LCCGetCurrentPlayerRacialStyleId() ,1 ,false, CRAFTING_TYPE_BLACKSMITHING, 0, 1,true) 
        end
        if (string.find(activeStepText,"deconstruct")) then
          slotIndex = LCCGetBackbackSlotByItemName("Iron Dagger")
          PrepareDeconstructMessage()
          AddItemToDeconstructMessage(BAG_BACKPACK,slotIndex,1)
          SendDeconstructMessage()
        end
      end
      if craftSkill == CRAFTING_TYPE_WOODWORKING then
        if (string.find(activeStepText,"craft")) then
          LLC_Global:CraftSmithingItemByLevel(1, false, 1,LCCGetCurrentPlayerRacialStyleId() ,1 ,false, CRAFTING_TYPE_WOODWORKING, 0, 1,true) 
        end
        if (string.find(activeStepText,"deconstruct")) then
          slotIndex = LCCGetBackbackSlotByItemName("Maple Bow")
          PrepareDeconstructMessage()
          AddItemToDeconstructMessage(BAG_BACKPACK,slotIndex,1)
          SendDeconstructMessage()
        end
      end
      if craftSkill == CRAFTING_TYPE_JEWELRYCRAFTING then
        if (string.find(activeStepText,"craft and deliver")) then --the word "craft" appears in the decon step
          LLC_Global:CraftSmithingItemByLevel(1, false, 1,LCCGetCurrentPlayerRacialStyleId() ,1 ,false, CRAFTING_TYPE_JEWELRYCRAFTING, 0, 1,true) 
        end
        if (string.find(activeStepText,"deconstruct")) then
          slotIndex = LCCGetBackbackSlotByItemName("Pewter Ring")
          PrepareDeconstructMessage()
          AddItemToDeconstructMessage(BAG_BACKPACK,slotIndex,1)
          SendDeconstructMessage()
        end
      end

      
      
      -- /script  local patternName, baseName, _, numMaterials, numTraitsRequired, numTraitsKnown, resultingItemFilterType = GetSmithingPatternInfo(3); d(patternName)
      -- /script  local name, gender, level, classId, raceId, alliance, id, locationId = GetCharacterInfo(1); d(raceId)
      -- /script LLC_Global:CraftSmithingItemByLevel(4, false, 1,5 ,1 ,false, CRAFTING_TYPE_CLOTHIER, 0, 1,true) 

    end
  end
end
local function LCCScratch()
end
-- Finally, we'll register our event handler function to be called when the proper event occurs.
-->This event EVENT_ADD_ON_LOADED will be called for EACH of the addns/libraries enabled, this is why there needs to be a check against the addon name
-->within your callback function! Else the very first addon loaded would run your code + all following addons too.
EVENT_MANAGER:RegisterForEvent(LazyCraftingCertification.name, EVENT_ADD_ON_LOADED, LazyCraftingCertification.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(LazyCraftingCertification.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, LazyCraftingCertification.InventoryChange)
EVENT_MANAGER:AddFilterForEvent(LazyCraftingCertification.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
EVENT_MANAGER:AddFilterForEvent(LazyCraftingCertification.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
EVENT_MANAGER:AddFilterForEvent(LazyCraftingCertification.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
EVENT_MANAGER:RegisterForEvent(LazyCraftingCertification.name, EVENT_CRAFTING_STATION_INTERACT, LazyCraftingCertification.CraftingStation)

-- SLASH_COMMANDS["/lcc"] = LCCScratch