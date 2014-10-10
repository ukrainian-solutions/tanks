express = require 'express'
app = express()
server = require('http').Server app
io = require('socket.io') server
map = require './backend/map'
controller = require './backend/controller'
controller.io = io
Tank = require './backend/tank'


server.listen 3000

app.get '/', (req, res, next) -> res.sendFile __dirname + '/frontend/index.html'

app.use '/bower', express.static(__dirname + '/bower_components')
app.use '/', express.static(__dirname + '/frontend')


directions = ['left', 'right', 'up', 'down']
bot1 = new Tank 0
controller.appendTank bot1
setInterval ->
  bot1.direction = directions[Math.floor (Math.random() * 5)]
  bot1.is_hold = no
, 2000

bot2 = new Tank 1
controller.appendTank bot2
setInterval ->
  bot2.direction = directions[Math.floor (Math.random() * 4)]
  bot2.is_hold = no
, 2000

bot3 = new Tank 2
controller.appendTank bot3
setInterval ->
  bot3.direction = directions[Math.floor (Math.random() * 4)]
  bot3.is_hold = no
, 2000

io.on 'connection', (socket)=>

  socket.on 'addTank', (fn)->
    if socket.tank then return fn no
    socket.tank = new Tank controller.tanksCount()

    not_placed = yes
    while not_placed
      x = Math.floor (Math.random() * map.maxX()) + 1
      y = Math.floor (Math.random() * map.maxY()) + 1
      if map.getTile(x, y) is 0 and controller.whatOnTile(x, y) is no
        not_placed = no
        socket.tank.place_on_map = [x,y]
        controller.appendTank socket.tank
    fn socket.tank.toJson()

  socket.on 'disconnect', ->
    if socket.tank != undefined
      io.sockets.emit 'tankDestroy', socket.tank.id
      controller.removeTank socket.tank

  socket.on 'map', (fn)->
    console.log 'map'
    fn map.getMap()

  socket.on 'tanks', (fn)->
    tanks = []
    for tank in controller.tanks
      tanks.push tank.toJson()
    fn(tanks)

  socket.on 'setDirection', (direction, is_hold)->
    console.log 'setDirection', direction, is_hold
    if direction in ['left', 'right', 'up', 'down'] and is_hold in [yes, no]
      console.log 'yes'
      socket.tank.direction = direction
      socket.tank.is_hold = is_hold
    else console.log 'no'

  socket.on 'start', ->
    controller.start()

  socket.on 'stop', ->
    controller.stop()
