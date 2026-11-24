-- MapPins: genormaliseerde wereldkaartpins; alleen eigen markers verwijderbaar.
local NS=QuestSync
NS.markers={}
function NS.AddMarker(map,x,y,label,permanent,owner,id)
 id=id or (owner..":"..tostring(GetTime())); local m={id=id,map=tonumber(map),x=tonumber(x),y=tonumber(y),label=label or "Plek",owner=owner,permanent=permanent}; NS.markers[id]=m
 if permanent and owner==NS.PlayerName() then QuestSyncDB.permanent[id]=m end; NS.DrawPins(); if owner~=NS.PlayerName() then local info=C_Map.GetMapInfo(m.map); NS.Toast((NS.code or "QuestSync")..": marker bij "..(info and info.name or m.label)); if PlaySound then PlaySound( SOUNDKIT and SOUNDKIT.RAID_WARNING or 8959) end end
end
function NS.DrawPins() if InCombatLockdown() or not WorldMapFrame or not WorldMapFrame.GetMapID then return end; if WorldMapFrame.AddDataProvider and NS.PinProvider and not NS.providerAdded then WorldMapFrame:AddDataProvider(NS.PinProvider); NS.providerAdded=true end; if NS.PinProvider and NS.PinProvider.RefreshAllData then NS.PinProvider:RefreshAllData() end end
function NS.ReceiveMarker(sender,p) local map,x,y,label,per=string.match(p,"^(%d+):([^:]+):([^:]+):([^|]+)|?(.*)$"); if map then NS.AddMarker(map,x,y,label,per=="p",sender) end end
if MapCanvasPinMixin and MapCanvasDataProviderMixin then
 NS.MyPinMixin=CreateFromMixins(MapCanvasPinMixin); local pinTemplate=CreateFrame("Frame","QuestSyncMapPinTemplate",nil); Mixin(pinTemplate,NS.MyPinMixin); function NS.MyPinMixin:OnLoad() self:SetSize(22,22); self.icon=self:CreateTexture(nil,"OVERLAY"); self.icon:SetAllPoints(); self.icon:SetTexture("Interface\\AddOns\\QuestSync\\Media\\marker") end
 function NS.MyPinMixin:OnAcquired(m) self.marker=m; self:SetPosition(m.x,m.y); self:SetScript("OnEnter",function(pin) GameTooltip:SetOwner(pin,"ANCHOR_RIGHT"); GameTooltip:AddLine(m.label); GameTooltip:AddLine(m.owner); GameTooltip:Show() end); self:SetScript("OnLeave",GameTooltip_Hide); self:Show() end
 NS.MyDataProvider=CreateFromMixins(MapCanvasDataProviderMixin); function NS.MyDataProvider:RefreshAllData() self:GetMap():RemoveAllPinsByTemplate("QuestSyncMapPinTemplate"); for id,m in pairs(NS.markers) do if m.map==self:GetMap():GetMapID() then self:GetMap():AcquirePin("QuestSyncMapPinTemplate",id,m.x,m.y) end end end; NS.PinProvider=NS.MyDataProvider
end
if WorldMapFrame and WorldMapFrame.ScrollContainer then WorldMapFrame:HookScript("OnMouseUp",function(_,button) if button~="RightButton" or not IsControlKeyDown() then return end; local x,y=WorldMapFrame:GetNormalizedCursorPosition(); if not x or not y then return end; local map=WorldMapFrame:GetMapID(); local permanent=IsShiftKeyDown(); local label=GetZoneText() or "Plek"; local id=NS.PlayerName()..":"..GetTime(); NS.AddMarker(map,x,y,label,permanent,NS.PlayerName(),id); NS.Send("M",map..":"..x..":"..y..":"..label..(permanent and "|p" or "")) end) end
