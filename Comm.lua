-- Comm: kanaal-only transport, 190-byte chunking, combat queue en herassemblage.
local NS=QuestSync
NS.outQueue=NS.outQueue or {}; NS.fragments={}; NS.lastSend=0
local function sendOne(msg)
 if InCombatLockdown and InCombatLockdown() then NS.outQueue[#NS.outQueue+1]=msg; return end
 if not NS.channel then return end
 C_ChatInfo.SendAddonMessage(NS.PREFIX,msg,"CHANNEL",NS.channel)
end
function NS.Send(kind,payload)
 if not NS.channel then return end
 local data=kind.."|"..(payload or "")
 if #data<=240 then sendOne(data); return end
 local id=tostring(math.floor((GetTime and GetTime() or 0)*1000))..tostring(math.random(10,99)); local size=190; local n=math.ceil(#data/size)
 for i=1,n do sendOne("#"..id.."|"..i.."|"..n.."|"..string.sub(data,(i-1)*size+1,i*size)) end
end
function NS.Flush()
 if InCombatLockdown and InCombatLockdown() then return end
 local msg=table.remove(NS.outQueue,1); if msg then if NS.channel then C_ChatInfo.SendAddonMessage(NS.PREFIX,msg,"CHANNEL",NS.channel) end; C_Timer.After(.11,NS.Flush) end
end
local f=CreateFrame("Frame"); f:RegisterEvent("CHAT_MSG_ADDON"); f:RegisterEvent("PLAYER_REGEN_ENABLED"); f:SetScript("OnEvent",function(_,event,...)
 if event=="PLAYER_REGEN_ENABLED" then NS.Flush(); if NS.DrawPins then NS.DrawPins() end; return end
 local p,m,dist,sender=...; if p~=NS.PREFIX or dist~="CHANNEL" or not NS.channel then return end
 if string.sub(m,1,1)=="#" then local id,i,n,d=string.match(m,"^#([^|]+)|(%d+)|(%d+)|(.*)$"); if not id then return end
  local r=NS.fragments[id] or {parts={},total=tonumber(n),sender=sender,time=GetTime()}; r.parts[tonumber(i)]=d; NS.fragments[id]=r
  local got=0; for _ in pairs(r.parts) do got=got+1 end; if got==r.total then local all=""; for j=1,r.total do all=all..(r.parts[j] or "") end; NS.fragments[id]=nil; NS.HandleMessage(all,sender) end; return end
 NS.HandleMessage(m,sender)
end)
C_Timer.NewTicker(10,function() for id,r in pairs(NS.fragments) do if GetTime()-r.time>10 then NS.fragments[id]=nil end end end)
