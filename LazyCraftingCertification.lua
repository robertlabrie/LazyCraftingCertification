LazyCraftingCertification = {}
 
LazyCraftingCertification.name = "LazyCraftingCertification"
local function LCCGetCurrentPlayerRacialStyleId()
  -- we need the pattern ID for the current character race since it'll know that pattern by default
  local characterId = GetCurrentCharacterId()
  for i = 1, GetNumCharacters() do
    local name, gender, level, classId, raceId, alliance, id, locationId = GetCharacterInfo(i)
    if (characterId == id) then
      if raceId == 10 then return 34 end -- imperial
      return raceId
    end
 end
end
 
function LazyCraftingCertification.Initialize()
    LazyCraftingCertification.LLC = LibLazyCrafting:AddRequestingAddon(LazyCraftingCertification.name, true, function()end)
    LazyCraftingCertification.styleId = LCCGetCurrentPlayerRacialStyleId()
end
 
function LazyCraftingCertification.OnAddOnLoaded(event, addonName)
  d("addon loaded: " .. addonName)
  if addonName == LazyCraftingCertification.name then
    LazyCraftingCertification.Initialize()
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
local function LCCDeconstructFirstMatchingBackpackItem(q)
  slotIndex = LCCGetBackbackSlotByItemName(q)
  PrepareDeconstructMessage()
  AddItemToDeconstructMessage(BAG_BACKPACK,slotIndex,1)
  SendDeconstructMessage()

end
local function LCCCheckCertificationQuest()
  local count = GetNumJournalQuests()
  for i = 1, count do
    local name = GetJournalQuestName(i)
    if (string.find(name,"Certification")) then
      return true
    end
  end
  return false
end
function LazyCraftingCertification.CraftingStation(eventCode, craftSkill, sameStation)
  -- d("opened crafting station sameStation:" .. tostring(sameStation))
  local count = GetNumJournalQuests()
  for i = 1, count do
    local name = GetJournalQuestName(i)
    if (string.find(name,"Certification")) then
      local questName, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText, completed, tracked, questLevel, pushed, questType,_ = GetJournalQuestInfo(i)
      -- local LLC = LibLazyCrafting:AddRequestingAddon(LazyCraftingCertification.name, true, function()end)
      -- d("questName:" .. questName .. " activeStepType:" .. activeStepType .. " activeStepText:" .. activeStepText)

      if craftSkill == CRAFTING_TYPE_PROVISIONING then
        LazyCraftingCertification.LLC:CraftProvisioningItemByRecipeId(45911) -- roast pig
      end
      if craftSkill == CRAFTING_TYPE_ENCHANTING then
        LazyCraftingCertification.LLC:CraftEnchantingItemId(45855, 45831, 45850) -- jora, oko, ta
      end
      if craftSkill == CRAFTING_TYPE_ALCHEMY then
        LazyCraftingCertification.LLC:CraftAlchemyItemId(883, 30164,30163,nil, 1, true,'1')
      end
      if craftSkill == CRAFTING_TYPE_CLOTHIER then
        if (string.find(activeStepText,"craft")) then
          LazyCraftingCertification.LLC:CraftSmithingItemByLevel(4, false, 1,LazyCraftingCertification.styleId ,1 ,false, CRAFTING_TYPE_CLOTHIER, 0, 1,true) 
        end
        if (string.find(activeStepText,"deconstruct")) then
          LCCDeconstructFirstMatchingBackpackItem("Homespun Gloves")
        end
      end
      if craftSkill == CRAFTING_TYPE_BLACKSMITHING then
        if (string.find(activeStepText,"craft")) then
          LazyCraftingCertification.LLC:CraftSmithingItemByLevel(7, false, 1,LazyCraftingCertification.styleId ,1 ,false, CRAFTING_TYPE_BLACKSMITHING, 0, 1,true) 
        end
        if (string.find(activeStepText,"deconstruct")) then
          LCCDeconstructFirstMatchingBackpackItem("Iron Dagger")
        end
      end
      if craftSkill == CRAFTING_TYPE_WOODWORKING then
        if (string.find(activeStepText,"craft")) then
          LazyCraftingCertification.LLC:CraftSmithingItemByLevel(1, false, 1,LazyCraftingCertification.styleId ,1 ,false, CRAFTING_TYPE_WOODWORKING, 0, 1,true) 
        end
        if (string.find(activeStepText,"deconstruct")) then
          LCCDeconstructFirstMatchingBackpackItem("Maple Bow")
        end
      end
      if craftSkill == CRAFTING_TYPE_JEWELRYCRAFTING then
        if (string.find(activeStepText,"craft and deliver")) then --the word "craft" appears in the decon step
          LazyCraftingCertification.LLC:CraftSmithingItemByLevel(1, false, 1,LazyCraftingCertification.styleId ,1 ,false, CRAFTING_TYPE_JEWELRYCRAFTING, 0, 1,true) 
        end
        if (string.find(activeStepText,"deconstruct")) then
          LCCDeconstructFirstMatchingBackpackItem("Pewter Ring")
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

EVENT_MANAGER:RegisterForEvent(LazyCraftingCertification.name, EVENT_ADD_ON_LOADED, LazyCraftingCertification.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(LazyCraftingCertification.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, LazyCraftingCertification.InventoryChange)
EVENT_MANAGER:AddFilterForEvent(LazyCraftingCertification.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
EVENT_MANAGER:AddFilterForEvent(LazyCraftingCertification.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
EVENT_MANAGER:AddFilterForEvent(LazyCraftingCertification.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
EVENT_MANAGER:RegisterForEvent(LazyCraftingCertification.name, EVENT_CRAFTING_STATION_INTERACT, LazyCraftingCertification.CraftingStation)

-- SLASH_COMMANDS["/lcc"] = LCCScratch