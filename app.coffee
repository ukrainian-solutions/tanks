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

controller.appendTank new Tank 0

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
