local lvlfn = {}

function MoveBox(id)
  local box = searchByID(id)
  moveBlock(id, box.x, box.y + 10)
end

function libraryMessage()
  openDialog("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc a metus eu risus ultrices posuere vel ac odio. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.@Donec tempus nunc velit, eget accumsan mi ullamcorper id. Curabitur sollicitudin, arcu sed sagittis venenatis, erat metus laoreet tellus, vitae molestie elit urna nec massa.@Vivamus ut lacus eget purus luctus volutpat et a felis. Quisque vel euismod nulla, eu condimentum elit.")
end

-- Level items
addBlock("library", -175, 100, 128, 128, assets.library, 1, true, libraryMessage)
addBlock("woodenBox", -152, 300, 84, 90, assets.box, 1, true, MoveBox)

addBlock("statueTop", 20, 300, 48, 126, assets.statue.top, 4, false)
addBlock("statueBottom", 19, 426, 52, 38, assets.statue.bottom)

SetPlayerDefaultSettings()

function lvlfn.update(dt)
  -- Execute every frame
end

return lvlfn
