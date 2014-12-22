local lfs = require 'lfs'

local mover = {}

function mover:new(inpath, outpath)
  print(string.format("%s %s %s", o, inpath, outpath))
  o = {}   -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  self.inpath = inpath
  self.outpath = outpath
  return o
end

function mover:allfiles()
  t = {}
  for path in lfs.dir(self.inpath) do
    table.insert(t, path)
  end
  table.sort(t, function (a,b) return string.lower(a) < string.lower(b) end)
  return t
end

return mover