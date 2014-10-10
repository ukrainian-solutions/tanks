controller = require './controller'

class Boost

  id: no
  place_on_map: no

  healthUP: no
  healthDOWN: no
  speedUP: no
  speedDOWN: no

  constructor: (@place_on_map)->
    @id = controller.getNewBoostId()

  use: (tank)->
    console.log 'USE BOOST', @id
    controller.removeBoost @
    if @healthUP
      tank.health = tank.health + @healthUP
      tank.sendInfo 'boost', ["healthUP"]
    else if @healthDOWN
      if tank.health > @healthDOWN then tank.health = tank.health - @healthDOWN
      else tank.health = 1
      tank.sendInfo 'boost', ["healthDOWN"]

    if @speedUP
      if tank.speed-@speedUP > 0
        tank.speed = tank.speed-@speedUP
      else
        tank.speed = 1

      tank.sendInfo 'boost', ["speedUP-#{tank.speed}"]

  toJson: -> [@place_on_map, @type]


exports.speedUP = class BoostSpeedUP extends Boost
  type: "speedUP"
  speedUP: 3


exports.healthUP = class BoostHealthUP extends Boost
  type: "healthUP"
  healthUP: Math.floor(Math.random()*10)
