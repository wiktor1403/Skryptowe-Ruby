require 'ruby2d'

set title: "Mario in Ruby2D", width: 1280, height: 480

# Game settings
ground_height = 40
level_width = 2560  # A larger level width for scrolling
hole_width = 100
plank_width = 200
plank_height = 20  # Height of the plank
plank_gap = 100    # Height above the ground where the plank is located

# Player settings
player = Sprite.new('mario.png', x: 50, y: 440 - ground_height, width: 40, height: 40)

# Ground settings (bigger level)
ground = Rectangle.new(x: 0, y: 440, width: level_width, height: ground_height, color: 'green')

# Create fixed holes at predefined positions (wider holes beneath floating planks)
holes = [
  Rectangle.new(x: 500, y: 440, width: hole_width + 50, height: ground_height, color: 'blue'),
  Rectangle.new(x: 1200, y: 440, width: hole_width + 50, height: ground_height, color: 'blue'),
  Rectangle.new(x: 1800, y: 440, width: hole_width + 50, height: ground_height, color: 'blue')
]

# Create floating planks at predefined positions
planks = [
  Rectangle.new(x: 400, y: 350 - plank_height, width: plank_width, height: plank_height, color: 'brown'),
  Rectangle.new(x: 1000, y: 350 - plank_height, width: plank_width, height: plank_height, color: 'brown'),
  Rectangle.new(x: 1600, y: 350 - plank_height, width: plank_width, height: plank_height, color: 'brown')
]

# Create traps at fixed positions (represented as red rectangles)
traps = [
  Rectangle.new(x: 800, y: 440 - ground_height, width: 40, height: 40, color: 'red'),
  Rectangle.new(x: 1300, y: 440 - ground_height, width: 40, height: 40, color: 'red'),
  Rectangle.new(x: 2050, y: 440 - ground_height, width: 40, height: 40, color: 'red')
]

gravity = 1
velocity_y = 0
jump_power = -15
on_ground = true
on_plank = false

# Flag to track if the game is over
game_over = false
win_game = false

# Camera settings
camera_x = 0
camera_width = 1280
camera_height = 480

# Text messages for Game Over and Win
# game_over_message = Text.new('Game Over!', x: 320, y: 200, size: 40, color: 'red', z: 10)
# win_message = Text.new('You Win!', x: 470, y: 200, size: 40, color: 'green', z: 10)

# Update loop
update do
  # End the game if Mario has fallen into any hole or touched a trap
  if game_over
    game_over_message = Text.new('Game Over!', x: 320, y: 200, size: 40, color: 'red', z: 10)
    return
  end

  # Win the game if Mario reaches the right edge of the level
  if player.x >= camera_width - player.width && camera_x == level_width - camera_width
    win_game = true
    win_message = Text.new('You Win!', x: 470, y: 200, size: 40, color: 'green', z: 10)
    return
  end

  velocity_y += gravity unless on_ground
  player.y += velocity_y

  plank_hit = planks.find { |p| player.x + player.width > p.x && player.x < p.x + p.width && player.y + player.height <= p.y + plank_height && player.y + player.height + velocity_y > p.y }
  if plank_hit
    player.y = plank_hit.y - player.height
    velocity_y = 0
    on_plank = true
  else
    on_plank = false
  end

  # Check if Mario has landed on the ground
  if player.y >= 440 - ground_height  
    hole_hit = holes.find { |h| player.x + player.width / 2 > h.x && player.x + player.width / 2 < h.x + h.width }
    
    if hole_hit
      on_ground = false
      # Mario has fallen into a hole (beyond the hole's bottom)
      if player.y >= 480  # Mario has fallen to the bottom of the screen
        game_over = true  # End the game
      end
    else
      player.y = 440 - ground_height
      velocity_y = 0
      on_ground = true
    end
  else
    on_ground = false
  end

  # Check if Mario touches any trap
  trap_hit = traps.find { |t| player.x + player.width > t.x && player.x < t.x + t.width && player.y + player.height > t.y && player.y < t.y + t.height }
  if trap_hit
    game_over = true  # End the game if Mario touches a trap
  end
end

on :key_held do |event|
  case event.key
  when 'left'
    if player.x < (camera_width / 5) && camera_x > 0
      camera_x -= 5
      ground.x += 5
      holes.each { |h| h.x += 5 }
      planks.each { |p| p.x += 5 }
      traps.each { |t| t.x += 5 }
    else
      player.x -= 5 unless player.x <= 0
    end
  when 'right'
    if player.x > (camera_width - camera_width / 5) && camera_x < level_width - camera_width
      camera_x += 5
      ground.x -= 5
      holes.each { |h| h.x -= 5 }
      planks.each { |p| p.x -= 5 }
      traps.each { |t| t.x -= 5 }
    else
      player.x += 5 unless player.x >= camera_width - player.width && camera_x == level_width - camera_width
    end
  end
end

on :key_down do |event|
  if event.key == 'space' && ( on_ground || on_plank )
    velocity_y = jump_power
    on_ground = false
  end
end

show
