--- Level creation and management using bump.
-- Some of the functions were inspired from <a href="https://love2d.org/forums/viewtopic.php?f=4&t=78729&p=173524#p173524">kikito</a>.

world = bump.newWorld() -- create a world with bump
blocks = {} -- In this table we store every object of the level except the player.

--- Add object to the current level.
-- @param id The ID that we will use to search the object
-- @param x X coordinates
-- @param y Y coordinates
-- @param w Width
-- @param h Height
-- @param drawable Sprite that will be used for the object
-- @param layer The layer where the object needs to be. The player is between the third and the fourth layer
-- @param collidable Collide with player (default: true)
-- @param execOnInteract Function to execute when player interacts with the object
-- @return Object that has been created.
function addBlock(id,x,y,w,h,drawable,layer,collidable,execOnInteract)
  if layer == nil then layer = 1 end
  if collidable == nil then collidable = true end

  local block = {id=id,x=x,y=y,w=w,h=h,drawable=drawable,layer=layer,collidable=collidable,execOnInteract=execOnInteract}
  blocks[#blocks+1] = block
  if collidable == true then
    world:add(block, x,y,w,h)
  end

  return blocks[#blocks]
end

--- Modify object by ID.
-- @param id The ID that we will use to search the object
-- @param x X coordinates
-- @param y Y coordinates
-- @param w Width
-- @param h Height
-- @param drawable Sprite that will be used for the object
-- @param layer The layer where the object needs to be. The player is between the third and the fourth layer
-- @param collidable Collide with player (default: true)
-- @param execOnInteract Function to execute when player interacts with the object
function updateBlock(id,x,y,w,h,drawable,layer,collidable,execOnInteract)
  for _,block in ipairs(blocks) do
    if block.id == id then
      if x ~= nil then block.x = x end
      if y ~= nil then block.y = y end
      if w ~= nil then block.w = w end
      if h ~= nil then block.h = h end
      if drawable ~= nil then block.drawable = drawable end
      if layer ~= nil then block.layer = layer end

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

--- Move object by ID.
-- @param id The ID that we will use to search the object
-- @param goalx Target position in X coordinates
-- @param goaly Target position in Y coordinates
-- @return New X value.
-- @return New Y value.
-- @return Objects that are colliding.
-- @return Number of objects that collided.
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

--- Remove object by ID.
-- @param id The ID that we will use to search the object
function removeBlock(id)
  for i, block in ipairs(blocks) do
    if block.id == id then
      if block.collidable == true then world:remove(block) end
      table.remove(blocks, i)
    end
  end
end

--- Draw every object of the level.
-- Put this inside love.draw()
-- @param layer The layer you want to draw. It will draw everything if the parameter is nil
function drawBlocks(layer)
  for _,block in ipairs(blocks) do
    if (layer ~= nil and layer == block.layer) or layer == nil then
      love.graphics.draw(block.drawable, block.x, block.y, 0, block.w / block.drawable:getWidth(), block.h / block.drawable:getHeight())
    end
  end
end

--- Search level object by ID.
-- @param id The ID used for the search
-- @return The object you were searching. Returns nil if the object doesn't exist.
function searchByID(id)
  for _,block in ipairs(blocks) do
    if block.id == id then
      return block
    end
  end
end

--- Load levels from lua files.
-- In the level file return a table with an update(dt) function inside
-- @param lvl Lua file to load
-- @return Level functions.
function LoadLevel(lvl)
  for i, block in ipairs(blocks) do
    if block.collidable == true then world:remove(block) end
    blocks[i] = nil
  end
  local loadedlvl = require(lvl)
  return loadedlvl
end
