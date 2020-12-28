love.graphics.setDefaultFilter("nearest", "nearest") -- Use nearest neighbor interpolation by default

local assets = {
  player = {
    up    = {idle = cropImage("assets/player.png", 0, 0,   64, 64), walk = cropImage("assets/player.png", 64, 0,   512, 64)},
    left  = {idle = cropImage("assets/player.png", 0, 64,  64, 64), walk = cropImage("assets/player.png", 64, 64,  512, 64)},
    down  = {idle = cropImage("assets/player.png", 0, 128, 64, 64), walk = cropImage("assets/player.png", 64, 128, 512, 64)},
    right = {idle = cropImage("assets/player.png", 0, 192, 64, 64), walk = cropImage("assets/player.png", 64, 192, 512, 64)}
  },

  library = cropImage("assets/tiles.png", 128, 325, 64, 59),
  box = cropImage("assets/tiles.png", 290, 481, 28, 30),

  statue = {top = cropImage("assets/tiles.png", 356, 426, 24, 63),
            bottom = cropImage("assets/tiles.png", 355, 489, 26, 19)}
}

return assets
