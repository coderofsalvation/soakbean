<img src=".dtp/soakbean.jpg"/>

## Plug and play middleware for redbean server 

Write beautiful [redbean apps](https://redbean.dev) like this [.init.lua](src/.init.lua):

```lua
app = require("soakbean") {
  opts = { my_cli_arg=1 },
  appname = "SOAKBEAN app"
}

app.url['^/mydata']   = '/data.lua'         -- add virtual file endpoints
app                                         
.use( app.router( app.url ) )               -- url router
.use( require("blacklisturl")({"^/foo"}) )  -- add plug'n'play middleware 
.use( function(req,next) Route() end)       -- redbean fileserver

app.post('^/save', function(req,next)       -- setup inline POST endpoint
  SetStatus(200)                            -- also support for: .get() 
  app.cache = req.body                      -- .put() .delete() and .options()
  print(req.body.foo.bar)                   -- automatic json parser
end)

function OnHttpRequest() app.run() end      -- attach to redbean
```

> Profit! Now run `soakbean.com -D . -- -my_cli_arg=99` on windows,mac and linux!

## Beautiful micro stack

<img src=".dtp/soakbean.gif">

* re-use middleware functions across redbean projects
* reactive programming (write less code)
* easy express-style routing
* adapt easily to redbean API changes

## Installation

Either:
1. Use [soakbean.com](soakbean.com) as a starting point, add files to `src` and run `./make all && ./soakbean.com`
2. Or copy [soakbean.lua](src/lua/soakbean.lua) and optionally [json.lua](src/.lua/json.lua) to your [redbean.com](https://redbean.dev) `.lua` folder, and copy the `.init.lua` below
3. clone this repo and run `docker build . -t soakbean && docker build run soakbean` (\*TODO\*)

> optional: copy [middleware](middleware) functions to `src/.lua`-folder where needed

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

> WANTED: please contribute your middleware functions to the [middleware](middleware) folder. Everybody loves (re)using battle-tested middleware.

## Req object

| key | type | alias for redbean |
|-|-|-|
| `req.method` | string | `GetMethod()` |
| `req.url` | string | `GetPath()` |
| `req.param` | table | `GetParams()` |
| `req.host` | string | `GetHost()` |
| `req.header` | table | `GetHeaders()` |
| `req.protocol` | string | `GetScheme()` |
| `req.body` | table (for json POST/PUT/DELETE) or string |  |

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

## Roadmap / Scope

* scope is backend, not frontend
* http auth
* middleware: sqlite user sessions
* middleware: sqlite tiny job queue
* middleware: sqlite tiny rule engine
* middleware: sqlite CRUD middleware (endpoints + sqlite schema derived from jsonschema)
