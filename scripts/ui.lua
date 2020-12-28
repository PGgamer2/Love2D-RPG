--- Manage and draw UI using catui.

uimgr = UIManager:getInstance()
escbtn = UIButton:new()
inventoryContent = UIContent:new()
WIPInventoryLabel = UILabel:new("assets/font.ttf", "The inventory is currently W.I.P.", 26)

--- Load every UI element.
function LoadUI()
  -- Exit button
  escbtn:setSize(200, 50)
  escbtn:setText("Exit")
  escbtn.events:on(UI_CLICK, function()
    love.event.quit()
  end)
  -- Inventory
  inventoryContent:setSize(700, 500)
  inventoryContent:setContentSize(1400, 1000)
  WIPInventoryLabel:setFontColor({255, 255, 255})
  inventoryContent:addChild(WIPInventoryLabel)

  UpdateUIposition()
end

--- Update the position of every UI element.
function UpdateUIposition()
  escbtn:setPos(love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 - 25)
  inventoryContent:setPos(love.graphics.getWidth() / 2 - 350, love.graphics.getHeight() / 2 - 250)
end

--- Open UI elements.
-- @param keypressed The key that has been pressed by the user
function OpenUIonKeyPressed(keypressed)
  -- Open inventory
	if player.canOpenInventory then
		for _,inventoryButton in ipairs(controls.inventory.keys) do
			if keypressed == inventoryButton then
        controls.inventory.held = 1
				if player.inventoryIsOpen then
					player.inventoryIsOpen = false
					player.canMove = true
					player.canInteract = true
          uimgr.rootCtrl.coreContainer:removeChild(inventoryContent)
				else
					player.inventoryIsOpen = true
					player.canMove = false
					player.canInteract = false
          uimgr.rootCtrl.coreContainer:addChild(inventoryContent)
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
end
