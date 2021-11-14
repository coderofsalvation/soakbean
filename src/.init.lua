-- special script called by main redbean process at startup
HidePath('/usr/share/zoneinfo/')
HidePath('/usr/share/ssl/')

-- create
app = require("soakbean") {
  opts = {
    my_cli_arg=1 
  },
  subtitle = "SOAKBEAN makes <a href='https://redbean.dev'>redbean</a> programming easy",
  notes   = {"🤩 express-style programming","🖧 easy routing","♻ re-use middleware function"}
}

app.url['^/data']   = '/data.lua'          -- setup file endpoint
app                                        --
.use( app.router( app.url ) )              -- url router
.use( function(req,next) Route() end)      -- redbean fileserver

function OnHttpRequest()
  app.run()
end

app.post('^/save', function(req,next)       -- setup inline POST endpoint
  SetStatus(200)                            
  -- also .get(), .put(), .delete(), .options()
  print(req.body)
  for k,v in pairs(req.body) do app.save(k,v) end
end)

app.save = function(k,v)                    -- called by hello.lua
  print(k .. " (saved)") 
  app.schema.properties[k].default = v      -- saved to server cache (fast)
                                            -- see http://redbean.dev for SQLite code 
end

app.foo = function()
  return {foo="bar"}
end

app.on('foo', function()
  print("im spying on foo!")
end)

app.on('/hello.lua', function(req)
  print("im spying on hello.lua!")
end)
