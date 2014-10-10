map = require './map'

class Controller
  io: no
  tanks: []
  tanks_to_remove: []
  bullets: []
  boosts: []

  tanks_timeout: no
  is_started: yes
  mainLoop_timeout: 150

  tank_last_id: 0
  boost_last_id: 0
  id_prefixes: ["a", "A", "b", "B", "c", "C", "x", "X"]

  tanksCount: => @tanks.length

  getNewTankId: ->
    @tank_last_id = @tank_last_id + 1
    return @id_prefixes[Math.floor (Math.random() * @id_prefixes.length)] + @tank_last_id

  appendTank: (tank)->
    tank.speed = 3
    @tanks.push tank
    @io.sockets.emit 'tanks', [tank.toJson()]

  removeTank: (tank_to_remove)-> @tanks_to_remove.push tank_to_remove.id

  getNewBoostId: ->
    @boost_last_id = @boost_last_id + 1
    return @id_prefixes[Math.floor (Math.random() * @id_prefixes.length)] + @boost_last_id

  appendBoost: (boost)->
    @boosts.push boost
    @io.sockets.emit 'newBoost', boost.toJson()

  removeBoost: (boost_to_remove)->
    @io.sockets.emit 'removeBoost', boost_to_remove.toJson()
    boosts = []
    for boost in @boosts
      if boost.id == boost_to_remove.id then continue
      boosts.push boost
    @boosts = boosts


  whatOnTile: (x,y)->
    console.log 'tanks count', @tanks.length

    for boost in @boosts
      if boost.place_on_map[0] is x and boost.place_on_map[1] == y
        return ['boost', boost]

    for tank in @tanks
      if tank.place_on_map[0] is x and tank.place_on_map[1] == y
        return ['tank', tank]
    # for bullet in @bullets then if bullet.place_on_map == [x,y] then return ['bullet', bullet]
    return no

  getFreeRandomTile: -> while yes
      x = Math.floor (Math.random() * map.maxX())
      y = Math.floor (Math.random() * map.maxY())
      if map.getTile(x, y) is 0 and @whatOnTile(x, y) is no
        return [x,y]

  tankMaxSpeed: -> Math.round(1000/@mainLoop_timeout)-1

  mainLoop: =>
    if @tanks_to_remove.length > 0
      console.log 'tanks need remove:', @tanks_to_remove
      new_tanks = []
      for tank in @tanks
        if tank.id not in @tanks_to_remove then new_tanks.push tank
        else
          @io.sockets.emit 'removeTank', tank.id
          console.log 'tank removed', tank.id
      @tanks = new_tanks
      @tanks_to_remove = []

    tanks = []
    tanks_demaged_objects = []
    tanks_demaged_list = []
    for tank in @tanks
      if tank.socket != "bot" and not tank.socket?.connected
        console.log 'found disconnected tank', tank
        io.sockets.emit 'removeTank', tank.id
        tank = undefined

      if tank == undefined then continue
      tank_move = tank.move()
      if tank.id in tanks_demaged_list
        tanks_demaged_list[tank.id] = undefined
      else if tank_move is no then continue

      if tank_move[1] != undefined  # if other tank demaged here may be link to this tank object
        console.log 'add to demaged tanks list'
        tanks_demaged_list.push tank_move[1].id
        tanks_demaged_objects.push tank_move[1]
      tanks.push tank.toJson()

    if tanks_demaged_list.length > 0
      console.log 'Tanks demaged list:', tanks_demaged_list, tanks_demaged_objects
      for tank in tanks_demaged_objects
        if tank.id in tanks_demaged_list then tanks.push tank.toJson()

    if tanks.length > 0 then @io.sockets.emit 'tanks', tanks

    if @is_started then setTimeout @mainLoop, @mainLoop_timeout

  start: ->
    @is_started = yes
    @mainLoop()

  stop: -> @is_started = no


module.exports = new Controller
