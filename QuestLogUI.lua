-- QuestLogUI: eigen questlog, zoekt en toont questdoelen; L en microknop worden omgeleid.
local NS=QuestSync
function NS.OpenQuest(id) NS.OpenQuestLog(); if id then C_QuestLog.SetSelectedQuest(id); NS.selected=id; NS.RefreshQuestDetail() end end
function NS.OpenQuestLog() if not NS.questWindow then NS.CreateQuestWindow() end; NS.questWindow:Show(); NS.RefreshQuestList() end
function NS.CreateQuestWindow()
 local f=NS.Panel(UIParent,820,520); f:SetPoint("CENTER"); f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton"); f:SetScript("OnDragStart",f.StartMoving); f:SetScript("OnDragStop",f.StopMovingOrSizing); f:SetFrameStrata("DIALOG"); f.name="QuestSyncQuestLog"; tinsert(UISpecialFrames,f.name)
 local title=NS.Label(f,"Questlog",18); title:SetPoint("TOPLEFT",18,-14); local close=NS.Button(f,"Sluiten",72,function() f:Hide() end); close:SetPoint("TOPRIGHT",-14,-10)
 local search=CreateFrame("EditBox",nil,f,"InputBoxTemplate"); search:SetSize(220,24); search:SetPoint("TOPLEFT",18,-48); search:SetAutoFocus(false); search:SetScript("OnTextChanged",function() NS.RefreshQuestList() end); f.search=search
 local list=NS.Panel(f,270,430); list:SetPoint("TOPLEFT",18,-82); f.list=list
 local detail=NS.Panel(f,490,430); detail:SetPoint("TOPLEFT",300,-82); f.detail=detail; f.detailText=NS.Label(detail,"Selecteer een quest",14,true); f.detailText:SetPoint("TOPLEFT",14,-14); f.detailText:SetWidth(455); f.detailText:SetJustifyH("LEFT"); f:Hide(); NS.questWindow=f
end
function NS.RefreshQuestList()
 if not NS.questWindow then return end; NS.RefreshQuests(); local f=NS.questWindow; for _,v in ipairs(f.items or {}) do v:Hide() end; f.items={}; local y=-8; local query=string.lower(f.search:GetText() or "")
 for id,q in pairs(NS.quests) do if query=="" or string.find(string.lower(q.title),query,1,true) then local b=NS.Button(f.list,(q.watch and "✓ " or "").."["..q.level.."] "..q.title,242,function() NS.selected=id; NS.RefreshQuestDetail() end); b:SetPoint("TOPLEFT",8,y); b:SetScript("OnMouseUp",function(_,button) if button=="RightButton" then NS.Track(id,not q.watch) elseif button=="MiddleButton" then NS.ShareQuest(id) end end); f.items[#f.items+1]=b; y=y-30 end end
end
function NS.RefreshQuestDetail()
 local f=NS.questWindow; if not f or not NS.selected then return end; local q=NS.quests[NS.selected]; if not q then return end; f.detailText:SetText(q.title.."  ["..q.level.."]"..(q.private and "  persoonlijk" or "").."\n\n"..(q.complete and "Voltooid" or "Actief")); local y=-82
 for _,o in ipairs(q.objectives) do local l=NS.Label(f.detail,(o.text or "Doel").."  "..o.numFulfilled.."/"..o.numRequired,13,true); l:SetPoint("TOPLEFT",14,y); y=y-23 end
 local track=NS.Button(f.detail,q.watch and "Niet meer volgen" or "Volgen",130,function() NS.Track(q.id,not q.watch); NS.RefreshQuestDetail() end); track:SetPoint("BOTTOMLEFT",14,14)
 local share=NS.Button(f.detail,"Deel met party",130,function() NS.ShareQuest(q.id) end); share:SetPoint("LEFT",track,"RIGHT",8,0); if q.private then share:Disable(); share:SetAlpha(.45) end
end
function NS.HookQuestLog()
 SetCVar("questLogOpen","0"); local names={"WorldMapFrame.SidePanelToggle","QuestLogCount","QuestMapFrame"}; for _,n in ipairs(names) do local x=_G; for p in string.gmatch(n,"[^%.]+") do x=x and x[p] end; if x then if x.SetAlpha then x:SetAlpha(0) end; if x.Hide then x:Hide() end end end
 local orig=ToggleQuestLog; NS.originalToggleQuestLog=orig; ToggleQuestLog=function() NS.OpenQuestLog() end
 if QuestLogMicroButton then QuestLogMicroButton:RegisterForClicks("LeftButtonUp","RightButtonUp"); QuestLogMicroButton:SetScript("OnClick",function(_,button) if button=="LeftButton" then NS.OpenQuestLog() end end) end
 local btn=CreateFrame("Button","QuestSyncBindingButton",UIParent); btn:SetScript("OnClick",NS.OpenQuestLog); btn:Hide(); local function bind() ClearOverrideBindings(btn); local a,b=GetBindingKey("TOGGLEQUESTLOG"); if a then SetOverrideBindingClick(btn,false,a,"QuestSyncBindingButton") end; if b then SetOverrideBindingClick(btn,false,b,"QuestSyncBindingButton") end end; bind(); local e=CreateFrame("Frame"); e:RegisterEvent("UPDATE_BINDINGS"); e:SetScript("OnEvent",bind)
end
local ev=CreateFrame("Frame"); for _,e in ipairs({"QUEST_LOG_UPDATE","QUEST_WATCH_LIST_CHANGED","QUEST_ACCEPTED","QUEST_REMOVED","QUEST_TURNED_IN","UNIT_QUEST_LOG_CHANGED"}) do ev:RegisterEvent(e) end; ev:SetScript("OnEvent",function() NS.RefreshQuests(); if NS.RefreshTracker then NS.RefreshTracker() end; if NS.questWindow and NS.questWindow:IsShown() then NS.RefreshQuestList() end; if NS.SendSnapshot then NS.SendSnapshot() end end)
