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
.use( require("json").middleware() )       -- plug'n'play json API middleware 
.use( app.router( app.url ) )              -- url router
.use( app.response() )                     -- serve app response  (if any)
.use( function(req,next) Route() end)      -- default redbean fileserver

app.post('^/save', function(req,res,next)  -- setup inline POST endpoint
  -- also .get(), .put(), .delete(), .options()
  app.cache  = req.body                     -- middleware auto-decodes json
  res.status(200)                         
  res.body({cache=app.cache})               -- middleware auto-encodes json 
  next()
end)

function OnHttpRequest() app.run() end
