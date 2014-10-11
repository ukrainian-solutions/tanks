express = require 'express'
app = express()
server = require('http').Server app
io = require('socket.io') server
map = require './backend/map'
Boost = require './backend/boost'
Bullet = require './backend/bullet'
controller = require './backend/controller'
controller.io = io
Tank = require './backend/tank'


server.listen 3000

app.get '/', (req, res, next) -> res.sendFile __dirname + '/frontend/index.html'

app.use '/bower', express.static(__dirname + '/bower_components')
app.use '/', express.static(__dirname + '/frontend')


boosts_enabled = ['speedUP', 'healthUP', 'mystery']
setInterval ->
  if controller.boosts.length > 3 then return
  switch boosts_enabled[Math.floor(Math.random()*boosts_enabled.length)]
    when "speedUP"
      boost = new Boost.speedUP controller.getFreeRandomTile()
    when "healthUP"
      boost = new Boost.healthUP controller.getFreeRandomTile()
    when "mystery"
      boost = new Boost.mystery controller.getFreeRandomTile()
  controller.appendBoost boost
, 10000


bot1 = new Tank controller.getNewTankId(), 'bot'
controller.appendTank bot1
directions = ['left', 'right', 'up', 'down']
setInterval ->
  # bot1.direction = directions[Math.floor (Math.random() * 4)]
  bot1.is_hold = yes
, 2000

io.on 'connection', (socket)=>

  socket.on 'addTank', (fn)->
    if socket.tank then return fn no
    socket.tank = new Tank controller.getNewTankId(), socket

    not_placed = yes
    while not_placed
      x = Math.floor (Math.random() * map.maxX())
      y = Math.floor (Math.random() * map.maxY())
      if map.getTile(x, y) is 0 and controller.whatOnTile(x, y) is no
        not_placed = no
        socket.tank.place_on_map = [x,y]
        controller.appendTank socket.tank
    fn socket.tank.toJson()

  socket.on 'disconnect', -> if socket.tank != undefined then controller.removeTank socket.tank

  socket.on 'map', (fn)->
    console.log 'map'
    fn map.getMap()

  socket.on 'tanks', (fn)->
    tanks = []
    for tank in controller.tanks
      tanks.push tank.toJson()
    fn(tanks)

  socket.on 'setDirection', (direction, is_hold)-> if socket.tank
    console.log 'setDirection', direction, is_hold
    if direction in ['left', 'right', 'up', 'down'] and is_hold in [yes, no]
      console.log 'yes'
      socket.tank.direction = direction
      socket.tank.is_hold = is_hold
    else console.log 'no'

  socket.on 'fire', (bullet_id)-> if socket.tank
    console.log 'Do fire!'
    socket.tank.fire bullet_id

  socket.on 'boosts', (fn)->
    boosts = []
    for boost in controller.boosts
      boosts.push boost.toJson()
    fn boosts

  socket.on 'giveMeBullet', (fn)-> if socket.tank
    bullet = new Bullet.super socket.tank
    socket.tank.addBullet bullet
    console.log 'bullet given', bullet.id
    fn bullet.id

controller.start()
