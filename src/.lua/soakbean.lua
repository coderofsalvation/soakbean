local json = require "json"

function error(str)
  print("[error] " .. str)
end

sb = {}
sb = {

  middleware={},
  handler={},
  data={},

  __index=function(self,k,v)
    if sb.data[k] then return sb.data[k] end
    if sb[k] then return sb[k] end
    return rawget(self,k)
  end,

  __newindex=function(self,k,v)
    if type(v) == "function" then 
      sb.data[k] = (function(k,v)
        return function(a,b,c,d,e,f)
          v(a,b,c,d,e,f) 
          sb.pub(k,v)
        end
      end)(k,v)
    else 
      sb.data[k] = v
      sb.pub(k,v)
    end
  end,

  on = function(k,f)
    sb.handler[k] = sb.handler[k] or {}
    table.insert( sb.handler[k], f )
    return sb.app
  end,

  pub = function(k,v)
    if sb.handler[k] ~= nil then 
      for i,handler in pairs(sb.handler[k]) do 
        coroutine.wrap(handler)(v,k)
      end
    end
  end,

  -- print( util.tpl("${name} is ${value}", {name = "foo", value = "bar"}) )
  -- "foo is bar"
  tpl = function(s,tab)
    return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
  end,

  write = function(str)
    Write( sb.app.tpl(str,sb.app.data) )
  end,

  job = function(app)
    return function(cfg)
      -- app.
      return app
    end
  end,

  request = function(method)
    return function(path,f)
      sb.app.url[path] = function(req,next)
        if req.method == method then 
          f(req,next) 
        else next() end 
      end
    end
  end,

  json = function(t)
    Write( json.encode(t) )
  end,

  use = function(f)
    table.insert(sb.middleware,f)
  end,

  useDefaults = function()
    app.use( function(req,next)
      pub(req.url,req)
      next()
    end)
  end,

  start = function(req)
    local next = function() end
    local k = 1
    local req = {
      param=GetParams(),
      method=GetMethod(),
      host=GetHost(),
      header=GetHeaders(),
      url=GetPath(),
      protocol=GetScheme(),
      body={}
    }
    if req.method == "POST" and req.header['Content-Type'] == "application/json" and GetPayload():sub(0,1) == "{" then
      req.body = json.decode( GetPayload() )
    end
    sb.useDefaults()
    -- run middleware
    local next = function()
      k = k+1
      if sb.middleware[k] ~= nil then sb.middleware[k](req,next) end
    end
    if type(sb.middleware[k]) == "function" then sb.middleware[k](req,next) end
  end,

  router = function(router)
    return function(req,next)
      for p1, p2 in pairs(router) do 
        if GetPath():match(p1) then
          if type(p2) == "string" then 
            print("router: " .. p1 .. " => " .. p2)
            RoutePath(p2) 
          end
          if type(p2) == "function" then p2(req,next) end
          sb.pub(p1,req)
          sb.pub(p2,req)
          return true
        end
      end 
      next()
    end
  end,


  init = function()
    for k,v in pairs(argv) do 
      app.opts[ v:gsub("=.*",""):gsub("^-","") ] = v:gsub(".*=","")
    end
    for k,v in pairs(sb.app.opts) do 
      print("$ ./soakbean.com -- -" .. k .. "=" .. v )
    end
  end

}

return function(data)
  local app = {}
  setmetatable(app,sb)
  sb.app = app
  sb.data = data
  sb.data.url = {}
  sb.get  = sb.request('GET')
  sb.post = sb.request('POST')
  sb.put = sb.request('PUT')
  sb.options = sb.request('OPTIONS')
  sb.delete  = sb.request('DELETE')
  app.init()
  return app
end
