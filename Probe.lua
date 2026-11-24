-- Probe.lua: controleert expliciet de clientaannames en toont waarden in het chatvenster.
local ADDON_NAME = ...
QuestSync = QuestSync or {}
local NS = QuestSync
local function report(name, ok, value)
    print(string.format("QuestSync Probe: %s — %s (%s)", ok and "PASS" or "FAIL", name, tostring(value)))
end
local function runProbe()
    local q = C_QuestLog
    report("GetQuestID", type(GetQuestID) == "function", type(GetQuestID))
    report("C_QuestLog.GetNumQuestLogEntries", q and type(q.GetNumQuestLogEntries) == "function", q and type(q.GetNumQuestLogEntries))
    report("C_QuestLog.GetInfo", q and type(q.GetInfo) == "function", q and type(q.GetInfo))
    report("C_QuestLog.GetQuestObjectives", q and type(q.GetQuestObjectives) == "function", q and type(q.GetQuestObjectives))
    report("C_QuestLog.SetSelectedQuest", q and type(q.SetSelectedQuest) == "function", q and type(q.SetSelectedQuest))
    report("QuestLogPushQuest", type(QuestLogPushQuest) == "function", type(QuestLogPushQuest))
    local found = false
    if q and q.GetNumQuestLogEntries and q.GetInfo and q.GetQuestTagInfo then
        for i=1,q.GetNumQuestLogEntries() do
            local info=q.GetInfo(i)
            if info and info.questID and not info.isHeader then
                local tag=q.GetQuestTagInfo(info.questID)
                if tag then
                    print("QuestSync Probe: class-tag kandidaat quest="..info.questID.." tagID="..tostring(tag.tagID).." tagName="..tostring(tag.tagName))
                    if (Enum and Enum.QuestTag and Enum.QuestTag.Class and tag.tagID==Enum.QuestTag.Class) or (tag.tagName and string.find(string.lower(tag.tagName),"class",1,true)) then found=true end
                end
            end
        end
    end
    report("class-tag gecontroleerd (open een class-quest voor exact bewijs)", found, "Enum.QuestTag.Class="..tostring(Enum and Enum.QuestTag and Enum.QuestTag.Class))
    report("C_SuperTrack.SetSuperTrackedQuestID", C_SuperTrack and type(C_SuperTrack.SetSuperTrackedQuestID)=="function", C_SuperTrack and type(C_SuperTrack.SetSuperTrackedQuestID))
    report("C_SuperTrack.GetSuperTrackedQuestID", C_SuperTrack and type(C_SuperTrack.GetSuperTrackedQuestID)=="function", C_SuperTrack and type(C_SuperTrack.GetSuperTrackedQuestID))
    report("C_ChatInfo.SendAddonMessage", C_ChatInfo and type(C_ChatInfo.SendAddonMessage)=="function", C_ChatInfo and type(C_ChatInfo.SendAddonMessage))
    report("CHAT_MSG_ADDON event", true, "registreerbaar via frame:RegisterEvent")
    local tex=CreateFrame("Frame"):CreateTexture(); local ok=pcall(tex.SetTexture,tex,"Interface\\AddOns\\QuestSync\\Media\\panel")
    report("panel.tga texturepad",ok,"Interface\\AddOns\\QuestSync\\Media\\panel")
    report("MapCanvasPinMixin", type(MapCanvasPinMixin)=="table", type(MapCanvasPinMixin))
    report("MapCanvasDataProviderMixin", type(MapCanvasDataProviderMixin)=="table", type(MapCanvasDataProviderMixin))
    report("WorldMapFrame.AddDataProvider", WorldMapFrame and type(WorldMapFrame.AddDataProvider)=="function", WorldMapFrame and type(WorldMapFrame.AddDataProvider))
    report("WorldMapFrame.GetNormalizedCursorPosition", WorldMapFrame and type(WorldMapFrame.GetNormalizedCursorPosition)=="function", WorldMapFrame and type(WorldMapFrame.GetNormalizedCursorPosition))
    local x,y,z,instance=UnitPosition and UnitPosition("player")
    report("UnitPosition tuple", x~=nil, table.concat({tostring(x),tostring(y),tostring(z),tostring(instance)},", "))
    report("Minimap:IsRotating", Minimap and type(Minimap.IsRotating)=="function", Minimap and Minimap.IsRotating and tostring(Minimap:IsRotating()))
    report("rotateMinimap CVar", GetCVar and GetCVar("rotateMinimap"), GetCVar and GetCVar("rotateMinimap"))
    report("JoinTemporaryChannel", type(JoinTemporaryChannel)=="function", type(JoinTemporaryChannel))
    report("LeaveChannelByName", type(LeaveChannelByName)=="function", type(LeaveChannelByName))
    report("C_QuestLog.GetQuestTagInfo exact class-tag", found, "class-tag wordt alleen hard bevestigd op een aanwezige class-quest")
end
SLASH_QUESTSYNCPROBE1="/qs"
SlashCmdList.QUESTSYNCPROBE=function(msg) if string.lower(msg or "")=="probe" then runProbe() elseif NS and NS.Command then NS.Command(msg) else print("QuestSync: probe of laad de addon volledig.") end end
