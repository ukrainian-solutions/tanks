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
  speedUP: 1


exports.healthUP = class BoostHealthUP extends Boost
  type: "healthUP"
  healthUP: Math.floor(Math.random()*10)


exports.mystery =  class BoostMystery extends Boost
  type: "mystery"

  use: (tank)->
    switch Math.floor(Math.random()*4)
      when 0 then @healthUP = Math.floor(Math.random()*10)
      when 1 then @healthDOWN = Math.floor(Math.random()*5)
      when 2 then @speedUP = 1
      when 3 then @speedDOWN = 1
      else @healthDOWN = 100
    super
