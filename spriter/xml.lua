
function parseargs(s)
  local arg = {}
--  string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
  string.gsub(s, "([%w:]+)=([\"'])(.-)%2", function (w, _, a)
    arg[w] = a
  end)
  return arg
end
    
function collect(s)
  local stacka = {}
  local top = {}
  table.insert(stacka, top)
  local ni,c,label,xarg, empty
  local i, j = 1, 1
  while true do
    ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
    if not ni then break end
    local text = string.sub(s, i, ni-1)
    if not string.find(text, "^%s*$") then
      table.insert(top, text)
    end
    if empty == "/" then  -- empty element tag
      table.insert(top, {label=label, xarg=parseargs(xarg), empty=1})
    elseif c == "" then   -- start tag
      top = {label=label, xarg=parseargs(xarg)}
      table.insert(stacka, top)   -- new level
    else  -- end tag
      local toclose = table.remove(stacka)  -- remove top
      top = stacka[table.getn(stacka)]
      if table.getn(stacka) < 1 then
        error("nothing to close with "..label)
      end
      if toclose.label ~= label then
        error("trying to close "..toclose.label.." with "..label)
      end
      table.insert(top, toclose)
    end
    i = j+1
  end
  local text = string.sub(s, i)
  if not string.find(text, "^%s*$") then
     table.insert(stacka[table.getn(stacka)], text)
  end
  if table.getn(stacka) > 1 then
     error("unclosed "..stacka[table.getn(stacka)].label)
  end
  return stacka[1]
end