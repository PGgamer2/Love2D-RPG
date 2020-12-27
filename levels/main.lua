function MoveBox(id)
  local box = searchByID(id)
  moveBlock(id, box.x, box.y + 10)
end

-- Level items
addBlock("library", -175, 100, 128, 128, assets.library)
addBlock("woodenBox", -152, 300, 84, 90, assets.box, true, MoveBox)


local lvlfn = {}

function lvlfn.load()
  SetPlayerDefaultSettings()
end

function lvlfn.update(dt)
  -- Execute every frame
end

return lvlfn
