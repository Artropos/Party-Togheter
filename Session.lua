-- Session: code maakt uitsluitend een tijdelijk, verborgen kanaal; protocolversie wordt afgedwongen.
local NS=QuestSync
local alphabet="ABCDEFGHJKMNPQRSTUVWXYZ23456789"
local function codegen() local s=""; for i=1,5 do local n=math.random(#alphabet); s=s..alphabet:sub(n,n) end; return s end
function NS.JoinSession(raw)
 local code=string.upper(string.gsub(string.gsub(raw or "","[%s%-]",""),"[^A-Z0-9]","")); if #code<4 or #code>10 then NS.Toast("Gebruik een code van 4–10 tekens."); return end
 if NS.channel then NS.LeaveSession() end; NS.code=code; QuestSyncDB.lastCode=code; local name="QS_"..code
 if JoinTemporaryChannel then JoinTemporaryChannel(name) elseif JoinChannelByName then JoinChannelByName(name) end
 C_Timer.After(.6,function() local id=GetChannelName(name); if not id or id==0 then if JoinTemporaryChannel then JoinTemporaryChannel(name) end; C_Timer.After(.7,function() NS.SetChannel(name) end) else NS.channel=id; NS.Send("V",NS.VERSION.."|"..NS.PlayerName()); NS.Send("R",""); NS.Send("SH",NS.PlayerName()) end end)
end
function NS.SetChannel(name) local id=GetChannelName(name); if id and id>0 then NS.channel=id; NS.Send("V",NS.VERSION.."|"..NS.PlayerName()); NS.Send("R","") end end
function NS.CreateSession() NS.JoinSession(codegen()) end
function NS.LeaveSession() if NS.channel and NS.code then NS.Send("X",NS.PlayerName()); LeaveChannelByName("QS_"..NS.code) end; NS.channel=nil; NS.code=nil; NS.players={}; if NS.UpdateSync then NS.UpdateSync() end end
function NS.HandleMessage(msg,sender)
 local typ,payload=string.match(msg,"^([^|]+)|?(.*)$"); if not typ then return end
 if typ=="V" then local ver=string.match(payload,"^([^|]+)"); if ver~=NS.VERSION then if not NS.versionWarned then NS.Toast("Een sessielid gebruikt een andere protocolversie."); NS.versionWarned=true end; NS.incompatible=NS.incompatible or {}; NS.incompatible[sender]=true; return end; NS.players[sender]=NS.players[sender] or {name=sender,quests={}}; NS.Send("S",NS.SerializeSnapshot()); return end
 if NS.incompatible and NS.incompatible[sender] then return end; NS.players[sender]=NS.players[sender] or {name=sender,quests={}}
 if typ=="R" then NS.Send("S",NS.SerializeSnapshot()) elseif typ=="S" then NS.ParseSnapshot(sender,payload)
 elseif typ=="Q" then local seq,data=string.match(payload,"^(%d+)|(.+)$"); seq=tonumber(seq); if seq and NS.players[sender].seq and seq>NS.players[sender].seq+1 then NS.Send("R","") end; if seq then NS.players[sender].seq=seq; NS.ParseSnapshot(sender,data) end
 elseif typ=="D" then NS.players[sender].quests[tonumber(payload)]=nil elseif typ=="C" then local id,n=string.match(payload,"^(%d+)|(.+)$"); if id then NS.claims[id]=n~="-" and n or nil end
 elseif typ=="X" then NS.players[sender]=nil elseif typ=="P" then NS.UpdatePosition(sender,payload) elseif typ=="M" then NS.ReceiveMarker(sender,payload) elseif typ=="SH" then end
 if NS.UpdateSync then NS.UpdateSync() end
end
function NS.SerializeSnapshot() local list={}; for id,q in pairs(NS.quests) do if not q.private then local o={}; for _,v in ipairs(q.objectives) do o[#o+1]=(v.numFulfilled or 0).."/"..(v.numRequired or 0) end; list[#list+1]=id.."="..(q.complete and "d" or "a").."="..table.concat(o,",") end end; return table.concat(list,";") end
function NS.ParseSnapshot(sender,data) local p=NS.players[sender]; p.quests={}; for row in string.gmatch(data or "","[^;]+") do local id,state,obj=string.match(row,"^(%d+)=([^=]+)=?(.*)$"); if id then p.quests[tonumber(id)]={state=state,objectives=obj} end end end
function NS.SendSnapshot() if NS.channel then NS.seq=NS.seq+1; NS.Send("Q",NS.seq.."|"..NS.SerializeSnapshot()) end end
C_Timer.NewTicker(300,function() if NS.channel then NS.Send("R","") end end)
