express = require 'express'
app = express()
server = require('http').Server app
io = require('socket.io') server
map = require './backend/map'
controller = require './backend/controller'

Tank = require './backend/tank'


server.listen 3000

app.get '/', (req, res, next) -> res.sendFile __dirname + '/frontend/index.html'

app.use '/bower', express.static(__dirname + '/bower_components')
app.use '/', express.static(__dirname + '/frontend')


first_tank = new Tank controller.tanksCount()
second_tank = new Tank controller.tanksCount()

second_tank.place_on_map = [10,10]

io.on 'connection', (socket)->
  socket.on 'map', (fn)->
    console.log 'map'
    fn map.getMap()

