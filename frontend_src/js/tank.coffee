class Tank

  id: false
  direction: false
  is_hold: false
  wait: false
  bullets: false
  bullets_max: false
  health: false
  place_on_map: false

  constructor: (tank_json)->
    @fill(tank_json)

  fill: (tank_json) ->
    @id= tank_json[0]
    @direction = tank_json[1]
    @is_hold = tank_json[2]
    @wait = tank_json[3]
    @bullets = tank_json[4]
    @bullets_max = tank_json[5]
    @health = tank_json[6]
    @place_on_map = tank_json[7]

