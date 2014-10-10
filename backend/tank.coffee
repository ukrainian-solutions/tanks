map = require './map'
controller = require './controller'

class Tank

  id: no
  direction: 'right'  # up, right, down, left
  is_hold: yes  # yes if tank is not move
  wait: 0  # count turn no move

  bullets: 0  # how many bullets in map now
  bullets_max: 3  # how many bullets can be on map
  health: 9  # if tank was shuted healts - 1. If ==0 tank is dead
  respawn_after: 10
  respawn_i: -1

  speed: controller.tankMaxSpeed()
  speed_i: 0

  damage_inflicted: 0
  demage_obtained: 0
  destroyed: 0

  place_on_map: [3, 1]  # [x, y]

  constructor: (@id)->

  ## return yes is tank was moved or one of property changed
  move: ->
    if @speed_i > 0
      @speed_i--
      return no

    if @health <= 0
      if @respawn_i == 0 then @health = 9
      @respawn_i = @respawn_i - 1
      return no
    if @wait > 0
      @wait = @wait - 1
      return yes
    @speed_i = @speed

    if @is_hold then return no

    x = @place_on_map[0]
    y = @place_on_map[1]

    switch @direction
      when "right" then x++
      when "left" then x--
      when "up" then y--
      when "down" then y++
      else return no

    if x < 0 or y < 0 or x > map.maxX() or y > map.maxY()
      @is_hold = yes
      return yes

    on_map = controller.whatOnTile x, y
    # console.log 'on map', on_map
    if not on_map
      tile = map.getTile x, y
      if tile is 0
        @place_on_map = [x, y]
      else if tile is 1
        @is_hold = yes
        console.log @id, 'stopped by wall'
      else if tile is 3
        @wait = @wait + 2
        @place_on_map = [x, y]
        console.log @id, 'in dirty'
      else if tile is 4
        @is_hold = yes
        console.log @id, 'stopped by water'
      return yes
    else
      if on_map[0] == 'tank'
        demage = on_map[1].demage(@)
        if demage is "destroy"
          @destroyed += 1
          @health += 2
        else @damage_inflicted = demage
        @is_hold = yes
        return [yes, on_map[1]]

  demage: (tank)->
    console.log @id, 'was demaged by ', tank.id
    if @health > 0
      demage = 1
      @health = @health - demage
      @demage_obtained += demage
      if @health == 0
        @respawn_i = @respawn_after
        return "destroy"
      return demage
    return 0


  toJson: -> [@id
              @direction
              @is_hold
              @wait
              @bullets
              @bullets_max
              @health
              @place_on_map
              @damage_inflicted
              @demage_obtained
              @destroyed]

module.exports = Tank
