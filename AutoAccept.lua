-- AutoAccept: nooit class-quests accepteren of remote-accept simuleren.
local NS=QuestSync
function NS.ShareQuest(id) if not id or NS.IsPrivate(id) then NS.Toast("Persoonlijke quests kunnen niet gedeeld worden."); return end; if not IsInGroup() then NS.Toast("Deel quests alleen via Blizzard in party/raid."); return end; C_QuestLog.SetSelectedQuest(id); if QuestLogPushQuest then QuestLogPushQuest() end end
local f=CreateFrame("Frame"); f:RegisterEvent("QUEST_DETAIL"); f:SetScript("OnEvent",function() if not QuestSyncDB.options.autoAccept or not GetQuestID then return end; local id=GetQuestID(); if id and not NS.IsPrivate(id) and AcceptQuest and not (InCombatLockdown and InCombatLockdown()) then AcceptQuest() end end)
