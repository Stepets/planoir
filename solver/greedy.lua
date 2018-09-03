local plan = require "plan"
local state = require "state"
local action = require "action"

return function(history)
  for k,v in pairs(history.actions) do
    v.name = k
  end

  local plan = plan.new()
  --plan:append({action = action.noop, duration = 0})

  local start_state = state.new():apply(history.states.initital)
  local final_state = state.new():apply(history.states.desired)

  -- plan:print(start_state)
  -- plan:print(final_state)

  local options = {}

  local current_state = final_state:copy()
  local ik = 15
  while not plan:materialize(start_state, "forward"):contains(final_state) and ik > 0 do
    ik = ik - 1
    --plan:print()
    local possible_actions = {}
    print("possible_actions :")
    for k,v in pairs(history.actions) do
      if v:post(current_state) and v:pre(start_state) then table.insert(possible_actions, v) print(v.name) end
    end
    while #possible_actions == 0 and plan do
      local prev = table.remove(options)
      plan = prev.plan
      possible_actions = prev.possible_actions
      print("reverting plan to :")
      plan:print(final_state)
      print("with possible_actions :")
      for _, a in ipairs(possible_actions) do print(a.name) end
    end
    if not plan then return end

    print()

    ::select_action::

    local idx = math.random(#possible_actions)
    local action = possible_actions[idx]
    print(action.name)
    table.remove(possible_actions, idx)

    local duration = {
      forward = action:resolve(start_state, current_state, "forward"),
      backward = action:resolve(current_state, start_state, "backward")
    }
    if duration.forward == 0 or duration.backward == 0 or duration.forward ~= duration.forward or duration.backward ~= duration.backward then
      goto select_action
    end
    print(duration.forward, duration.backward)
    plan:append({action = action, duration = duration, name = action.name})

    -- for k,v in pairs(current_state) do print(k,v) end
    -- io.write("picked ", action.name, " for ", duration, " possible: ")
    -- for k,v in ipairs(possible_actions) do io.write(v.name, " ") end
    -- io.write('\n')
    table.insert(options, {plan = plan:clone(), possible_actions = possible_actions})

    current_state = plan:materialize(final_state, "backward")
    print(start_state.val, final_state.val)
    print("plan //")
    plan:print(current_state, "forward")
    print("plan \\\\")
  end

  if ik == 0 then return nil end

  return plan
end
