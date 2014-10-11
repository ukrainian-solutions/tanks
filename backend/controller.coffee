map = require './map'

class Controller
  io: no
  tanks: []
  tanks_to_remove: []
  bullets: []
  has_bullets_to_remove: no  # if yes in next mainLoop restruct @bullets
  boosts: []

  tanks_timeout: no
  is_started: yes
  mainLoop_timeout: 150

  tank_last_id: 0
  boost_last_id: 0
  bullet_last_id: 0
  id_prefixes: ["A", "B", "C", "D", "H", "X", "Z", "N"]

  tanksCount: => @tanks.length

  ## BEGIN Tanks controller
  getNewTankId: ->
    @tank_last_id = @tank_last_id + 1
    return @id_prefixes[Math.floor (Math.random() * @id_prefixes.length)] + @tank_last_id

  appendTank: (tank)->
    tank.speed = 3
    @tanks.push tank
    @io.sockets.emit 'tanks', [tank.toJson()]

  removeTank: (tank_to_remove)-> @tanks_to_remove.push tank_to_remove.id
  ## END Tanks controller

  ## BEGIN Boost controller
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
  ## END Boost controller

  ## BEGIN Bullet controller
  getNewBulletId: ->
    @bullet_last_id = @bullet_last_id + 1
    return @id_prefixes[Math.floor (Math.random() * @id_prefixes.length)] + @bullet_last_id

  appendBullet: (bullet)->
    @bullets.push bullet
    @io.sockets.emit 'newBullet', bullet.toJson()


  removeBullet: (bullet)->
    bullet.is_on_fly = no
    @has_bullets_to_remove = yes
    @io.sockets.emit 'removeBullet', bullet.toJson()
  ## END Bullet controller

  whatOnTile: (x,y)->

    for boost in @boosts
      if boost.place_on_map[0] is x and boost.place_on_map[1] == y
        return ['boost', boost]

    for tank in @tanks
      if tank.place_on_map[0] is x and tank.place_on_map[1] == y
        return ['tank', tank]

    for bullet in @bullets
      if bullet.place_on_map[0] is x and bullet.place_on_map[1] == y
        return ['bullet', bullet]

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

    # move bullets
    for bullet in @bullets
      console.log "bullet", bullet.id, "do move!"
      bullet_move = bullet.move()
      console.log 'bullet moved', bullet.id, 'res', bullet_move
      if not bullet_move is no
        tanks_demaged_objects.push bullet_move
        tanks_demaged_list.push bullet_move.id

    # move tanks
    for tank in @tanks
      if tank.socket != "bot" and not tank.socket?.connected
        console.log 'found disconnected tank', tank
        io.sockets.emit 'removeTank', tank.id
        tank = undefined

      if tank == undefined then continue
      tank_move = tank.move()
      if tank.id in tanks_demaged_list or tank is yes
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

    if tanks.length > 0
      console.log 'try to send tanks', tanks
      @io.sockets.emit 'tanks', tanks

    #cleanup used bullets
    if @has_bullets_to_remove
      console.log 'we have bullets to remove. Do it!'
      new_bullets = []
      for bullet in @bullets
        if not bullet.is_on_fly
          console.log 'found used bullet', bullet.id
          continue
        new_bullets.push bullet
      @bullets = new_bullets
      @has_bullets_to_remove = no

    if @is_started then setTimeout @mainLoop, @mainLoop_timeout

  start: ->
    @is_started = yes
    @mainLoop()

  stop: -> @is_started = no


module.exports = new Controller
