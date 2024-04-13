require 'ruby2d'

require_relative './vector2'

module CONSTANTS
  BLOCK_SIZE = 33
  X_BLOCKS = 11
  Y_BLOCKS = 18
  GRID_COLOR = "black"
  BACKGROUND_COLOR = "#87CEEB"
end


BLOCK_STATUS = {
  FALLING: 0,
  LANDED: 1,
}

class Block
  attr_accessor :position, :rotation, :status, :color, :size

  def initialize(position=Vector2.new, rotation=Vector2.new, color="random", status=BLOCK_STATUS[:FALLING], size=CONSTANTS::BLOCK_SIZE)
    @position = position
    @rotation = rotation
    @status = status
    @color = color
    @size = size
  end

  def set_location(position=Vector2.new, rotation=Vector2.new)
    @position = position
    @rotation = rotation
  end

  def location
    @position + @rotation
  end

  def to_s
    "<Block #{location()}>"
  end

  def hash
    to_s.hash
  end

  def clone
    Block.new(@position.clone, @rotation.clone, @color, @status, @size)
  end
end
