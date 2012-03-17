-- A triple bouncing fireball that the hero cannot fight

local speed = 192
local bounces = 0
local max_bounces = 8
local sprite2 = nil
local sprite3 = nil

function event_appear()

  sol.enemy.set_life(1)
  sol.enemy.set_damage(8)
  sol.enemy.create_sprite("enemies/blue_fireball_triple")
  sol.enemy.set_size(16, 16)
  sol.enemy.set_origin(8, 8)
  sol.enemy.set_obstacle_behavior("flying")
  sol.enemy.set_invincible()
  sol.enemy.set_attack_consequence("sword", "custom")

  -- two smaller fireballs just for the displaying
  sprite2 = sol.sprite.create("enemies/blue_fireball_triple")
  sprite2:set_animation("small")
  sprite3 = sol.sprite.create("enemies/blue_fireball_triple")
  sprite3:set_animation("tiny")
end

function event_restart()

  local x, y = sol.enemy.get_position()
  local hero_x, hero_y = sol.map.hero_get_position()
  local angle = sol.main.get_angle(x, y, hero_x, hero_y - 5)
  local m = sol.movement.straight_movement_create(speed, angle)
  --m:set_property("ignore_obstacles", true)
  sol.enemy.start_movement(m)
end

function event_obstacle_reached()

  if bounces < max_bounces then

    -- compute the bouncing angle
    -- (works good with horizontal and vertical walls)
    local m = sol.enemy.get_movement()
    local angle = m:get_property("angle")
    if not m:test_obstacles(1, 0)
      and not m:test_obstacles(-1, 0) then
      angle = -angle
    else
      angle = math.pi - angle
    end

    m:set_property("angle", angle)
    m:set_property("speed", speed)

    bounces = bounces + 1
    speed = speed + 48
  else
    sol.map.enemy_remove(sol.enemy.get_name())
  end
end

function event_custom_attack_received(attack, sprite)

  if attack == "sword" then
    -- explode
    local x, y, layer = sol.enemy.get_position()
    sol.map.hero_start_hurt(x, y, 8, 0)
    sol.audio.play_sound("explosion")
    sol.map.explosion_create(x, y, layer)
    sol.map.enemy_remove(sol.enemy.get_name())
  end
end

function event_pre_display()

  local m = sol.enemy.get_movement()
  local angle = m:get_property("angle")
  local x, y = sol.enemy.get_position()

  local x2 = x - math.cos(angle) * 12
  local y2 = y + math.sin(angle) * 12

  local x3 = x - math.cos(angle) * 24
  local y3 = y + math.sin(angle) * 24

  sol.map.sprite_display(sprite2, x2, y2)
  sol.map.sprite_display(sprite3, x3, y3)
end

