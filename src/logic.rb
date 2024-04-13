require 'set'
require 'ruby2d'

require_relative './block'
require_relative './shapes'
require_relative './vector2'


class Logic
  attr_accessor :gravity_speed, :running

  def initialize
    @blocks = []
    @gravity_speed = 60
    @score = 0
    @running = true
    @next_shape = nil
  end

  def score!
    blocks_by_y = Hash.new { |hash, key| hash[key] = [] }

    @blocks.each do |block|
      if block.status == BLOCK_STATUS[:FALLING]
        next
      end

      blocks_by_y[block.location.y].append(block)
    end

    score_factor = 0
    highest_y = 0
    ys = 0

    blocks_by_y.each do |y, blocks|
      if blocks.length == CONSTANTS::X_BLOCKS
        score_factor += 1

        blocks.each do |block|
          @blocks.delete(block)
        end

        if y > highest_y
          highest_y = y
        end

        ys += 1
      end
    end

    @blocks.each do |block|
      if block.status == BLOCK_STATUS[:LANDED] and block.location.y < highest_y
        block.position.y += ys * CONSTANTS::BLOCK_SIZE
      end
    end

    @score += score_factor ** 2 * 100

    @gravity_speed -= score_factor ** 2
  end

  def gravitate(blocks)
    blocks.each do |block|
      if block.status == BLOCK_STATUS[:FALLING]
        block.position.y += 1 * CONSTANTS::BLOCK_SIZE
      end
    end

    blocks
  end

  def falling?
    @blocks.any? { |block| block.status == BLOCK_STATUS[:FALLING]}
  end

  def land!
    @blocks.each do |block|
      block.status = BLOCK_STATUS[:LANDED]
    end
  end

  def generate_next_shape
    rotation_vector_list = $rotation_vectors_of_shapes.sample
    color = $color_of_shapes[$rotation_vectors_of_shapes.index(rotation_vector_list)]
    [rotation_vector_list, color]
  end

  def add_shape(blocks)
    if @next_shape
      rotation_vector_list, color = @next_shape
      @next_shape = generate_next_shape
    else
      @next_shape = generate_next_shape
      rotation_vector_list, color = @next_shape
      @next_shape = generate_next_shape
    end

    rotation_vector_list.each do |rotation_vector|
      block = Block.new(
        Vector2.new(CONSTANTS::X_BLOCKS/2, 2).scale!(CONSTANTS::BLOCK_SIZE),
        rotation_vector.clone.scale!(CONSTANTS::BLOCK_SIZE),
        color
      )

      blocks.append(block)
    end

    blocks
  end

  def rotate_falling_shape_clockwise_90(blocks)
    blocks.each do |block|
      if block.status == BLOCK_STATUS[:FALLING]
        block.rotation.set_coordinates(block.rotation.y, -block.rotation.x)
      end
    end

    blocks
  end

  def rotate_falling_shape_counterclockwise_90(blocks)
    blocks.each do |block|
      if block.status == BLOCK_STATUS[:FALLING]
        block.rotation.set_coordinates(-block.rotation.y, block.rotation.x)
      end
    end

    blocks
  end

  def move_falling_shape(blocks, vector)
    blocks.each do |block|
      if block.status == BLOCK_STATUS[:FALLING]
        block.position += vector
      end
    end
  end

  def inside_boundaries?(block)
    if block.location.x < 0 || block.location.y < 0
      return false
    end

    if block.location.x >= CONSTANTS::X_BLOCKS * CONSTANTS::BLOCK_SIZE || block.location.y >= CONSTANTS::Y_BLOCKS * CONSTANTS::BLOCK_SIZE
      return false
    end

    return true
  end

  def clone
    cloned_blocks = []

    @blocks.each do |block|
      cloned_blocks.append(block.clone)
    end

    cloned_blocks
  end

  def commit!(blocks)
    blocks.each do |block|
      if block.status == BLOCK_STATUS[:FALLING]
        unless inside_boundaries?(block)
          return false
        end
      end
    end

    # Collision detection
    return false if ( blocks.map { |block| block.to_s } ).uniq.length != blocks.length

    @blocks = blocks

    return true
  end

  def draw_blocks(blocks=@blocks)

    blocks.each do |block|
      Square.new(
        size: block.size,
        x: block.location.x,
        y: block.location.y,
        color: block.color,
      ).add
    end
  end

  def draw_score
    Text.new(
      "Score: #@score",
      x: 5, y: 10,
      style: 'bold',
      size: 23,
      color: 'black',
      z: 2,
    ).add
  end

  def draw_game_over
    game_over_message = "GAME OVER"

    game_over_text = Text.new(
      game_over_message,
      style: 'bold',
      size: 34,
      color: 'red',
      z: 2,
    )

    game_over_text.x = (CONSTANTS::X_BLOCKS*CONSTANTS::BLOCK_SIZE - game_over_text.width)/2
    game_over_text.y = (CONSTANTS::Y_BLOCKS*CONSTANTS::BLOCK_SIZE - game_over_text.height)/2

    game_over_text.add
  end

  def draw_next_shape
    return unless @next_shape

    rotation_vector_list, color = @next_shape

    blocks = []

    rotation_vector_list.each do |rotation_vector|
      block = Block.new(
        Vector2.new(CONSTANTS::X_BLOCKS/2, 2).scale!(CONSTANTS::BLOCK_SIZE),
        rotation_vector.clone.scale!(CONSTANTS::BLOCK_SIZE),
        color,
        CONSTANTS::BLOCK_SIZE
      )


      block.color = Color.new([180, 180, 180, 0.5])

      blocks.append(block)
    end

    draw_blocks(blocks)
  end
end
