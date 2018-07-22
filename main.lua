local make_water_glass_history = {
  actions = {
    take_bottle = {
      apply = function(initial_state, duration)
      end,
      check = function(state)
        return not state.bottle_taken and state.manipulator_empty
      end,
      get_duration = function()
        return 1
      end,
      get_description = function()
        return {
          bottle_taken = true,
          manipulator_empty = false,
        }
      end,
    },
    place_bottle = {
      apply = function(initial_state, duration)
      end,
      check = function(state)
        return state.bottle_taken
      end,
      get_duration = function()
        return 1
      end,
      get_description = function()
        return {
          bottle_taken = false,
          manipulator_empty = true,
        }
      end,
    },
    take_cup = {
      apply = function(initial_state, duration)
      end,
      check = function(state)
        return not state.cup_taken and state.manipulator_empty
      end,
      get_duration = function()
        return 1
      end,
      get_description = function()
        return {
          cup_taken = true,
          manipulator_empty = false,
        }
      end,
    },
    place_cup = {
      apply = function(initial_state, duration)
      end,
      check = function(state)
        return state.cup_taken
      end,
      get_duration = function()
        return 1
      end,
      get_description = function()
        return {
          cup_taken = false,
          manipulator_empty = true,
        }
      end,
    },
    pour_bottle = {
      apply = function(initial_state, duration)
      end,
      check = function(state)
        return state.bottle_taken and state.bottle_full
      end,
      get_duration = function()
        return 1
      end,
      get_description = function()
        return {
          bottle_full = false,
          cup_full = true
        }
      end,
    },
  },
  states = {
    initital = {
      bottle_full = true,
      manipulator_empty = true,
    },
    desired = {
      cup_full = true,
      cup_taken = true,
    },
  },
}

function contains(s1, s2)
  for k,v in pairs(s1) do
    if not s2[k] == v then
      return false
    end
  end
  return true
end

function eq(s1, s2)
  return contains(s1,s2) and contains(s2,s1)
end

function apply(state, action)
  local changes = action.get_description()
  for k,v in pairs(changes) do
    state[k] = v
  end
  return state
end

function undo(state, action)
  local changes = action.get_description()
  for k,v in pairs(changes) do
    state[k] = not v
  end
  return state
end

function solve(history)
  local plan = {}

  local current_state = {}
  for k,v in pairs(history.states.desired) do
    current_state[k] = v
  end

  while not eq(current_state, history.states.initital) do
    print(unpack(plan))
    local found = false
    for k,v in pairs(history.actions) do
      local changes = v.get_description()
      if contains(changes, current_state) then
        found = true
        if (math.random() > 0.5) then
          undo(current_state, v)
          if (not v.check(current_state)) then
            apply(current_state, v)
          else
            table.insert(plan, 1, k)
          end
          break
        end
      end
    end
    if not found then break end
  end

  print(unpack(plan))
end

solve(make_water_glass_history)
