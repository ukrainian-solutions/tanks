controller = require './controller'
bullet = require './bullet'

class Boost

  id: no
  place_on_map: no

  healthUP: no
  healthDOWN: no
  speedUP: no
  speedDOWN: no
  bullet: no

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
    else if @speedDOWN
      if tank.speed + @speedDOWN < controller.tankMaxSpeed()
        tank.speed += @speedDOWN
      else tank.speed = controller.tankMaxSpeed()
      tank.sendInfo 'boost', ["speedDOWN-#{tank.speed}"]

    if @bullet
      tank.addBullet new @bullet tank


  toJson: -> [@place_on_map, @type]


exports.speedUP = class BoostSpeedUP extends Boost
  type: "speedUP"
  speedUP: 1

exports.healthUP = class BoostHealthUP extends Boost
  type: "healthUP"
  healthUP: Math.floor(Math.random()*10)+1

exports.bulletLight = class BoostBulletLight extends Boost
  type: "bulletLight"
  bullet: bullet.light

exports.bulletBig = class BoostBulletLight extends Boost
  type: "bulletBig"
  bullet: bullet.big

exports.bulletSuper = class BoostBulletLight extends Boost
  type: "bulletLight"
  bullet: bullet.super

exports.mystery =  class BoostMystery extends Boost
  type: "mystery"

  use: (tank)->
    switch Math.floor(Math.random()*7)
      when 0 then @healthUP = Math.floor(Math.random()*10)
      when 1 then @healthDOWN = Math.floor(Math.random()*5)
      when 2 then @speedUP = 1
      when 3 then @speedDOWN = 1
      when 4 then @bullet = bullet.light
      when 5 then @bullet = bullet.big
      when 6 then @bullet = bullet.super
      else @healthDOWN = 100
    super
