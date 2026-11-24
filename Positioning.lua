-- Positioning: deelt alleen niet-groepsleden; wereldpositie en minimapblips op basis van UnitPosition.
local NS=QuestSync
NS.remotePositions={}
function NS.UpdatePosition(sender,p) local x,y,inst=string.match(p,"^([^:]+):([^:]+):([^:]+)$"); if x then NS.remotePositions[sender]={x=tonumber(x),y=tonumber(y),instance=tonumber(inst),time=GetTime()} end end
function NS.DrawPositions() if not Minimap then return end; NS.blips=NS.blips or {}; local px,py,_,inst=UnitPosition("player"); if not px then return end
 for name,pos in pairs(NS.remotePositions) do if not UnitInParty(name) and not UnitInRaid(name) and pos.instance==inst then local b=NS.blips[name]; if not b then b=CreateFrame("Frame",nil,Minimap); b:SetSize(14,14); b.t=b:CreateTexture(nil,"OVERLAY"); b.t:SetAllPoints(); b.t:SetTexture("Interface\\AddOns\\QuestSync\\Media\\blip"); NS.blips[name]=b end
  local dx,dy=pos.x-px,-(pos.y-py); local scale=Minimap:GetZoomLevels() or 1; local radius=1000/(scale+1); local angle=math.atan2(dy,dx); local dist=math.sqrt(dx*dx+dy*dy); local r=math.min(dist,radius); b:ClearAllPoints(); b:SetPoint("CENTER",Minimap,"CENTER",math.cos(angle)*r/12,math.sin(angle)*r/12); b:Show()
 end end
end
local ticker=C_Timer.NewTicker(1,function() if not NS.channel or not QuestSyncDB.options.sharePosition or InCombatLockdown() then NS.DrawPositions(); return end; local x,y,_,inst=UnitPosition("player"); if x then local p=NS.lastPos; if not p or (x-p.x)^2+(y-p.y)^2>25 then NS.Send("P",x..":"..y..":"..inst); NS.lastPos={x=x,y=y} end end; NS.DrawPositions() end)
