require 'ruby2d'

require_relative './logic'
require_relative './vector2'
require_relative './block'


set title: 'Tetris',
    width: CONSTANTS::X_BLOCKS*CONSTANTS::BLOCK_SIZE,
    height: CONSTANTS::Y_BLOCKS*CONSTANTS::BLOCK_SIZE,
    background: CONSTANTS::BACKGROUND_COLOR


theme_music = Music.new("tetris.mp3")
theme_music.play
theme_music.loop = true

def draw_grid
  window_width = Window.width
  window_height = Window.height
  block_size = CONSTANTS::BLOCK_SIZE

  (0..CONSTANTS::X_BLOCKS).each do |x|
    Line.new(
      x1: x * block_size, y1: 0,
      x2: x * block_size, y2: window_height,
      width: 1,
      color: CONSTANTS::GRID_COLOR,
      z: 1
    )
  end

  (0..CONSTANTS::Y_BLOCKS).each do |y|
    Line.new(
      x1: 0, y1: y * block_size,
      x2: window_width, y2: y * block_size,
      width: 1,
      color: CONSTANTS::GRID_COLOR,
      z: 1
    )
  end
end

logic = Logic.new
$gravity_speed = logic.gravity_speed

on :key_down do |event|
  case event.key
    when 'a', :left
      logic.commit!(logic.move_falling_shape(logic.clone, Vector2.new(-1*CONSTANTS::BLOCK_SIZE, 0)))
    when 'w', :up
      logic.commit!(logic.rotate_falling_shape_clockwise_90(logic.clone))
    when 'd', :right
      logic.commit!(logic.move_falling_shape(logic.clone, Vector2.new(1*CONSTANTS::BLOCK_SIZE, 0)))
    when 's', :down
      logic.commit!(logic.rotate_falling_shape_counterclockwise_90(logic.clone))
    when 'space'
      $gravity_speed = ( logic.gravity_speed * 0.05 ).to_i
  end
end

on :key_up do |event|
  case event.key
    when 'space'
      $gravity_speed = logic.gravity_speed
  end
end


tick = 0

update do
  next unless logic.running

  # Gravity
  if tick % $gravity_speed == 0
    unless logic.commit!(logic.gravitate(logic.clone))
      logic.land!
    end
  end

  tick += 1

  # Score
  logic.score!

  # Draw
  clear

  draw_grid
  logic.draw_next_shape
  logic.draw_blocks
  logic.draw_score

  # New Shape
  unless logic.falling?
    unless logic.commit!(logic.add_shape(logic.clone))
      logic.draw_game_over
      logic.running=false

      def close_window
        sleep 3
        close
      end

      Thread.new { close_window }
    end
  end
end

show
