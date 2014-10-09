map = require './map'
controller = require './controller'

class Tank

  id: no
  direction: 'right'  # up, right, down, left
  is_hold: yes  # yes if tank is not move
  wait: 0  # count turn no move

  bullets: 0  # how many bullets in map now
  bullets_max: 3  # how many bullets can be on map
  health: 3  # if tank was shuted healts - 1. If ==0 tank is dead

  place_on_map: [3, 1]  # [x, y]

  constructor: (@id)->

  ## return yes is tank was moved or one of property changed
  move: ->
    if @health < 0 then return no
    if @is_hold then return no

    x = @place_on_map[0]
    y = @place_on_map[1]

    switch @direction
      when "right" then x++
      when "left" then x--
      when "up" then y--
      when "down" then y++
      else return no

    if x <= 0 or y <= 0 or x > map.maxX() or y > map.maxY()
      @is_hold = yes
      return yes

    on_map = controller.whatOnTile x, y

    if not on_map
      @place_on_map = [x, y]
      return yes
    else
      if on_map[0] == 'tank'
        on_map[1].demage()
        @is_hold = yes
        return yes

  demage: ->
    @health = @health - 1


  toJson: ->
    id: @id
    direction: @direction
    is_hold: @is_hold
    wait: @wait
    bullets: @bullets
    bullets_max: @bullets_max
    health: @health
    place_on_map: @place_on_map


module.exports = Tank
