local state = {}

local util = require "util"

function state.new()
  return setmetatable({}, {__index = state})
end

function state:contains(other)
  for k,v in pairs(other) do
    if type(v) == "boolean" then
      if not self[k] == v then
        return false
      end
    elseif type(v) == "number" then
      if math.abs(v - (self[k] or 0)) > 10e-5 then
        return false
      end
    else
      if not ((self[k] or 0) <= v) then
        return false
      end
    end
  end
  return true
end

function state:eq(other)
  return self:contains(other) and other:contains(self)
end

function state:apply(changes)
  local next = self:copy()
  for k,v in pairs(changes) do
    next[k] = v
  end
  return next
end

function state:copy()
  return setmetatable(util.deep_copy(self), {__index = state})
end

return state
