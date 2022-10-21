-- most usecases will just do fine with the global soakbean app in .init.lua 
-- however, file-endpoints can initialize separated soakbean apps
-- or just use direct Redbean calls. 
local json = require("json")
local app2 = require("soakbean") -- in theory you could setup a separate instance here

SetStatus(200)
SetHeader('Content-Type', 'application/json; charset=utf-8')
local data = {}
for k,v in pairs({"notes","title"}) do data[v] = app[v] end
Write( json.encode( data ) ) 
