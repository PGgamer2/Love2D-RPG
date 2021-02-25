--- Main script
DEBUG = false

-- Libraries init
math = require "math"
Timer = require "libs/timer"
anim8 = require 'libs/anim8'
Camera = require "libs/camera"
require "catui"

bump = require 'libs/bump'

-- All of the controls are stored here.
controls = { up = { keys = {"w", "up"}, held = 0}, down = { keys = {"s", "down"}, held = 0},
             left = { keys = {"a", "left"}, held = 0}, right = { keys = {"d", "right"}, held = 0},
             inventory = { keys = {"i", "c"}, held = 0}, menu = { keys = {"escape", "p"}, held = 0},
             attack = { keys = {"x", "z", "f", "space"}, held = 0 --[[ Attack system TODO ]]}, interact = { keys = {"e", "return"}, held = 0} }

require "scripts/utilities"
require "scripts/blocks"
assets = require "assets/resources"
require "scripts/player"
require "scripts/ui"

-- Load main level
currentlvl = LoadLevel("levels/main")

--- Execute on start
function love.load(arg)
  min_dt = 1/60 -- FPS amount we want
  next_time = love.timer.getTime()

  -- Add player to the world and init camera
  world:add(player, player.x, player.y, player.w, player.h)
  cam = Camera(player.x + (player.w / 2), player.y + (player.h / 2))

  LoadUI()
end

--- Execute every frame
function love.update(dt)
  next_time = next_time + min_dt

  updatePlayer(dt)
  currentlvl.update(dt)

  -- Move camera
  local camdx, camdy = player.x + (player.w / 2) - cam.x, player.y + (player.h / 2) - cam.y
  cam:move(camdx / 2, camdy / 2)

  Timer.update(dt)
  uimgr:update(dt)
end

--- Detect key press
function love.keypressed(keypressed, scancode, isrepeat)
  -- Toggle debug mode if you press \ or del
  if keypressed == "\\" or keypressed == "delete" then
    DEBUG = not DEBUG
  end

  -- Toggle fullscreen if you press F11
  if keypressed == "f11" then
    love.window.setFullscreen(not love.window.getFullscreen())
    UpdateUIposition()
  end

  uimgr:keyDown(keypressed, scancode, isrepeat)
  OpenUIonKeyPressed(keypressed)

  playerKeyPressed(keypressed)

  player.finishedTalkingInThisUpdate = false
end

--- Detect key release
function love.keyreleased(keyreleased)
  -- Reset held counter when key is released
  for _, button in pairs(controls) do
    if hasValue(button.keys, keyreleased) then
      button.held = 0
    end
  end

  uimgr:keyUp(keyreleased)
end

--- Draw graphics
function love.draw()
  love.graphics.setColor(255, 255, 255)

  -- GFX scaling
  local ratio = math.min(love.graphics.getWidth() / 800, love.graphics.getHeight() / 600)
  cam:zoomTo(ratio)

  cam:attach()
  -- Draw first, second and third layer of objects
  for i=1, 3 do
    drawBlocks(i)
  end

  drawPlayer()

  -- Draw fourth, fifth and sixth layer.
  for i=4, 6 do
    drawBlocks(i)
  end

  cam:detach()
  -- Draw UI
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
