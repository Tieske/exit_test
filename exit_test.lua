local list = {}
local osexec = os.execute
local path = require("pl.path")

local ditch = " > /dev/null 2>&1"
if path.is_windows then
  ditch = " 1> NUL 2>NUL"
end

local function pack(...)
  return { n = select("#", ...), ... }
end

local function exec(desc, cmd)
  assert(cmd, "no command provided")
  local r = pack(osexec(cmd..ditch))
  if r[r.n] > 255 then
    local v = r[r.n]
    r[r.n] = math.floor(v/256)
    r[r.n+1] = v - r[r.n]*256
    r.n = r.n + 1
  end  
  r.desc = desc
  r.cmd = cmd
  table.insert(list,r)
end

function display()
  for _,r in ipairs(list) do
    print(r.desc.." ("..r.cmd..")")
    print("  #:"..r.n)
    for i=1,r.n do
      print("  "..i..": ", r[i])
    end
    print()
  end
end

local function test()
  exec("testing shell command (always success)", "dir")
  exec("testing non-existing command (always failure)", "this_obviously_does_not_exist")
  exec("testing os.exit(25) exitcode", "lua _exitcode.lua 25")
  exec("testing os.exit(-5) exitcode", "lua _exitcode.lua -5")
  exec("testing os.exit(400) exitcode", "lua _exitcode.lua 400")
  exec("testing erroneous script", "lua _exiterror.lua")
  --exec("testing ctrl-c exit", "_exit-ctrl-c.lua")
end

print("====> PLAIN <====")
list = {}
test()
display()
print("====> PENLIGHT <====")
osexec = require("pl.utils").execute
list = {}
test()
display()
