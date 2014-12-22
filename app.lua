local lapis = require ("lapis")
local mover = require ("mover")
local config = require ("lapis.config").get()

local app = lapis.Application()
app:enable("etlua")

app:get("/", function(self)
	local mymover = mover:new(config.inpath, config.outpath)
	self.groups = mymover:groups()
	return { render="index" }
end)

return app