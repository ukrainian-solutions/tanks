class Tank

  my_tank = false
  id: false
  direction: false
  is_hold: false
  wait: false
  bullets: false
  bullets_max: false
  health: false
  place_on_map: false

  constructor: ()->
    console.log('Tank create')


  convert: (tank_json) ->
#    console.log('tank_json', tank_json)
    if tank_json['id'] == undefined
      tank_json =
        'id': tank_json[0]
        'direction': tank_json[1]
        'is_hold': tank_json[2]
        'wait': tank_json[3]
        'bullets': tank_json[4]
        'bullets_max': tank_json[5]
        'health': tank_json[6]
        'place_on_map': tank_json[7]
        'damage_inflicted': tank_json[8]
        'demage_obtained': tank_json[9]
        'destroyed': tank_json[10]
        'speed': tank_json[11]
    else
      console.log tank_json
      return tank_json

  remove_tank: (tank_id) ->
    tank = $('[data-id_tank='+tank_id+']')
    tank.html('')
    tank.removeClass('my_tank')
    tank.removeClass('tank')
    tank.removeClass('left')
    tank.removeClass('right')
    tank.removeClass('down')
    tank.removeClass('up')
    tank.addClass('box')


  draw_tank: (tank) ->
    # return [@id, @direction, @is_hold, @wait, @bullets, @bullets_max, @health, @place_on_map]
    y = tank['place_on_map'][0]
    x = tank['place_on_map'][1]
    div = $('*[data-x='+x.toString()+'][data-y='+ y.toString()+']')
    div.attr('data-id_tank', tank['id'])
    div.html(tank['health'])
    if tank['id'] == @my_tank
      div.addClass('my_tank')
    else
      div.addClass('tank')
    div.addClass(tank['direction'])

  move_tank: (tank_json) ->
#      console.log 'move tank', tank_json, tank_json["id"]
    tank = $('[data-id_tank='+tank_json['id']+']')
    tank.html('')
    tank.removeClass('my_tank')
    tank.removeClass('tank')
    tank.removeClass('left')
    tank.removeClass('right')
    tank.removeClass('down')
    tank.removeClass('up')
    tank.addClass('box')
    @draw_tank(tank_json)

  tank_stats: (tank) ->
    console.log 'tank_stats', tank
    table = $('.tank_stats')
    list_stats = ['id', 'damage_inflicted', 'demage_obtained', 'destroyed']
    div_tr = $('<tr/>', {
          id: 'tr_'+tank['id'],
    }).appendTo table
    for stat in list_stats
      div_td = $('<td/>', {
          id: "td_#{tank[stat]}"
      }).appendTo div_tr
      div_td.html(tank[stat])