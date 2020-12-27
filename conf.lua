-- Configuration file
function love.conf(t)
	t.title = "LÖVE2D RPG"   -- The title of the window
	t.version = "11.3"       -- The LÖVE version we are using

  -- Window starting size
	t.window.width = 800
	t.window.height = 600

  -- Use VSync
	t.window.vsync = 1

	-- Used for debugging
	t.console = true
end
