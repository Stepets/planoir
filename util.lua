local util = {}

function util.deep_copy(obj, tab)
  tab = tab or ''
  if type(obj) == 'table' then
    local result = {}
    for k,v in pairs(obj) do
      result[k] = util.deep_copy(v, tab .. '\t')
    end
    return result
  else
    return obj
  end
end

function util.deep_print(obj, tab)
  tab = tab or ''
  if type(obj) == 'table' then
    print(tab, "{")
    for k,v in pairs(obj) do
      print(tab, k)
      util.deep_print(v, tab .. '\t')
    end
    print(tab, "}")
  else
    print(tab, obj, type(obj))
  end
end

return util
