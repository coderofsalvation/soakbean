package.path = package.path .. ";.lua/?.lua"
package.path = package.path .. ";src/.lua/?.lua"
package.path = package.path .. ";middleware/?.lua"

json = require "json"

-- special script called by main redbean process at startup
HidePath('/usr/share/zoneinfo/')
HidePath('/usr/share/ssl/')

-- create
app = require("soakbean") {
  bin = "./redbean.com",
  opts = {
    my_cli_arg=1 
  },
  cmd={
    -- runtask =  {file="sometask.lua",   info="description of cli cmd"}
  },
  title     = 'SOAKBEAN - a buddy of redbean',
  subtitle  = 'SOAKBEAN makes <a href=https://redbean.dev>redbean</a> programming easy',
  notes     = {'🤩 express-style programming', '🖧 easy  routings', '♻ re-use middleware functions'}
}

app.url['^/data']   = '/data.lua'          -- setup custom file endpoint

app.get('^/', app.template('index.html') ) -- alias for app.tpl( LoadAsset('index.html'), app )

app.post('^/save', function(req,res,next)  -- setup inline POST endpoint
  -- also .get(), .put(), .delete(), .options()
  app.cache  = req.body                     -- middleware auto-decodes json
  res.status(200)                         
  res.body({cache=app.cache})               -- middleware auto-encodes json 
  next()
end)

app                                        --
.use( require("json").middleware() )       -- try plug'n'play json API middleware 
.use( app.router( app.url ) )              -- try url router
.use( app.response() )                     -- try serve app response  (if any)
.use( function(req,next) Route() end)      -- fallback default redbean fileserver

function OnHttpRequest() app.run() end
