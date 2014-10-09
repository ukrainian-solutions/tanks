class Controller
  io: no
  tanks: []
  bullets: []

  tanks_interval: no


  tanksCount: => @tanks.length
  appendTank: (tank)-> @tanks.push tank

  whatOnTile: (x,y)->
    console.log 'tanks', @tanks
    for tank in @tanks then if tank.place_on_map == [x,y] then return ['tank', tank]
    for bullet in @bullets then if bullet.place_on_map == [x,y] then return ['bullet', bullet]
    return no

  start: -> if @tanks_interval is no
    @tanks_interval = setInterval =>
      tanks = []
      for tank in @tanks
        tank.move()
        tanks.push tank.toJson()
      @io.sockets.emit 'tanks', tanks
    , 500

  stop: ->
    clearInterval @tanks_interval
    @tanks_interval = no

module.exports = new Controller
