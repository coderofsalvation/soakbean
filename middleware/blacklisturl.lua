-- blocks certain url patterns
-- usage:
--   app.use( require("middleware/blacklisturl")({"^/foo","/^bar"}) )
--
return function(urls)
  return function(req,next)
    for k,url in pairs(urls) do 
      print(url)
      if req.url:match(url) then return SetStatus(403) end
    end
    next()
  end
end
