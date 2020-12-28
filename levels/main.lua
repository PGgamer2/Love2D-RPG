function MoveBox(id)
  local box = searchByID(id)
  moveBlock(id, box.x, box.y + 10)
end

-- Level items
addBlock("library", -175, 100, 128, 128, assets.library)
addBlock("woodenBox", -152, 300, 84, 90, assets.box, 1, true, MoveBox)

addBlock("statueTop", 20, 300, 48, 126, assets.statue.top, 4, false)
addBlock("statueBottom", 19, 426, 52, 38, assets.statue.bottom)

local lvlfn = {}

function lvlfn.load()
  SetPlayerDefaultSettings()
end

function lvlfn.update(dt)
  -- Execute every frame
end

return lvlfn
