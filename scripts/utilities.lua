--- Useful things.

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
