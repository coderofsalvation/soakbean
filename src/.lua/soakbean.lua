local json = require "json"

function error(str) print("[error] " .. str) end

function keys(table) local i = 0 ; for k, v in pairs(table) do i = i + 1 end ; return i end

sb = {}
sb = {

  middleware={},
  handler={},
  data={},
  charset="utf-8",

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

  request = function(method, app)
    return function(path,f)
      app.use( function(req,res,next)
        if req.url:match(path) and req.method == method then 
          f(req,res,next) 
        else next() end 
      end)
    end
  end,

  use = function(f)
    table.insert(sb.middleware,f)
    return sb.app
  end,

  useDefaults = function(app)
    app.use( function(req,res,next)
      app.pub(req.url,{req=req,res=res})
      next()
    end)
  end,

  run = function(req)
    local next = function() end
    local k = 0
    local req = {
      param={},
      method=GetMethod(),
      host=GetHost(),
      header=GetHeaders(),
      url=GetPath(),
      protocol=GetScheme(),
      body={}
    }
    local res={
      _status=nil,
      _header={},
      _body=""
    }
    local params = GetParams()
    if params ~= nil then
      for i,p in pairs(params) do req.param[ p[1] ] = p[2] end
    end
    res.status = function(status) res._status = status ; sb.pub('res.status',status)          end
    res.body   = function(v)      res._body = v        ; sb.pub('req.body'  ,body)            end
    res.header = function(k,v)    
      if v == nil then return res._header[k] end 
      res._header[k] = v 
      sb.pub('res.header',{key=k,value=v})
    end
    res.header("content-type","text/html")
    -- run middleware
    next = function()
      k = k+1
      if type(sb.middleware[k]) == "function" then sb.middleware[k](req,res,next) end
    end
    next()
  end,

  json = function()
    local json_response = function(response)
      return function()
        return function(req,res,next)
          if type(res._body) == "table" then 
            res.header('content-type',"application/json")
            res.body( json.encode(res._body) )
          end
          response(req,res,next)
        end
      end
    end
    sb.response = json_response(sb.response())
    return function(req,res,next)
      if req.method ~= "GET" and req.header['Content-Type']:match("application/json") and GetPayload():sub(0,1) == "{" then
        req.body = json.decode( GetPayload() )
      end
      next()
    end
  end,

  response = function()
    return function(req,res,next)
      if res._body ~= nil and res._status ~= nil and res._header['content-type'] ~= nil then 
        SetStatus(res._status)
        for k,v in pairs(res._header) do 
          if k == "content-type" then v = v .. "; charset=" .. sb.charset end
          SetHeader(k,v) 
        end
        if type(res._body) == "string" then
          Write( res._body )
        else print("[ERROR] res.body is not a string (HINT: use json middleware)") end
      else next() end
    end
  end,

  router = function(router)
    return function(req,res,next)
      for p1, p2 in pairs(router) do 
        if GetPath():match(p1) then
          if type(p2) == "string" then 
            print("router: " .. p1 .. " => " .. p2)
            RoutePath(p2) 
          end
          if type(p2) == "function" then p2(req,res,next) end
          sb.pub(p1,req)
          sb.pub(p2,req)
          return true
        end
      end 
      next()
    end
  end,

  template = function(file)
    return function(req,res,next)
      res.status(200)
      res.header('content-type','text/html')
      res.body( sb.app.tpl( LoadAsset(file), sb.app ) )
      next()
    end
  end,

  init = function(app)
    for k,v in pairs(argv) do 
      app.opts[ v:gsub("=.*","") ] = v:gsub(".*=","")
    end
    if( keys(app.cmd) > 0 ) then sb.runcmd(app) end
  end,

  runcmd = function(app)
    for k,v in pairs(app.opts) do 
      if app.cmd[k] then 
        local file = app.cmd[k].file
        return require( file:sub(0,-5) )(app,argv)
      end
    end 
    print("\nUsage: " .. app.bin .. " <cmd> [opts]\n\n")
    for k,v in pairs(app.cmd) do 
      print("\t" .. app.bin .. " " .. k .. "\t\t" .. v.info )
    end
    print("")
    os.exit()
  end

}

return function(data)
  local app = {}
  setmetatable(app,sb)
  sb.app = app
  sb.data = data
  sb.data.url = {}
  if data.url == nil then sb.data.url = {} end 
  sb.get  = sb.request('GET', app)
  sb.post = sb.request('POST', app)
  sb.put = sb.request('PUT', app)
  sb.options = sb.request('OPTIONS', app)
  sb.delete  = sb.request('DELETE', app)
  sb.init(app)
  sb.useDefaults(app)
  return app
end
