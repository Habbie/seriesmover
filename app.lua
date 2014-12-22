local lapis = require ("lapis")
local mover = require ("mover")
local config = require ("lapis.config").get()

local app = lapis.Application()
app:enable("etlua")

app:get("/", function(self)
	local mymover = mover:new(config.inpath, config.outpath)
	local allfiles = mymover:allfiles()
	self.allfiles = allfiles
	return { render="index" }
end)

return app