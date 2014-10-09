class Controller
  io: no
  tanks: []
  bullets: []

  tanks_interval: no


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

  start: -> if @tanks_interval is no
    @tanks_interval = setInterval =>
      tanks = []
      for tank in @tanks
        if tank == undefined then continue
        tank.move()
        tanks.push tank.toJson()
      @io.sockets.emit 'tanks', tanks
    , 500

  stop: ->
    clearInterval @tanks_interval
    @tanks_interval = no


module.exports = new Controller
