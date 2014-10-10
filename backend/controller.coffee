class Controller
  io: no
  tanks: []
  bullets: []

  tanks_timeout: no
  is_started: no
  mainLoop_timeout: 150



  tanksCount: => @tanks.length
  appendTank: (tank)-> @tanks.push tank
  removeTank: (tank_to_delete)->
    new_tanks = []
    for tank in @tanks
      if tank.id != tank_to_delete.id then new_tanks.push tank
    @tanks = new_tanks

  whatOnTile: (x,y)->
    console.log 'tanks', @tanks
    for tank in @tanks
      if tank.place_on_map[0] is x and tank.place_on_map[1] == y
        return ['tank', tank]
    # for bullet in @bullets then if bullet.place_on_map == [x,y] then return ['bullet', bullet]
    return no

  tankMaxSpeed: -> Math.round 1000/@mainLoop_timeout

  mainLoop: =>
    tanks = []
    for tank in @tanks
      if tank == undefined then continue
      tank.move()
      tanks.push tank.toJson()
    @io.sockets.emit 'tanks', tanks
    if @is_started then setTimeout @mainLoop, @mainLoop_timeout

  start: ->
    @is_started = yes
    @mainLoop()

  stop: -> @is_started = no


module.exports = new Controller
