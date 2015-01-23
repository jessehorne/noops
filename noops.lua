-- Forgive me for what you're about to read

local warnings = 0
local errors = 0

local code = nil

-- execs holds lua executable statements created from noops code
local execs = {}

function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

local warning = function(text)
  warnings = warnings + 1
  print("WARNING[" .. warnings .. "]: " .. text .. "!")
end

local error = function(text)
  errors = errors + 1
  print("ERROR[" .. errors .. "]: " .. text .. "!")
  os.exit()
end

local filename = arg[1]
local args = (function() table.remove(arg, 1); return arg end)()

-- Initial noops.lua warnings and errors
if not filename then
  error("The filename argument is missing")
else
  code = io.open(filename, "r")
  if not code then
    error("There is no code in " .. filename)
  else
    code = code:read("*all")
    if code == "" then
      error("There is no code in " .. filename)
    end
  end
end

if #args == 0 then
  warning("No arguments to this script, I hope that was intentional")
end

-- Right here, in the future, go through and error if any operators are found
-- Because as it stands, you can still use them, because I'm lazy

local code_by_newlines = code:split("\n")

-- Highest parsing scope

for i,v in ipairs(code_by_newlines) do
  local line = v:split(" ")
  if line[1] == "print" then
    local str = "print("
    local code = line
    table.remove(code, 1)

    for x,y in ipairs(code) do
      if _G[y] then
        if x < #code then
          local bleh = _G[y] .. " .. \" \""
          str = str .. bleh .. " .. "
        else
          str = str .. _G[y]
        end
      else
        if x < #code then
          str = str .. "\"" .. y .. " \" .. "
        else
          str = str .. "\"" .. y .. "\""
        end
      end
    end
    str = str .. ")"
    table.insert(execs, str)
  elseif line[1] == "var" then
    local code = "_G['" .. line[2] .. "']="

    for x, y in ipairs(line) do
      if y ~= "var" and y ~= "is" and y ~= line[2] then
        if y == "op" then
          code = code .. "("
        elseif y == "cp" then
          code = code .. ")"
        elseif y == "plus" then
          code = code .. "+"
        elseif y == "min" then
          code = code .. "-"
        elseif y == "mul" then
          code = code .. "*"
        elseif y == "div" then
          code = code .. "/"
        else
          if _G[y] then
            code = code .. _G[y]
          else
            code = code .. y
          end
        end
      end
    end
    loadstring(code)()
  end
end

-- Time to run the code
-- print(table.concat(execs, ";"))
loadstring(table.concat(execs, ";"))()
