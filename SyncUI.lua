-- SyncUI: code, roster, questmatrix, claims en gedeelde sessie-instellingen.
local NS=QuestSync
function NS.OpenSync() if not NS.sync then NS.CreateSync() end; NS.sync:Show(); NS.UpdateSync() end
function NS.CreateSync()
 local f=NS.Panel(UIParent,650,430); f:SetPoint("CENTER"); f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton"); f:SetScript("OnDragStart",f.StartMoving); f:SetScript("OnDragStop",f.StopMovingOrSizing); f:SetFrameStrata("DIALOG")
 local title=NS.Label(f,"QuestSync — sessie",18); title:SetPoint("TOPLEFT",14,-12)
 local code=CreateFrame("EditBox",nil,f,"InputBoxTemplate"); code:SetSize(120,24); code:SetPoint("TOPLEFT",18,-46); code:SetAutoFocus(false); f.code=code
 local join=NS.Button(f,"Sluit aan",90,function() NS.JoinSession(code:GetText()) end); join:SetPoint("LEFT",code,"RIGHT",8,0); local create=NS.Button(f,"Nieuwe sessie",110,NS.CreateSession); create:SetPoint("LEFT",join,"RIGHT",5,0); local leave=NS.Button(f,"Verlaat",74,NS.LeaveSession); leave:SetPoint("LEFT",create,"RIGHT",5,0); local res=NS.Button(f,"Resync",74,function() NS.Send("R","") end); res:SetPoint("LEFT",leave,"RIGHT",5,0)
 local matrix=NS.Panel(f,610,320); matrix:SetPoint("TOPLEFT",18,-88); f.matrix=matrix; f:Hide(); NS.sync=f
end
function NS.UpdateSync()
 local f=NS.sync; if not f then return end; f.code:SetText(NS.code or QuestSyncDB.lastCode or ""); for _,v in ipairs(f.cells or {}) do v:Hide() end; f.cells={}; local players={NS.PlayerName()}; for n in pairs(NS.players) do if n~=NS.PlayerName() then players[#players+1]=n end end; local y=-10; local h=NS.Label(f.matrix,"Quest",14); h:SetPoint("TOPLEFT",8,y); for i,n in ipairs(players) do local l=NS.Label(f.matrix,n,12); l:SetPoint("TOPLEFT",220+(i-1)*95,y) end; y=y-25
 local union={}; for id,q in pairs(NS.quests) do if not q.private then union[id]=q end end; for _,p in pairs(NS.players) do for id in pairs(p.quests or {}) do if not union[id] then union[id]={id=id,title="Quest "..id} end end end
 for id,q in pairs(union) do local b=NS.Button(f.matrix,q.title,205,function() local n=NS.claims[id]==NS.PlayerName() and "-" or NS.PlayerName(); NS.Send("C",id.."|"..n); NS.claims[id]=n~="-" and n or nil; NS.UpdateSync() end); b:SetPoint("TOPLEFT",8,y); f.cells[#f.cells+1]=b; for i,n in ipairs(players) do local own=n==NS.PlayerName() and NS.quests[id] or (NS.players[n] and NS.players[n].quests[id]); local txt=own and (own.state=="d" and "✓" or (own.objectives or "•")) or "·"; local c=NS.Button(f.matrix,txt,88,function() if n==NS.PlayerName() then NS.Send("C",id.."|"..(NS.claims[id]==NS.PlayerName() and "-" or NS.PlayerName())) end end); c:SetPoint("TOPLEFT",220+(i-1)*95,y); if NS.claims[id]==n then c:SetBackdropBorderColor(1,.75,.1,1) end; f.cells[#f.cells+1]=c end; y=y-29 end
end
