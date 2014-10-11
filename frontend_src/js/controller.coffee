# main controller
$ ->

  key_code =
    37: 'left'
    38: 'up'
    39: 'right'
    40: 'down'

  direct = 'up'
  stay = false

  Boost = new Boost()
  Map = new Map()
  Tank = new Tank()

  # start work
  socket.emit('addTank', (tank) ->
    tank = Tank.convert(tank)
    Tank.my_tank = tank['id']
    Tank.draw_tank(tank, yes)
  )

  socket.on('tankDestroy', (tank_id) ->
    Tank.remove_tank(tank_id)
  )
  socket.on('newBoost', (boost) ->
    console.log('boost',boost)
    Boost.add_boost(boost)
  )
  socket.on('removeBoost', (boost) ->
    console.log('boost',boost)
    Boost.remove_boost(boost)
  )

  $('html').keydown( (eventObject) ->
#    console.log('key code', key_code[event.keyCode])
    direct = if key_code[event.keyCode] then key_code[event.keyCode] else direct
    stay = if event.keyCode == 81 then true else stay
    stay = if event.keyCode == 87 then false else stay
    return socket.emit('setDirection', direct , stay)
  )

  socket.on('tanks', (tanks) ->
#    console.log 'socket on  tanks', tanks
    for tank in tanks
      tank = Tank.convert(tank)
      Tank.move_tank(tank)
#      Tank.tank_stats(tank)
  )

  socket.on('info', (logg) ->
    console.log 'socket on  info'
    console.log(logg)
  )

  socket.emit('map', (map) ->
    console.log 'socket emit map'
    Map.render_map(map)
  )

  socket.emit('tanks', (tanks_json) ->
    for tank in tanks_json
      tank = Tank.convert(tank)
      Tank.draw_tank(tank)
  )