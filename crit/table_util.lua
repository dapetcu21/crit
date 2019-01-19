local M = {}

local function deep_clone(t, transformer)
  if transformer then
    t = transformer(t)
  end

  if type(t) ~= "table" then
    return t
  end

  local new_t = {}
  for k, v in pairs(t) do
    new_t[deep_clone(k, transformer)] = deep_clone(v, transformer)
  end
  return new_t
end

M.deep_clone = deep_clone

function M.no_functions(v)
  if type(v) == "function" then
    return nil
  end
  return v
end

function M.clone(t)
  local new_t = {}
  for k, v in pairs(t) do
    new_t[k] = v
  end
  return new_t
end

function M.assign(target, source)
  for k, v in pairs(source) do
    target[k] = v
  end
end

function M.map(t, mapper)
  local new_t = {}
  for k, v in pairs(t) do
    new_t[k] = mapper(v, k, t)
  end
  return new_t
end

function M.imap(t, mapper)
  local new_t = {}
  for k, v in ipairs(t) do
    new_t[k] = mapper(v, k, t)
  end
  return new_t
end

function M.reduce(t, reducer, initial_value)
  local i = 1
  if initial_value == nil then
    i = 2
    initial_value = t[1]
  end

  while true do
    local next_value = t[i]
    if next_value == nil then break end
    initial_value = reducer(initial_value, next_value, i, t)
    i = i + 1
  end
  return initial_value
end

function M.filter(t, predicate)
  local new_t = {}
  local i = 1
  for k, v in ipairs(t) do
    if predicate(v, k, t) then
      new_t[i] = v
      i = i + 1
    end
  end
  return new_t
end

function M.filter_in_place(t, predicate)
  local n = #t
  local i, j = 1, 1
  while j <= n do
    local v = t[j]
    if predicate(v, j, t) then
      if i ~= j then
        t[j] = nil
        t[i] = v
      end
      i = i + 1
    else
      t[j] = nil
    end
    j = j + 1
  end
  return t
end

local random = math.random

-- Fisher-Yates shuffle in-place
function M.shuffle(t)
  for i = #t, 1, -1 do
    local j = random(i)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

-- Fisher-Yates shuffle
function M.shuffled(source)
  local result = {}
  local n = #source
  for i = 1, n do
    local j = random(i)
    result[i] = result[j]
    result[j] = source[i]
  end
  return result
end

return M
