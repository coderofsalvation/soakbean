-- inject app variables into strings/files 
-- usage:
--   app.use( 
--     require("middleware/template")(app,{
--       "^/a.txt"  = {header="text/plain"      ,'${appname}'},
--       "^/a.html" = {header="text/html"       ,'file_in_zip.html'}
--     })
--   )
--   app.appname = "my appname"                     -- template variable
--   str = app.tpl("hello ${appname}", app.data)    -- ad hoc usage
return function(app,urls)

  app.tpl = function (s,tab)
    return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
  end

  return function(req,next)
    for url,v in pairs(urls) do 
      if req.url:match(url) then
        SetStatus(200)
        SetHeader(v[1],v[2])
        if type(k):match("%.lua") then 

        else
          Write( app.tpl(v[2],app.data) ) 
        end
      end
    end
    next()
  end
end
