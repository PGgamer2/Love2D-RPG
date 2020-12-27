--- Useful functions for level creation.
-- Some of the functions were inspired from <a href="https://love2d.org/forums/viewtopic.php?f=4&t=78729&p=173524#p173524">kikito</a>.

blocks = {} -- In this table we store every item of the level except the player.

--- Check if table has value.
-- @param tab Table
-- @param val Value
-- @return Boolean.
function hasValue(tab, val)
    for i, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

--- Crop images.
-- I'm using this instead of Love2D quads.
-- @param imgpath Path of the image
-- @param cropX X position where we'll start to crop the image (in pixels)
-- @param cropY Y position where we'll start to crop the image (in pixels)
-- @param cropWidth Width of the cropped image (in pixels)
-- @param cropHeight Height of the cropped image (in pixels)
-- @return Cropped image.
function cropImage(imgpath, cropX, cropY, cropWidth, cropHeight)
  local img = love.image.newImageData(imgpath)
  local cropped = love.image.newImageData(cropWidth, cropHeight)
  cropped:paste(img, 0, 0, cropX, cropY, cropWidth, cropHeight)
  return love.graphics.newImage(cropped)
end

--- Add item to the current level.
-- @param id The ID that we will use to search the item
-- @param x X coordinates
-- @param y Y coordinates
-- @param w Width
-- @param h Height
-- @param drawable Sprite that will be used for the item
-- @param collidable Collide with player (default: true)
-- @param execOnInteract Function to execute when player interacts with the item
-- @return Item that has been created.
function addBlock(id,x,y,w,h,drawable,collidable,execOnInteract)
  if collidable == nil then collidable = true end

  local block = {id=id,x=x,y=y,w=w,h=h,drawable=drawable,collidable=collidable,execOnInteract=execOnInteract}
  blocks[#blocks+1] = block
  if collidable == true then
    world:add(block, x,y,w,h)
  end

  return blocks[#blocks]
end

--- Modify item by ID.
-- @param id The ID that we will use to search the item
-- @param x X coordinates
-- @param y Y coordinates
-- @param w Width
-- @param h Height
-- @param drawable Sprite that will be used for the item
-- @param collidable Collide with player (default: true)
-- @param execOnInteract Function to execute when player interacts with the item
function updateBlock(id,x,y,w,h,drawable,collidable,execOnInteract)
  for _,block in ipairs(blocks) do
    if block.id == id then
      block.x, block.y = x, y
      if w ~= nil then block.w = w end
      if h ~= nil then block.h = h end
      if drawable ~= nil then block.drawable = drawable end

      if collidable ~= nil then
        if block.collidable == true and collidable == false then
          world:remove(block)
          block.collidable = false
        elseif block.collidable == false and collidable == true then
          world:add(block, x,y,w,h)
          block.collidable = true
        end
      end

      if block.collidable == true then
        world:update(block, x,y,w,h)
      end

	    if execOnInteract ~= nil then
	      block.execOnInteract = execOnInteract
	    end
    end
  end
end

--- Move item by ID.
-- @param id The ID that we will use to search the item
-- @param goalx Target position in X coordinates
-- @param goaly Target position in Y coordinates
-- @return New X value.
-- @return New Y value.
-- @return Items that are colliding.
-- @return Number of items that collided.
function moveBlock(id, goalx, goaly)
  for _,block in ipairs(blocks) do
    if block.id == id then
      if block.collidable == true then
        block.x, block.y, block.cols, block.len = world:move(block, goalx, goaly)
        return block.x, block.y, block.cols, block.len
      else
        block.x, block.y = goalx, goaly
      end
    end
  end
end

--- Remove item by ID.
-- @param id The ID that we will use to search the item
function removeBlock(id)
  for i, block in ipairs(blocks) do
    if block.id == id then
      if block.collidable == true then world:remove(block) end
      table.remove(blocks, i)
    end
  end
end

--- Draw every item of the level.
-- Put this inside love.draw()
function drawBlocks()
  for _,block in ipairs(blocks) do
    love.graphics.draw(block.drawable, block.x, block.y, 0, block.w / block.drawable:getWidth(), block.h / block.drawable:getHeight())
  end
end

--- Search level item by ID.
-- @param id The ID used for the search
-- @return The item you were searching. Returns nil if the item doesn't exist.
function searchByID(id)
  for _,block in ipairs(blocks) do
    if block.id == id then
      return block
    end
  end
end

--- Set player settings to the default ones.
-- The player will be: <ul><li>Able to move</li><li>Able to interact</li><li>Able to open the inventory</li><li>Able to open the menu</li><li>Visible</li></ul>
function SetPlayerDefaultSettings()
  player.MenuIsOpen = false
  player.inventoryIsOpen = false
  player.canMove = true
  player.canInteract = true
  player.canOpenInventory = true
  player.canOpenMenu = true
  player.visible = true
end

--- Load levels from lua files.
-- Inside the level file put a load() and an update(dt) function
-- @param lvl Lua file to load
-- @return Level functions.
function LoadLevel(lvl)
  for i, block in ipairs(blocks) do
    world:remove(block)
    blocks[i] = nil
  end
  local loadedlvl = require(lvl)
  loadedlvl.load(arg)
  return loadedlvl
end
