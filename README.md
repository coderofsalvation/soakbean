<img src=".dtp/soakbean.jpg"/>

## Plug and play middleware for redbean server 

Write beautiful [redbean apps](https://redbean.dev) like this [.init.lua](src/.init.lua):

```lua
app = require("soakbean") {
  opts = { my_cli_arg=1 },
  appname = "SOAKBEAN app"
}
app.url['^/data']   = '/data.lua'          -- add virtual file endpoints

app                                        --
.use( require("json").middleware() )       -- plug'n'play json API middleware 
.use( app.router( app.url ) )              -- url router
.use( app.response() )                     -- serve app response  (if any)
.use( function(req,next) Route() end)      -- default redbean fileserver

app.post('^/save', function(req,res,next)  -- setup inline POST endpoint
  res.status(200)                          -- also: .get(), .put(), .delete(), .options()
  app.cache  = req.body                    -- middleware auto-decodes json
  res.body({cache=app.cache})              -- middleware auto-encodes json 
  next()
end)

function OnHttpRequest() app.run() end
```

> Profit! Now run `soakbean.com -D . -- -my_cli_arg=99` on windows,mac or linux (yes!)

## Beautiful micro stack

<img src=".dtp/soakbean.gif">

* re-use middleware functions across redbean projects
* reactive programming (write less code)
* easy express-style routing
* easily adapt to redbean API changes

## Getting started 

| Easy | DIY | Docker |
|-|-|-|
| rename [soakbean.com](soakbean.com) to `soakbean.zip`, add lua + html files, rename back to `soakbean.com` and run `./soakbean.com` | copy [soakbean.lua](src/lua/soakbean.lua) (and optional middleware) to your [redbean.com](https://redbean.dev) `.lua` folder, and copy the `.init.lua` above | clone this repo and run `docker build . -t soakbean && docker build run soakbean` (\*TODO\*) |

> middleware: copy [middleware](middleware) functions to `src/.lua`-folder where needed

## Middleware functions

You can easily manipulate the http-request flow, using existing middleware functions:

```lua
app.use( 
    require("blacklisturl")({
        "^/secret/",
        "^/me-fainting-next-to-justinbieber.mp4"
    })
)
```

> make sure you copy [middleware/blacklisturl.lua](middleware/blacklisturl.lua) to [src/.lua](src/.lua)

or just write ad-hoc middleware:

```lua
app.use( function(req,next)
    if !req.loggedin && req.url:match("^/mydata") then
        SetStatus(403)
    else next()
end)
```

> WANTED: please contribute your [middleware](middleware) functions by pushing repositories with nameconvention `soakbean-middleware-<name>`. Everybody loves (re)using battle-tested middleware.

## req & res object

| key | type | alias for redbean |
|-|-|-|
| `req.method` | string | `GetMethod()` |
| `req.url` | string | `GetPath()` |
| `req.param` | table | `GetParams()` |
| `req.host` | string | `GetHost()` |
| `req.header` | table | `GetHeaders()` |
| `req.protocol` | string | `GetScheme()` |
| `req.body` | table or string |  |
| `res.body(value)` | string | `Write(value) including auto-encoding (json e.g.)` |
| `res.status(code)` | int | `SetStatus(code)` |
| `res.header(type,value)` | string,string | `SetHeader(type,value)` |

## Reactive programming

#### react to variable changes:

```lua
app.on("foo", function(k,v)
  print("appname changed: " .. v)
end)

app.foo = "flop"   -- output: appname changed: flop
app.foo = "bar"    -- output: appname changed: bar
```

#### react to function calls 

```lua 
app.on('foobar', function(a)
    print("!")
end)

app.foobar = function(a)
    print('foobar')
end

app.foobar()       -- output: foobar!
```

#### react to router patterns

```lua
app.url['^/foo'] = '/somefile.lua'

app.on('^/foo', function(a,b)
  -- do something
end)
```

#### react to luafile endpoint execution 

```lua
app.url['^/foo'] = '/somefile.lua'

app.on('somefile.lua', function(a,b)
  -- do something
end)
```

#### react to response code/header/body changes

```lua
app.on('res.status', print )
app.on('res.body'  , print )
app.on('res.header', function(k,v)
  print(k .. " => " .. v)
end)
```

> NOTE: above is handy for debugging a flow. Use `app.use(..)` for more control.

## Roadmap / Scope

* scope is backend, not frontend
* http auth (*)
* middleware: sqlite user sessions (*)
* middleware: sqlite tiny job queue (*)
* middleware: sqlite tiny rule engine (*)
* middleware: sqlite CRUD middleware (endpoints + sqlite schema derived from jsonschema) (*)

\* = please contribute! =]
