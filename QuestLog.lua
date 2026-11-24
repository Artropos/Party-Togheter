-- QuestLog: moderne questlog uitlezen; completion uitsluitend uit GetInfo-cache.
local NS=QuestSync
function NS.ReadQuests()
 local out={}; if not C_QuestLog or not C_QuestLog.GetNumQuestLogEntries then return out end
 for i=1,C_QuestLog.GetNumQuestLogEntries() do local v=C_QuestLog.GetInfo(i)
  if v and not v.isHeader and v.questID and not v.isHidden then
   local objs=C_QuestLog.GetQuestObjectives(v.questID) or {}; local o={}
   for _,x in ipairs(objs) do o[#o+1]={text=x.text or "",finished=x.finished,numFulfilled=x.numFulfilled or 0,numRequired=x.numRequired or 0} end
   out[v.questID]={id=v.questID,title=v.title or ("Quest "..v.questID),level=v.level or v.difficultyLevel or 0,complete=v.isComplete==1,objectives=o,private=NS.IsPrivate(v.questID),watch=C_QuestLog.GetQuestWatchType(v.questID)~=nil,zone=""}
  elseif v and v.isHeader then NS.zone=v.title or "" end
 end
 for _,v in pairs(out) do v.zone=NS.zone or "" end; return out
end
function NS.RefreshQuests()
 local old=NS.quests; NS.quests=NS.ReadQuests(); if NS.OnQuestData then NS.OnQuestData(old,NS.quests) end
end
