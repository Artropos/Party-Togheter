-- Core: initialisatie, migratie, privacy-class quests en commando's.
local NS=QuestSync
NS.VERSION="1"; NS.PREFIX="QuestSync"; NS.players={}; NS.quests={}; NS.claims={}; NS.channel=nil; NS.seq=0
function NS.Migrate()
 QuestSyncDB=QuestSyncDB or {}; local d=QuestSyncDB; d.version=1; d.options=d.options or {autoAccept=true,autoNPC=false,autoShare=true,notices=true,sharePosition=true}; d.permanent=d.permanent or {}; d.position=d.position or {}; d.lastCode=d.lastCode or nil
end
function NS.IsPrivate(qid)
 if not qid or not C_QuestLog or not C_QuestLog.GetQuestTagInfo then return false end
 local t=C_QuestLog.GetQuestTagInfo(qid); if not t then return false end
 if Enum and Enum.QuestTag and Enum.QuestTag.Class and t.tagID==Enum.QuestTag.Class then return true end
 return t.tagName and (string.lower(t.tagName)=="class" or string.find(string.lower(t.tagName),"class",1,true)~=nil) or false
end
function NS.PlayerName() return UnitName("player") or "Speler" end
function NS.Command(msg)
 local a={}; for v in string.gmatch(msg or "","%S+") do a[#a+1]=v end
 local cmd=string.lower(a[1] or "")
 if cmd=="create" then NS.CreateSession() elseif cmd=="join" and a[2] then NS.JoinSession(a[2]) elseif cmd=="leave" then NS.LeaveSession() elseif cmd=="probe" then print("QuestSync: /qs probe") else NS.OpenSync() end
end
local boot=CreateFrame("Frame"); boot:RegisterEvent("PLAYER_LOGIN"); boot:SetScript("OnEvent",function()
 NS.Migrate(); if NS.Initialize then NS.Initialize() end
end)
function NS.Initialize()
 C_ChatInfo.RegisterAddonMessagePrefix(NS.PREFIX); NS.HookQuestLog(); NS.RefreshQuests(); if NS.BuildTracker then NS.BuildTracker() end
 local ev=CreateFrame("Frame"); ev:RegisterEvent("PLAYER_ENTERING_WORLD"); ev:RegisterEvent("PLAYER_REGEN_ENABLED"); ev:SetScript("OnEvent",function(_,event) if event=="PLAYER_ENTERING_WORLD" then if QuestSyncDB.lastCode and not NS.channel then NS.JoinSession(QuestSyncDB.lastCode) end; NS.RefreshQuests() else NS.Flush() end end)
 if NS.DrawPins then for _,m in pairs(QuestSyncDB.permanent) do NS.markers[m.id]=m end; NS.DrawPins() end
end
