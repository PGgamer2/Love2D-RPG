--- Manage and draw UI using catui.

uimgr = UIManager:getInstance()

escbtn = UIButton:new()
inventoryContent = UIContent:new()

dialogContent = UIContent:new()
dialogLabel = UILabel:new("assets/font.ttf", "", 20)
local labelTimers = {}
local dialogText

--- Load every UI element.
function LoadUI()
  -- Exit button
  escbtn:setSize(200, 50)
  escbtn:setText("Exit")
  escbtn.events:on(UI_CLICK, function()
    love.event.quit()
  end)
  -- Inventory
  WIPInventoryLabel = UILabel:new("assets/font.ttf", "The inventory is currently W.I.P.", 26)
  inventoryContent:setSize(700, 500)
  inventoryContent:setContentSize(700, 500)
  WIPInventoryLabel:setFontColor({255, 255, 255})
  inventoryContent:addChild(WIPInventoryLabel)
  -- Dialog
  dialogContent:setSize(600, 176)
  dialogLabel:setFontColor({255, 255, 255})
  dialogLabel:setAutoSize(false)
  dialogLabel:setSize(580, 165)
  dialogContent:addChild(dialogLabel)

  UpdateUIposition()
end

--- Update the position of every UI element.
function UpdateUIposition()
  escbtn:setPos(love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 - 25)
  inventoryContent:setPos(love.graphics.getWidth() / 2 - 350, love.graphics.getHeight() / 2 - 250)
  dialogContent:setPos(love.graphics.getWidth() / 2 - 300, love.graphics.getHeight() - 200)
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
          if not player.isTalking then
            if not player.inventoryIsOpen then
    					player.canMove = true
    					player.canInteract = true
            end
            player.canOpenInventory = true
          end
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

  -- Dialog
  if player.isTalking then
    for _,interactButton in ipairs(controls.interact.keys) do
      if keypressed == interactButton then
        if player.dialogIsEnded then
          uimgr.rootCtrl.coreContainer:removeChild(dialogContent)
          if dialogText:sub(1, 1) == "@" then
            openDialog(dialogText:sub(2, #dialogText))
          else
            if not player.MenuIsOpen then
              player.canOpenInventory = true
              player.canInteract = true
              player.canMove = true
            end
            player.isTalking = false
            player.finishedTalkingInThisUpdate = true
          end
        else
          for i = 1, #dialogText do
            if dialogText:sub(i, i) == "@" then
              finishDialog(dialogText:sub(1, i - 1))
              dialogText = dialogText:sub(i, #dialogText)
              break
            end
            if i == #dialogText then
              finishDialog(dialogText)
            end
          end
        end
      end
    end
  end
end

--- Open a dialog.
-- @param text The text in the dialog. You can use the @ character to separate the dialog in multiple windows.
-- @param t Time between two characters. default: 20
function openDialog(text, t)
  if t == nil then t = 20 end
  if not player.finishedTalkingInThisUpdate then
    finishDialog()
    player.canOpenInventory = false
    player.canInteract = false
    player.canMove = false

    player.isTalking = true
    player.dialogIsEnded = false
    uimgr.rootCtrl.coreContainer:addChild(dialogContent)

    dialogText = text
    for i = 1, #text do
      if text:sub(i, i) == "@" then
        labelTimers[i] = Timer.after(i / t, function()
          finishDialog(text:sub(1, i - 1))
          dialogText = text:sub(i, #text)
        end)
        break
      else
        labelTimers[i] = Timer.after(i / t, function()
          dialogLabel:setText(text:sub(1, i))
          if i == #text then
            finishDialog(text)
          end
        end)
      end
    end
  end
end

--- End the current dialog.
-- @param text The text that will be displayed instead of the current one.
function finishDialog(text)
  for _, cTimer in ipairs(labelTimers) do
    Timer.cancel(cTimer)
  end
  dialogLabel:setText(text)
  player.dialogIsEnded = true
end
