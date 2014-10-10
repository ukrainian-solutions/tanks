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
    tanks_demaged_objects = []
    tanks_demaged_list = []
    for tank in @tanks
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

    console.log 'Tanks demaged list:', tanks_demaged_list, tanks_demaged_objects
    for tank in tanks_demaged_objects
      if tank.id in tanks_demaged_list then tanks.push tank.toJson()

    @io.sockets.emit 'tanks', tanks
    if @is_started then setTimeout @mainLoop, @mainLoop_timeout

  start: ->
    @is_started = yes
    @mainLoop()

  stop: -> @is_started = no


module.exports = new Controller
