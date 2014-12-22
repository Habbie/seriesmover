local lfs = require 'lfs'

local mover = {}

local function endswith(s, send)
         return #s >= #send and s:find(send, #s-#send+1, true) and true or false
end

local function title(s)
  local parts = {}
  for part in s:gmatch("(%w+) ?") do
    print(string.format("[%s]", part))
    local newpart = part:sub(1,1):upper() .. part:sub(2)
    table.insert(parts, newpart)
  end
  return table.concat(parts, ' ')
end

local function augment(item, attrs)
  local nameparts = {}
  local season = nil
  local episode = nil
  item.inode = attrs.ino
  for part in item.name:gmatch("(%w+)%.?") do
    -- try SxxEyy syntax
    season, episode = part:match('^S(%d+)E(%d+)$')
    if season then
      season = tonumber(season)
      episode = tonumber(episode)
    else
      -- try xyy syntax
      season, episode = part:match('^(%d+)(%d%d)$')
      if season then
        season = tonumber(season)
        episode = tonumber(episode)
      end
    end
    if season then
      item.season = season
      item.episode = episode
      item.title = title(table.concat(nameparts, ' '):lower())
      return
    end
    table.insert(nameparts, part)
  end
end

local function compare(a, b)
  if a.title == b.title then
    if a.season == b.season then
      return a.episode < b.episode
    else
      return a.season < b.season
    end
  else
    return string.lower(a.title) < string.lower(b.title)
  end
end

function mover:new(inpath, outpath)
  print(string.format("%s %s %s", o, inpath, outpath))
  local o = {}   -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  self.inpath = inpath
  self.outpath = outpath
  return o
end

function mover:allfiles()
  local files = {}
  local seen = {}
  for name in lfs.dir(self.inpath) do
    local attrs = lfs.symlinkattributes(string.format('%s/%s', self.inpath, name))
    if attrs.mode == 'file' then
      if endswith(name, '.t') then
        print(string.format('seen %s', name:sub(1, -3)))
        seen[name:sub(1, -3)] = 1
      else
        local item = {name=name}
        augment(item, attrs)
        table.insert(files, item)
      end
    end
  end
  for i, v in ipairs(files) do
    print(string.format('i=%s, v=%s', i, type(v)))
    print(string.format("seen %s?", v.name))
    v.seen = (seen[v.name] == 1)
    print(string.format("seen=%s", v.seen))
  end
  table.sort(files, compare)
  return files
end

function mover:groups()
  local groups = {}
  for k,v in ipairs(self:allfiles()) do
    local index = #groups
    if index == 0 or groups[index].title ~= v.title then
      table.insert(groups, {title=v.title, items={}})
      index = #groups
    end
    table.insert(groups[index].items, v)
  end
  return groups
end

return mover