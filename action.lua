local action = {}

function action.new(data)
  assert(data.post)
  assert(data.pre)
  assert(data.dt)
  assert(data.process)

  return setmetatable(data, {__index = action})
end

function action:resolve(state_from, state_to, direction)
  --if not self:pre(state_from) or not self:post(state_to) then return 1/0 end

  return self:dt(state_from, state_to, direction)
end

function action:apply(state, dt)
  -- if not self:pre(state) then
  --   return state
  -- else
    return self:process(state, dt) or state
  -- end
end

function action:sign(v, d)
  if v < 0 then
    if type(d) == "number" then return -d end
    return not d
  else
    if type(d) == "number" then return d end
    return d
  end
end

action.noop = action.new{
  post = function() return true end,
  pre = function() return true end,
  dt = function() return 0 end,
  process = function(self, state) return state end,
  name = "noop",
}

return action
