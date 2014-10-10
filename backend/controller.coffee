class Controller
  io: no
  tanks: []
  tanks_to_remove: []
  bullets: []

  tanks_timeout: no
  is_started: no
  mainLoop_timeout: 150

  tank_last_id: 0
  tank_id_prefixes: ["a", "A", "b", "B", "c", "C", "x", "X"]

  tanksCount: => @tanks.length

  getNewTankId: ->
    @tank_last_id = @tank_last_id + 1
    return @tank_id_prefixes[Math.floor (Math.random() * @tank_id_prefixes.length)] + @tank_last_id

  appendTank: (tank)->
    @tanks.push tank
    @io.sockets.emit 'tanks', [tank.toJson()]

  removeTank: (tank_to_remove)-> @tanks_to_remove.push tank_to_remove.id

  whatOnTile: (x,y)->
    console.log 'tanks count', @tanks.length
    for tank in @tanks
      if tank.place_on_map[0] is x and tank.place_on_map[1] == y
        return ['tank', tank]
    # for bullet in @bullets then if bullet.place_on_map == [x,y] then return ['bullet', bullet]
    return no

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
