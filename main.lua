local action = require "action"

local make_water_glass_history = {
  actions = {
    take_bottle = action.new {
      process = function(self, state, duration)
        if 1 <= math.abs(duration) then
          state.bottle_taken = self:sign(duration, true)
          state.manipulator_empty = self:sign(duration, false)
        end
      end,
      pre = function(self, state)
        return not state.bottle_taken and state.manipulator_empty
      end,
      post = function(self, state)
        return state.bottle_taken and not state.manipulator_empty
      end,
      dt = function(self, state_from, state_to)
        return 1
      end,
    },
    place_bottle = action.new {
      process = function(self, state, duration)
        if 1 <= math.abs(duration) then
          state.bottle_taken = self:sign(duration, false)
          state.manipulator_empty = self:sign(duration, true)
        end
      end,
      pre = function(self, state)
        return state.bottle_taken and not state.manipulator_empty
      end,
      post = function(self, state)
        return not state.bottle_taken and state.manipulator_empty
      end,
      dt = function(self, state_from, state_to)
        return 1
      end,
    },
    take_cup = action.new {
      process = function(self, state, duration)
        if 1 <= math.abs(duration) then
          state.cup_taken = self:sign(duration, true)
          state.manipulator_empty = self:sign(duration, false)
        end
      end,
      pre = function(self, state)
        return not state.cup_taken and state.manipulator_empty
      end,
      post = function(self, state)
        return state.cup_taken and not state.manipulator_empty
      end,
      dt = function(self, state_from, state_to)
        return 1
      end,
    },
    place_cup = action.new {
      process = function(self, state, duration)
        if 1 <= math.abs(duration) then
          state.cup_taken = self:sign(duration, false)
          state.manipulator_empty = self:sign(duration, true)
        end
      end,
      pre = function(self, state)
        return state.cup_taken and not state.manipulator_empty
      end,
      post = function(self, state)
        return not state.cup_taken and state.manipulator_empty
      end,
      dt = function(state_from, state_to)
        return 1
      end,
    },
    pour_bottle = action.new {
      process = function(self, state, duration)
        -- if 1 <= math.abs(duration) then
        --   state.bottle_full = self:sign(duration, false)
        --   state.cup_full = self:sign(duration, true)
        -- end
        if (duration > 0) then
          state.bottle = math.max((state.bottle or 0) - duration, 0)
          state.cup = math.min((state.cup or 0) + duration, 0.2)
        else
          state.bottle = math.min((state.bottle or 0) - duration, 1)
          state.cup = math.max((state.cup or 0) + duration, 0)
        end
      end,
      pre = function(self, state)
        return state.bottle_taken and (state.bottle or 0) > 0
      end,
      post = function(self, state)
        return state.bottle_taken and (state.bottle or 0) >= 0
      end,
      dt = function(self, state_from, state_to)
        local cup = (state_to.cup or 0) - (state_from.cup or 0)
        local bottle = (state_to.bottle or 0) - (state_from.bottle or 0)
        print(cup, bottle)
        if cup > 0 and bottle > 0 then
          return math.max(cup, bottle)
        else
          return math.min(cup, bottle)
        end
      end,
    },
  },
  states = {
    initital = {
      cup = 0,
      bottle = 1,
      manipulator_empty = false,
      bottle_taken = true,
    },
    desired = {
      cup = 0.2,
      cup_taken = true,
    },
  },
}

local solve = require "solver.greedy"

local list = {}
local function visited(state)
  for _, s in ipairs(list) do
    if state:eq(s) then
      return true
    end
  end
  return false
end
local function chooser(acts, curr, desired)
  local util = require "util"
  local best = {
    idx = math.random(#acts),
    diff = 1/0,
  }
  local vis = false
  local action = acts[best.idx]
  local dur = action:resolve(curr, desired)
  best.changes = curr:apply(action:apply({}, dur))
    -- local diff = 0
    -- for k,v in pairs(changes) do
    --   if (desired[k] or false) ~= v then
    --     diff = diff + 1
    --   end
    -- end
    -- for k,v in pairs(desired) do
    --   if (changes[k] or false) ~= v then
    --     diff = diff + 1
    --   end
    -- end
    -- if diff < best.diff and not visited(changes) then
  if not visited(best.changes) then
    vis = true
    -- best = { idx = i, diff = diff, changes = changes }
  end

  if not vis then
    table.remove(list)
    return -1
  else
    table.insert(list, best.changes)
    return best.idx
  end
end

local expression_test = {
  actions = {
    calc_mult = action.new {
      process = function(self, state, duration)
        state.val = (1 + duration) * state.val
      end,
      pre = function(self, state)
        print("pre", state.val, state.limit)
        return state.val ~= 0
      end,
      post = function(self, state)
        return true
      end,
      dt = function(self, state_from, state_to)
        print(state_from.val, state_to.val)
        return state_to.val / state_from.val - 1
      end,
    },
    calc_add = action.new {
      process = function(self, state, duration)
        state.val = duration + state.val
      end,
      pre = function(self, state)
        return true
      end,
      post = function(self, state)
        return true
      end,
      dt = function(self, state_from, state_to, direction)
        print(state_from.val, state_to.val, state_from.limit, state_to.limit, direction == "forward")
        local d = state_to.val - state_from.val
        local limit
        if direction == "forward" then
          if state_to.limit == state_to.limit then
            limit = state_to.limit
          else
            limit = state_from.limit
          end
        else
          if state_from.limit == state_from.limit then
            limit = state_from.limit
          else
            limit = state_to.limit
          end
        end
        print(self:sign(d, math.min(math.abs(d), math.abs(limit))), d, math.abs(d), math.abs(limit))
        return self:sign(d, math.min(math.abs(d), math.abs(limit)))
      end,
    },
    limit_mult = action.new {
      process = function(self, state, duration)
        state.limit = (1 + duration) * state.limit
      end,
      pre = function(self, state)
        return state.limit ~= 0
      end,
      post = function(self, state)
        return true
      end,
      dt = function(self, state_from, state_to)
        return state_to.limit / state_from.limit - 1
      end,
    },
  },
  states = {
    initital = {
      val = 0,
      limit = 5,
    },
    desired = {
      val = 11,
      limit = 2.5
    },
  },
}

local state = require "state"

local order = solve(expression_test)
if order then order:print(state.new():apply(expression_test.states.initital), "forward") end
