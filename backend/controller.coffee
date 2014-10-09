class Controller

  tanks: []
  bullets: []

  tanksCount: => @tanks.length
  appendTank: (tank)-> @tanks.push tank

  whatOnTile: (x,y)->
    for tank in @tanks then if tank.place_on_map == [x,y] then return ['tank', tank]
    for bullet in @bullents then if bullen.place_on_map == [x,y] then return ['bullet', bullet]
    return no

module.exports = new Controller
