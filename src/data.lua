local json = require "json"

SetStatus(200)
SetHeader('Content-Type', 'application/json; charset=utf-8')
local data = {}
for k,v in pairs({"notes","subtitle"}) do data[v] = app[v] end
Write( json.encode( data ) ) 
