--- Player movements and drawing.

-- Init player
player = {x = 0, y = 0, w = 64, h = 64, goalX = 0, goalY = 0, cols = {}, len = 0,
          isMoving = false, direction = 0, axis = 0, vel = 3, visible = true,
          canMove = true, canInteract = true, inventory = {},
          MenuIsOpen = false, canOpenMenu = true,
          canOpenInventory = true, inventoryIsOpen = false}

playerAnimations = {up    = anim8.newAnimation(anim8.newGrid(64, 64, assets.player.up.walk:getWidth(),    assets.player.up.walk:getHeight())   ('1-8',1), 0.1),
                    left  = anim8.newAnimation(anim8.newGrid(64, 64, assets.player.left.walk:getWidth(),  assets.player.left.walk:getHeight()) ('1-8',1), 0.1),
                    down  = anim8.newAnimation(anim8.newGrid(64, 64, assets.player.down.walk:getWidth(),  assets.player.down.walk:getHeight()) ('1-8',1), 0.1),
                    right = anim8.newAnimation(anim8.newGrid(64, 64, assets.player.right.walk:getWidth(), assets.player.right.walk:getHeight())('1-8',1), 0.1)}

--- Player movements.
-- @param dt Time since the last update in seconds.
function updatePlayer(dt)
  if player.canMove == true then
    -- Vertical movements
    if love.keyboard.isDown(controls.up.keys) then
      player.goalY = player.y - player.vel
      controls.up.held = controls.up.held + 1
      controls.down.held = 0
    elseif love.keyboard.isDown(controls.down.keys) then
      player.goalY = player.y + player.vel
      controls.down.held = controls.down.held + 1
    end
    -- Horizontal movements
    if love.keyboard.isDown(controls.left.keys) then
      player.goalX = player.x - player.vel
      controls.left.held = controls.left.held + 1
      controls.right.held = 0
    elseif love.keyboard.isDown(controls.right.keys) then
      player.goalX = player.x + player.vel
      controls.right.held = controls.right.held + 1
    end

    -- Update direction
    oldestkey = math.max(controls.right.held, controls.left.held, controls.up.held, controls.down.held)
    if (love.keyboard.isDown(controls.up.keys) and oldestkey == controls.up.held) or
       (love.keyboard.isDown(controls.down.keys) and oldestkey == controls.down.held) then
      player.axis = 0
    elseif (love.keyboard.isDown(controls.right.keys) and oldestkey == controls.right.held) or
           (love.keyboard.isDown(controls.left.keys) and oldestkey == controls.left.held) then
      player.axis = 1
    end

    if player.axis == 0 and love.keyboard.isDown(controls.up.keys) then
      player.direction = 2
    elseif player.axis == 0 and love.keyboard.isDown(controls.down.keys) then
      player.direction = 0
    end
    if player.axis == 1 and love.keyboard.isDown(controls.left.keys) then
      player.direction = 3
    elseif player.axis == 1 and love.keyboard.isDown(controls.right.keys) then
      player.direction = 1
    end

    player.x, player.y, player.cols, player.len = world:move(player, player.goalX, player.goalY)
  end

  -- Update player animations
  for _, animName in pairs(playerAnimations) do
    animName:update(dt)
  end
end

--- Draw the player.
function drawPlayer()
  if player.visible == true then
    if DEBUG then love.graphics.rectangle("fill", player.x, player.y, player.w, player.h) end
    local playerXmiddle = player.x + (player.w / 2)
    local playerYmiddle = player.y + (player.h / 2)

    local playerCurrentSprite
    local playerCurrentAnim

    if player.direction == 0 then
      if controls.down.held == 0 then playerCurrentSprite = assets.player.down.idle
      else
        playerCurrentSprite = assets.player.down.walk
        playerCurrentAnim = playerAnimations.down
      end
    end
    if player.direction == 1 then
      if controls.right.held == 0 then playerCurrentSprite = assets.player.right.idle
      else
        playerCurrentSprite = assets.player.right.walk
        playerCurrentAnim = playerAnimations.right
      end
    end
    if player.direction == 2 then
      if controls.up.held == 0 then playerCurrentSprite = assets.player.up.idle
      else
        playerCurrentSprite = assets.player.up.walk
        playerCurrentAnim = playerAnimations.up
      end
    end
    if player.direction == 3 then
      if controls.left.held == 0 then playerCurrentSprite = assets.player.left.idle
      else
        playerCurrentSprite = assets.player.left.walk
        playerCurrentAnim = playerAnimations.left
      end
    end

    if playerCurrentAnim ~= nil then
      local animWidth, animHeight = playerCurrentAnim:getDimensions()
      playerCurrentAnim:draw(playerCurrentSprite, playerXmiddle - (animWidth / 2), playerYmiddle - (animHeight / 2))
      player.isMoving = true
    else
      love.graphics.draw(playerCurrentSprite, playerXmiddle - (playerCurrentSprite:getWidth() / 2), playerYmiddle - (playerCurrentSprite:getHeight() / 2))
      for _, animName in pairs(playerAnimations) do
        animName:gotoFrame(1)
      end
      player.isMoving = false
    end
  end
end

--- Player actions when keys are pressed.
-- @param keypressed The key that has been pressed by the user
function playerKeyPressed(keypressed)
  -- Execute object function when touching and interacting
  if player.canInteract then
    for _,interactButton in ipairs(controls.interact.keys) do
      if keypressed == interactButton then
        controls.interact.held = 1
        for i=1, player.len do
          if player.cols[i].other.execOnInteract ~= nil then
            player.cols[i].other.execOnInteract(player.cols[i].other.id)
          end
        end
      end
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
