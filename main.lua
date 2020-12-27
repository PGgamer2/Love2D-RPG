-- Main script
DEBUG = false

-- Libraries init
math = require "math"
anim8 = require 'libs/anim8'
require "globalfunc"
assets = require "assets/resources"
Camera = require "libs/camera"

require "catui"
uimgr = UIManager:getInstance()
escbtn = UIButton:new()

bump = require 'libs/bump'
world = bump.newWorld() -- create a world with bump

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

-- All of the controls are stored here.
controls = { up = { keys = {"w", "up"}, held = 0}, down = { keys = {"s", "down"}, held = 0},
             left = { keys = {"a", "left"}, held = 0}, right = { keys = {"d", "right"}, held = 0},
             inventory = { keys = {"i", "c"}, held = 0}, menu = { keys = {"escape", "p"}, held = 0},
             attack = { keys = {"x", "z", "f"}, held = 0 --[[ Attack system TODO ]]}, interact = { keys = {"e", "return"}, held = 0} }

-- Player movements
local function updatePlayer(dt)
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
end

-- Execute on start
function love.load(arg)
  min_dt = 1/60 -- FPS amount we want
  next_time = love.timer.getTime()

  -- Add player to the world and init camera
  world:add(player, player.x, player.y, player.w, player.h)
  cam = Camera(player.x + (player.w / 2), player.y + (player.h / 2))

  -- Load main level
  currentlvl = LoadLevel("levels/main")

  -- UI things
  escbtn:setPos(love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 - 25)
  escbtn:setSize(200, 50)
  escbtn:setText("Exit")
  escbtn.events:on(UI_CLICK, function()
    love.event.quit()
  end)
end

-- Execute every frame
function love.update(dt)
  next_time = next_time + min_dt

  updatePlayer(dt)
  currentlvl.update(dt)

  -- Move camera
  local camdx, camdy = player.x + (player.w / 2) - cam.x, player.y + (player.h / 2) - cam.y
  cam:move(camdx / 2, camdy / 2)

  uimgr:update(dt)

  -- Update player animations
  for _, animName in pairs(playerAnimations) do
    animName:update(dt)
  end
end

-- Detect keypress
function love.keypressed(keypressed, scancode, isrepeat)
  -- Toggle debug mode if you press \ or del
  if keypressed == "\\" or keypressed == "delete" then
    DEBUG = not DEBUG
  end

  -- Toggle fullscreen if you press F11
  if keypressed == "f11" then
    love.window.setFullscreen(not love.window.getFullscreen())
    escbtn:setPos(love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 - 25)
  end

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

	-- Open inventory
	if player.canOpenInventory then
		for _,inventoryButton in ipairs(controls.inventory.keys) do
			if keypressed == inventoryButton then
        controls.inventory.held = 1
				if player.inventoryIsOpen then
					player.inventoryIsOpen = false
					player.canMove = true
					player.canInteract = true
				else
					player.inventoryIsOpen = true
					player.canMove = false
					player.canInteract = false
				end
			end
		end
	end

  -- Open menu
  if player.canOpenMenu then
		for _,menuButton in ipairs(controls.menu.keys) do
			if keypressed == menuButton then
        controls.menu.held = 1
				if player.MenuIsOpen then
					player.MenuIsOpen = false
          if not player.inventoryIsOpen then
  					player.canMove = true
  					player.canInteract = true
          end
          player.canOpenInventory = true
          -- Remove UI items
          uimgr.rootCtrl.coreContainer:removeChild(escbtn)
				else
					player.MenuIsOpen = true
					player.canMove = false
					player.canInteract = false
          player.canOpenInventory = false
          -- Add UI items
          uimgr.rootCtrl.coreContainer:addChild(escbtn)
				end
			end
		end
	end

  uimgr:keyDown(keypressed, scancode, isrepeat)
end

function love.keyreleased(keyreleased)
	-- Reset held counter when key is released
	for _, button in pairs(controls) do
    if hasValue(button.keys, keyreleased) then
  		button.held = 0
  	end
  end

  uimgr:keyUp(keyreleased)
end

-- Draw graphics
function love.draw()
	love.graphics.setColor(255, 255, 255)

	cam:attach()
	local ratio = math.min(love.graphics.getWidth() / 800, love.graphics.getHeight() / 600)
	love.graphics.scale(ratio, ratio) -- GFX scaling

  drawBlocks() -- Draw world objects

  if player.visible == true then
    -- Draw player
    if DEBUG then love.graphics.rectangle("fill", player.x, player.y, player.w, player.h) end
    local playerXmiddle = player.x + (player.w / 2)
    local playerYmiddle = player.y + (player.h / 2)

    local playerCurrentSprite
    local playerCurrentAnim

    if player.direction == 0 then
      if controls.down.held == 0 then
        playerCurrentSprite = assets.player.down.idle
      else
        playerCurrentSprite = assets.player.down.walk
        playerCurrentAnim = playerAnimations.down
      end
    end
    if player.direction == 1 then
      if controls.right.held == 0 then
        playerCurrentSprite = assets.player.right.idle
      else
        playerCurrentSprite = assets.player.right.walk
        playerCurrentAnim = playerAnimations.right
      end
    end
    if player.direction == 2 then
      if controls.up.held == 0 then
        playerCurrentSprite = assets.player.up.idle
      else
        playerCurrentSprite = assets.player.up.walk
        playerCurrentAnim = playerAnimations.up
      end
    end
    if player.direction == 3 then
      if controls.left.held == 0 then
        playerCurrentSprite = assets.player.left.idle
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

	cam:detach()
	-- Draw UI
	if (player.inventoryIsOpen) then
    -- Inventory TODO
		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("fill", 70, 70, love.graphics.getWidth() - 140, love.graphics.getHeight() - 140)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", 80, 80, love.graphics.getWidth() - 160, love.graphics.getHeight() - 160)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Inventory (work in progress)", 100, 100)
	end

  uimgr:draw()

  if DEBUG then
    love.graphics.print(love.timer.getFPS() .. " FPS", 0, 0)
    love.graphics.print("X: " .. tostring(player.x), 0, 15)
    love.graphics.print("Y: " .. tostring(player.y), 0, 30)
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 2, 0, 4, love.graphics.getHeight())
		love.graphics.rectangle("fill", 0, love.graphics.getHeight() / 2 - 2, love.graphics.getWidth(), 4)
  end

  -- Cap FPS at 60
  -- [https://love2d.org/wiki/love.timer.sleep#More_sophisticated_way_to_cap_30_FPS]
  local cur_time = love.timer.getTime()
   if next_time <= cur_time then
      next_time = cur_time
      return
   end
   love.timer.sleep(next_time - cur_time)
end

function love.mousemoved(x, y, dx, dy)
    uimgr:mouseMove(x, y, dx, dy)
end

function love.mousepressed(x, y, button, isTouch)
    uimgr:mouseDown(x, y, button, isTouch)
end

function love.mousereleased(x, y, button, isTouch)
    uimgr:mouseUp(x, y, button, isTouch)
end

function love.wheelmoved(x, y)
    uimgr:whellMove(x, y)
end

function love.textinput(text)
    uimgr:textInput(text)
end
