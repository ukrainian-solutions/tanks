controller = require './controller'
map = require './map'

class Bullet

  id: no
  tank: no
  type: ""
  is_on_fly: no
  place_on_map: no
  direction: no

  speed: 0
  speed_i: 0
  demage: 0


  constructor: (@tank)->
    @id = controller.getNewBulletId()

  use: (tank)-> if @is_on_fly
    console.log tank.id, 'was demaged by bullet', @id, 'from tank', @tank.id
    if @demage >= tank.health
      @tank.destroyed += 1
      @tank.demage_inflicted += tank.health

      tank.damage_obtained += tank.health
      tank.health = 0
      tank.respawn_i = tank.respawn_after
      tank.sendInfo 'defeated', no
    else
      @tank.demage_inflicted += @demage
      tank.damage_obtained += @demage
      tank.health -= @demage
      tank.sendInfo 'demage', ['healthDOWN']

  fire: ->
    @place_on_map = @tank.place_on_map
    @is_on_fly = yes
    @direction = @tank.direction
    controller.appendBullet @
    @move()

  move: -> if @is_on_fly
    x = @place_on_map[0]
    y = @place_on_map[1]
    switch @direction
      when "right" then x++
      when "left" then x--
      when "up" then y--
      when "down" then y++

    if x < 0 or y < 0 or x > map.maxX() or y > map.maxY()
      controller.removeBullet @
      return no

    tile = map.getTile x,y
    if tile is 0
      on_tile = controller.whatOnTile(x,y)
      if on_tile != no
        if on_tile[0] == "boost"
          controller.removeBoost on_tile[1]
          @place_on_map = [x,y]
          return no
        if on_tile[0] == "bullet"
          controller.removeBullet on_tile[1]
          controller.removeBullet @
          return no
        if on_tile[0] == "tank"
          @use on_tile[1]
          controller.removeBullet @
          return on_tile[1]
    else if tile is 1
      controller.removeBullet @
      return no
    @place_on_map = [x,y]
    return no

  toJson: -> [@id
              @type
              @tank.id
              @is_on_fly
              @place_on_map
              @direction
              @speed
              @demage]


exports.light = class LightBullet extends Bullet
  type: "light"
  demage: 1

exports.big = class BigBullet extends Bullet
  type: "big"
  demage: 3

exports.super = class SuperBullet extends Bullet
  type: "suepr"
  demage: 10
