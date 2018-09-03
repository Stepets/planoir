local plan = {}

local util = require "util"

function plan.new()
  local obj = {
    steps = {},
  }
  return setmetatable(obj, {__index = plan})
end

function plan:append(step)
  table.insert(self.steps, 1, step)
end

function plan:clone()
  return setmetatable(util.deep_copy(self), {__index = plan})
end

function plan:materialize(initial_state, direction)
  local state = initial_state:copy()
  for i = 1, #self.steps do
    local step
    if direction == "forward" then
      step = self.steps[i]
    elseif direction == "backward" then
      step = self.steps[#self.steps - i + 1]
    end
    state = step.action:apply(state, step.duration[direction]) or state
  end
  return state
end

function plan:print(initial_state, direction)
  local state = initial_state:copy()
  if state then
    print("state:")
    for k,v in pairs(state) do print("", k,v) end
  end
  for i = 1, #self.steps do
    local step
    if direction == "forward" then
      step = self.steps[i]
    elseif direction == "backward" then
      step = self.steps[#self.steps - i + 1]
    end
    print(step.name, " for ", step.duration[direction])
    if state then
      state = step.action:apply(state, step.duration[direction]) or state
      print("state:")
      for k,v in pairs(state) do print("", k,v) end
    end
  end
end

return plan
