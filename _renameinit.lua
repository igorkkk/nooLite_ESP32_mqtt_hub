if file.exists("init.lua") then
  file.rename("init.lua","_init.lua")
  node.restart()
elseif file.exists("_init.lua") then
  print("Make autostart! \n 15 sec!")
  tmr.create():alarm(15000, 0, function()
      file.rename("_init.lua","init.lua")
      node.restart()
  end)
end