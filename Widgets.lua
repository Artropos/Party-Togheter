-- Widgets: gedeelde warme panelen, knoppen en leesbare tekststijlen.
local NS=QuestSync
NS.C={wood={0.227,0.157,0.11},light={0.36,0.25,0.16},edge={0.478,0.345,0.212},paper={0.91,0.847,0.698},ink={0.165,0.122,0.078},bronze={0.659,0.502,0.29},cream={0.949,0.91,0.835},muted={0.769,0.69,0.557},green={0.25,0.72,0.35}}
function NS.Panel(parent,w,h)
 local f=CreateFrame("Frame",nil,parent,"BackdropTemplate"); f:SetSize(w,h); f:SetBackdrop({bgFile="Interface\\AddOns\\QuestSync\\Media\\panel_plain",edgeFile="Interface\\AddOns\\QuestSync\\Media\\border",edgeSize=16,insets={left=8,right=8,top=8,bottom=8}}); return f
end
function NS.Label(parent,text,size,paper)
 local fs=parent:CreateFontString(nil,"OVERLAY","GameFontNormal"); fs:SetFont(STANDARD_TEXT_FONT,size or 13,"OUTLINE"); fs:SetText(text or ""); local c=paper and NS.C.ink or NS.C.cream; fs:SetTextColor(unpack(c)); if not paper then fs:SetShadowOffset(1,-1); fs:SetShadowColor(0,0,0,.75) end; return fs
end
function NS.Button(parent,text,w,fn)
 local b=CreateFrame("Button",nil,parent,"BackdropTemplate"); b:SetSize(w or 100,26); b:RegisterForClicks("LeftButtonUp","RightButtonUp","MiddleButtonUp"); b:SetBackdrop({bgFile="Interface\\AddOns\\QuestSync\\Media\\button",edgeFile="Interface\\AddOns\\QuestSync\\Media\\border",edgeSize=8,insets={left=3,right=3,top=3,bottom=3}})
 local t=NS.Label(b,text,13); t:SetPoint("CENTER"); b.text=t; b:SetScript("OnClick",fn); b:SetScript("OnEnter",function(self) self:SetBackdropColor(1.18,1.12,.92,1) end); b:SetScript("OnLeave",function(self) self:SetBackdropColor(1,1,1,1) end); return b
end
function NS.Toast(msg)
 if not NS.toast then local f=NS.Panel(UIParent,360,42); f:SetPoint("BOTTOM",0,110); f:SetFrameStrata("DIALOG"); f.text=NS.Label(f,"",14); f.text:SetPoint("CENTER"); NS.toast=f end
 NS.toast.text:SetText(msg); NS.toast:Show(); if C_Timer then C_Timer.After(3,function() if NS.toast then NS.toast:Hide() end end) end
end
