local plan = require "plan"
local state = require "state"
local action = require "action"

return function(history, action_chooser)
  if not action_chooser then action_chooser = function(acts) return math.random(#acts) end end

  for k,v in pairs(history.actions) do
    v.name = k
  end

  local plan = plan.new()
  plan:append({action = action.noop, duration = 0})

  local start_state = state.new():apply(history.states.initital)
  local final_state = state.new():apply(history.states.desired)

  local options = {}

  local current_state = plan:materialize(final_state)
  plan:print(final_state)
  local ik = 100
  while not start_state:eq(current_state) and ik > 0 do
    ik = ik - 1
    --plan:print()
    local possible_actions = {}
    for k,v in pairs(history.actions) do
      if v:post(current_state) then table.insert(possible_actions, v) end
    end
    ::fail::
    while #possible_actions == 0 and plan do
      local prev = table.remove(options)
      plan = prev.plan
      possible_actions = prev.possible_actions
    end
    if not plan then return end

    local idx = action_chooser(possible_actions, current_state, start_state)
    if idx == -1 then goto fail end
    local action = possible_actions[idx]
    table.remove(possible_actions, idx)

    plan:append({action = action, duration = -action:resolve(start_state, current_state), name = action.name})

    for k,v in pairs(current_state) do print(k,v) end
    io.write("picked ", action.name, " possible: ")
    for k,v in ipairs(possible_actions) do io.write(v.name, " ") end
    io.write('\n')
    table.insert(options, {plan = plan:clone(), possible_actions = possible_actions})

    current_state = plan:materialize(final_state)
    --plan:print(final_state)
  end

  if ik == 0 then return nil end

  return plan
end
